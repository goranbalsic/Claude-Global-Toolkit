# Requires -Version 5.1
# The managed region is the only text this tool owns.
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Version = '3.0.0'
$CoreLimit = 1200
$StateLimit = 400
$RootDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$CoreFile = Join-Path $RootDir 'core\CLAUDE.core.md'
$TargetDir = (Get-Location).Path
$GlobalTarget = $false
$DryRun = $false
$AssumeYes = $false
$Mode = 'link'
$ModeSet = $false
$Profile = 'standard'
$ProfileSet = $false
$ModulesDisabled = $false
$RequestedModules = New-Object System.Collections.Generic.List[string]
$StateAction = $null
$StateText = $null
$BudgetPassed = $true
$ProfileAssetsPassed = $true
$InstalledAssetsPassed = $true
$StageRecords = @{}

function Fail([string]$Message) { Write-Error "ERROR: $Message"; exit 1 }
function Show-Usage {
@'
Usage: ctk <command> [options]

Commands:
  install       Append the managed block and stage the selected profile.
  update        Replace the managed block and stage the selected profile.
  uninstall     Remove the managed block and unmodified staged assets.
  restore       Restore the newest managed-file backup.
  status        Show target, profile, managed-block, and staged-asset status.
  doctor        Check block integrity, drift, budget, staged assets, and backups.
  budget        Measure the always-loaded core and bounded state.
  state         state show | state add "text" | state rotate
  version       Print the toolkit version.
  help          Print this help.

Options:
  --link                    Inject an absolute @ import (default).
  --embed                   Inline the core into the managed block.
  --global                  Use ~/.claude as the target directory.
  --profile NAME            minimal, standard, or full (default: standard).
  --module NAME             Stage a named module; may be repeated.
  --no-modules              Do not stage detected or explicitly requested modules.
  --target DIR              Target directory (default: current directory).
  --dry-run                 Describe a mutating operation without writing.
  --yes                     Do not prompt before a mutation.
'@ | Write-Output
}

function Get-TargetFile { Join-Path $script:TargetDir 'CLAUDE.md' }
function Get-BackupDir { Join-Path $script:TargetDir '.ctk-backup' }
function Get-StateFile { Join-Path $script:TargetDir '.claude\ctk\STATE.md' }
function Get-InstalledFile { Join-Path $script:TargetDir '.claude\ctk\installed.txt' }
function Require-Core { if (-not (Test-Path -LiteralPath $CoreFile -PathType Leaf)) { Fail "core file is missing: $CoreFile" } }
function Get-FileSha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-CoreHash { Require-Core; (Get-FileSha256 $CoreFile).Substring(0, 12) }
function Get-StateHash {
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes("# ctk bounded session state$([Environment]::NewLine)")
    $sha = [Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() } finally { $sha.Dispose() }
}
function Test-Profile {
    if ($Profile -notin @('minimal', 'standard', 'full')) { Fail "invalid profile: $Profile (expected minimal, standard, or full)" }
    if (-not (Test-Path -LiteralPath (Join-Path $RootDir ("core\profiles\{0}.txt" -f $Profile)) -PathType Leaf)) { Fail "profile manifest is missing: $Profile" }
}
function Test-SafeRelative([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or [IO.Path]::IsPathRooted($Path)) { return $false }
    foreach ($part in ($Path -split '[\\/]')) { if ($part -eq '..' -or $part -eq '') { return $false } }
    return $true
}
function Ensure-ReadTarget { if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) { Fail "target directory does not exist: $TargetDir" } }
function Ensure-WriteTarget { if (-not (Test-Path -LiteralPath $TargetDir -PathType Container) -and -not $GlobalTarget) { Fail "target directory does not exist: $TargetDir" } }
function Get-BlockState {
    $file = Get-TargetFile
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return 'absent' }
    $text = [IO.File]::ReadAllText($file)
    $begins = [regex]::Matches($text, '(?m)^<!-- ctk:begin v=').Count
    $ends = [regex]::Matches($text, '(?m)^<!-- ctk:end -->\r?$').Count
    if ($begins -eq 0 -and $ends -eq 0) { return 'absent' }
    if ($begins -eq 1 -and $ends -eq 1 -and $text.IndexOf('<!-- ctk:begin v=') -lt $text.IndexOf('<!-- ctk:end -->')) { return 'complete' }
    return 'orphan'
}
function Get-HeaderValue([string]$Name) {
    $text = [IO.File]::ReadAllText((Get-TargetFile))
    $match = [regex]::Match($text, ("(?m)^<!-- ctk:begin v=[^`r`n]*\b{0}=([^\s]+)" -f [regex]::Escape($Name)))
    if ($match.Success) { return $match.Groups[1].Value }; return ''
}
function Get-BlockMode {
    $match = [regex]::Match([IO.File]::ReadAllText((Get-TargetFile)), '(?ms)^<!-- ctk:begin v=.*?\r?\n(.*?)^<!-- ctk:end -->')
    if ($match.Success -and $match.Groups[1].Value -match '(?m)^@([A-Za-z]:\\|/)') { return 'link' }; return 'embed'
}
function Confirm-Mutation([string]$Description) {
    if ($AssumeYes) { return }
    if ($Host.Name -eq 'ConsoleHost') { if ((Read-Host "$Description [y/N]") -in @('y', 'Y', 'yes', 'YES')) { return }; Fail 'operation cancelled' }
    Fail 'non-interactive mutation requires --yes'
}
# The common backup helper is used for the managed block and all staged files.
function Save-Backup([string]$Source) {
    $targetPrefix = $TargetDir.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $Source.StartsWith($targetPrefix, [StringComparison]::OrdinalIgnoreCase)) { Fail "backup path is outside target: $Source" }
    $relative = $Source.Substring($targetPrefix.Length).Replace('\', '/')
    if (-not (Test-SafeRelative $relative)) { Fail "unsafe backup path: $relative" }
    $root = Get-BackupDir
    $backup = Join-Path $root ($relative + '.' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ'))
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backup) | Out-Null
    $n = 1
    while (Test-Path -LiteralPath $backup) { $backup = Join-Path $root ($relative + '.' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ') + '-' + $n); $n++ }
    if (Test-Path -LiteralPath $Source -PathType Leaf) { Copy-Item -LiteralPath $Source -Destination $backup } else { [IO.File]::WriteAllBytes($backup, [byte[]]@()) }
    return $backup
}
function New-Block([bool]$SeparatorAdded = $false) {
    $header = "<!-- ctk:begin v=$Version profile=$Profile hash=$(Get-CoreHash) sep=$([int]$SeparatorAdded) -->"
    if ($Mode -eq 'link') { return $header + [Environment]::NewLine + '@' + $CoreFile + [Environment]::NewLine + '<!-- ctk:end -->' + [Environment]::NewLine }
    $body = [IO.File]::ReadAllText($CoreFile); if (-not $body.EndsWith("`n")) { $body += [Environment]::NewLine }
    return $header + [Environment]::NewLine + $body + '<!-- ctk:end -->' + [Environment]::NewLine
}
function Write-TargetText([string]$Text) { [IO.File]::WriteAllText((Get-TargetFile), $Text, [Text.UTF8Encoding]::new($false)) }
function Choose-ExistingSettings {
    if ((Get-BlockState) -eq 'complete') {
        if (-not $ProfileSet) { $oldProfile = Get-HeaderValue 'profile'; if ($oldProfile) { $script:Profile = $oldProfile } }
        if (-not $ModeSet) { $script:Mode = Get-BlockMode }
    }
    Test-Profile
}
function Get-ProfileEntries {
    $manifest = Join-Path $RootDir ("core\profiles\{0}.txt" -f $Profile)
    foreach ($raw in Get-Content -LiteralPath $manifest) {
        $line = $raw.Trim()
        if (-not $line -or $line.StartsWith('#')) { continue }
        $parts = [regex]::Split($line, '\t+| {2,}', 2)
        if ($parts.Count -ne 2) { Fail "invalid profile manifest entry: $raw" }
        [pscustomobject]@{ Source = $parts[0]; Destination = $parts[1] }
    }
}
function Test-ProfileAssets {
    $failed = $false
    foreach ($entry in Get-ProfileEntries) {
        if (-not (Test-SafeRelative $entry.Destination.TrimEnd('/'))) { Write-Output "FAIL: profile destination is unsafe: $($entry.Destination)"; $failed = $true; continue }
        if ($entry.Source -eq '@state') { Write-Output 'PASS: referenced generated asset exists: @state'; continue }
        $source = Join-Path $RootDir $entry.Source.TrimEnd('/', '\')
        if (Test-Path -LiteralPath $source) { Write-Output "PASS: referenced asset exists: $($entry.Source)" } else { Write-Output "FAIL: referenced asset is missing: $($entry.Source)"; $failed = $true }
    }
    $script:ProfileAssetsPassed = -not $failed
}
function Prepare-StageRecords {
    $script:StageRecords = @{}
    $installed = Get-InstalledFile
    if (Test-Path -LiteralPath $installed -PathType Leaf) {
        foreach ($line in Get-Content -LiteralPath $installed) {
            $parts = $line -split "`t", 2
            if ($parts.Count -eq 2 -and $parts[0] -notin @('version', 'profile') -and -not $parts[0].StartsWith('#')) { $script:StageRecords[$parts[0]] = $parts[1] }
        }
    }
}
function Write-InstalledManifest {
    $installed = Get-InstalledFile
    if ($StageRecords.Count -eq 0) { Remove-Item -LiteralPath $installed -Force -ErrorAction SilentlyContinue; return }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $installed) | Out-Null
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# ctk installed assets'); $lines.Add("version`t$Version"); $lines.Add("profile`t$Profile")
    foreach ($path in ($StageRecords.Keys | Sort-Object)) { $lines.Add("$path`t$($StageRecords[$path])") }
    [IO.File]::WriteAllLines($installed, [string[]]$lines, [Text.UTF8Encoding]::new($false))
}
function Stage-File([string]$Source, [string]$RelativeDestination) {
    if (-not (Test-SafeRelative $RelativeDestination)) { Fail "unsafe staged destination: $RelativeDestination" }
    $destination = Join-Path $TargetDir $RelativeDestination
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { Fail "cannot stage file over non-file: $destination" }
        if ((Get-FileSha256 $Source) -eq (Get-FileSha256 $destination)) {
            if ($DryRun) { Write-Output "DRY-RUN: SKIP: identical staged file: $RelativeDestination" } else { $StageRecords[$RelativeDestination] = Get-FileSha256 $destination; Write-Output "SKIP: identical staged file: $RelativeDestination" }
            return
        }
        if ($DryRun) { Write-Output "DRY-RUN: BACKUP: $RelativeDestination -> .ctk-backup/$RelativeDestination.<timestamp>"; Write-Output "DRY-RUN: STAGE: $Source -> $RelativeDestination"; return }
        $backup = Save-Backup $destination
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $Source -Destination $destination -Force
        $StageRecords[$RelativeDestination] = Get-FileSha256 $destination
        Write-Output "CHANGED: staged $RelativeDestination (backup: $backup)"
    } else {
        if ($DryRun) { Write-Output "DRY-RUN: STAGE: $Source -> $RelativeDestination"; return }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $Source -Destination $destination
        $StageRecords[$RelativeDestination] = Get-FileSha256 $destination
        Write-Output "CHANGED: staged $RelativeDestination"
    }
}
function Stage-StateFile {
    $relative = '.claude/ctk/STATE.md'; $destination = Get-StateFile; $hash = Get-StateHash
    $identical = (Test-Path -LiteralPath $destination -PathType Leaf) -and ((Get-FileSha256 $destination) -eq $hash)
    if ($identical) { if ($DryRun) { Write-Output "DRY-RUN: SKIP: identical staged file: $relative" } else { $StageRecords[$relative] = $hash; Write-Output "SKIP: identical staged file: $relative" }; return }
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { Fail "cannot stage state over non-file: $destination" }
        if ($DryRun) { Write-Output "DRY-RUN: BACKUP: $relative -> .ctk-backup/$relative.<timestamp>"; Write-Output "DRY-RUN: STAGE: @state -> $relative"; return }
        $backup = Save-Backup $destination
        [IO.File]::WriteAllText($destination, "# ctk bounded session state$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))
        $StageRecords[$relative] = $hash; Write-Output "CHANGED: staged $relative (backup: $backup)"
    } else {
        if ($DryRun) { Write-Output "DRY-RUN: STAGE: @state -> $relative"; return }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        [IO.File]::WriteAllText($destination, "# ctk bounded session state$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))
        $StageRecords[$relative] = $hash; Write-Output "CHANGED: staged $relative"
    }
}
function Stage-Directory([string]$SourceDirectory, [string]$DestinationDirectory) {
    if (-not (Test-Path -LiteralPath $SourceDirectory -PathType Container)) { Fail "profile source directory is missing: $SourceDirectory" }
    foreach ($file in Get-ChildItem -LiteralPath $SourceDirectory -File -Recurse) {
        $relative = $file.FullName.Substring($SourceDirectory.TrimEnd('\', '/').Length).TrimStart('\', '/')
        Stage-File $file.FullName ((Join-Path $DestinationDirectory $relative).Replace('\', '/'))
    }
}
function Get-ModuleDetectRule([string]$ModuleDirectory) {
    # The declaration is YAML, so the value may be quoted. Strip one layer of
    # surrounding double or single quotes before matching.
    $match = Select-String -LiteralPath (Join-Path $ModuleDirectory 'module.md') -Pattern '^detect:\s*(?:"(.+)"|''(.+)''|(.+?))\s*$' | Select-Object -First 1
    if ($null -ne $match) {
        foreach ($i in 1, 2, 3) {
            $value = $match.Matches[0].Groups[$i].Value
            if ($value -ne '') { return $value }
        }
    }
    return ''
}
function Test-ModuleApplies([string]$ModuleDirectory) {
    $rule = Get-ModuleDetectRule $ModuleDirectory
    if ($rule -match '^(.+) contains (.+)$') { $file = $matches[1]; $text = $matches[2]; return (Test-SafeRelative $file) -and (Test-Path -LiteralPath (Join-Path $TargetDir $file) -PathType Leaf) -and ((Select-String -LiteralPath (Join-Path $TargetDir $file) -SimpleMatch $text -Quiet)) }
    if ($rule -match '^(.+) exists$') { $file = $matches[1]; return (Test-SafeRelative $file) -and (Test-Path -LiteralPath (Join-Path $TargetDir $file)) }
    return $false
}
function Test-ModuleSupportsProfile([string]$ModuleDirectory) { Select-String -LiteralPath (Join-Path $ModuleDirectory 'module.md') -Pattern ('^\s*-\s*' + [regex]::Escape($Profile) + '\s*$') -Quiet }
function Get-SelectedModules {
    if ($ModulesDisabled) { return @() }
    $names = New-Object System.Collections.Generic.List[string]
    if ($Profile -eq 'full') {
        foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $RootDir 'modules') -Directory) { if ((Test-Path -LiteralPath (Join-Path $dir.FullName 'module.md')) -and (Test-ModuleSupportsProfile $dir.FullName) -and (Test-ModuleApplies $dir.FullName)) { $names.Add($dir.Name) } }
    }
    foreach ($name in $RequestedModules) { if (-not (Test-Path -LiteralPath (Join-Path $RootDir ("modules\$name\module.md")) -PathType Leaf)) { Fail "unknown module: $name" }; $names.Add($name) }
    return @($names | Sort-Object -Unique)
}
function Stage-ProfileAssets {
    foreach ($entry in Get-ProfileEntries) {
        if ($entry.Source -eq '@state') { if ($entry.Destination -ne '.claude/ctk/STATE.md') { Fail '@state must target .claude/ctk/STATE.md' }; Stage-StateFile; continue }
        if ($entry.Source.EndsWith('/')) {
            if (-not $entry.Destination.EndsWith('/')) { Fail "directory destination must end in /: $($entry.Destination)" }
            Stage-Directory (Join-Path $RootDir $entry.Source.TrimEnd('/')) $entry.Destination.TrimEnd('/')
        } else { Stage-File (Join-Path $RootDir $entry.Source) $entry.Destination }
    }
    foreach ($module in Get-SelectedModules) {
        $moduleDir = Join-Path $RootDir ("modules\$module")
        if (Test-Path -LiteralPath (Join-Path $moduleDir 'commands') -PathType Container) { Stage-Directory (Join-Path $moduleDir 'commands') ".claude/commands/$module" }
        if (Test-Path -LiteralPath (Join-Path $moduleDir 'scripts') -PathType Container) { Stage-Directory (Join-Path $moduleDir 'scripts') ".claude/ctk/modules/$module/scripts" }
    }
}
function Stage-SelectedProfile { if (-not $DryRun) { Prepare-StageRecords }; Stage-ProfileAssets; if (-not $DryRun) { Write-InstalledManifest } }
function Invoke-Install {
    Ensure-WriteTarget; Choose-ExistingSettings; $state = Get-BlockState
    if ($state -eq 'orphan') { Fail "orphaned ctk markers in $(Get-TargetFile); repair them before install" }
    if ($DryRun) { if ($state -eq 'complete') { Write-Output "DRY-RUN: SKIP: managed block already present in $(Get-TargetFile)" } else { Write-Output "DRY-RUN: install managed block in $(Get-TargetFile)" }; Stage-SelectedProfile; return }
    Confirm-Mutation "Install profile $Profile in ${TargetDir}?"
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    if ($state -eq 'absent') {
        $backup = Save-Backup (Get-TargetFile); $file = Get-TargetFile; $old = if (Test-Path -LiteralPath $file) { [IO.File]::ReadAllText($file) } else { '' }
        $sepAdded = $old.Length -gt 0 -and -not $old.EndsWith("`n")
        if ($sepAdded) { $old += [Environment]::NewLine }
        Write-TargetText ($old + (New-Block $sepAdded)); Write-Output "CHANGED: installed managed block in $file (backup: $backup)"
    } else { Write-Output "SKIP: managed block already present in $(Get-TargetFile)" }
    Stage-SelectedProfile
}
function Invoke-Update {
    Ensure-WriteTarget; $file = Get-TargetFile; if (-not (Test-Path -LiteralPath $file)) { Fail "no target file to update: $file" }; if ((Get-BlockState) -ne 'complete') { Fail 'update requires one complete managed block' }; Choose-ExistingSettings
    $existingSep = (Get-HeaderValue 'sep') -eq '1'
    if ($DryRun) { Write-Output "DRY-RUN: update managed block in $file"; Stage-SelectedProfile; return }
    Confirm-Mutation "Update managed block in ${file}?"; $backup = Save-Backup $file; $old = [IO.File]::ReadAllText($file); $new = [regex]::Replace($old, '(?ms)^<!-- ctk:begin v=.*?^<!-- ctk:end -->\r?\n?', (New-Block $existingSep), 1); Write-TargetText $new; Write-Output "CHANGED: updated managed block in $file (backup: $backup)"; Stage-SelectedProfile
}
function Remove-EmptyParents([string]$Path) { $parent = Split-Path -Parent $Path; while ($parent -and -not [string]::Equals($parent, $TargetDir, [StringComparison]::OrdinalIgnoreCase)) { try { Remove-Item -LiteralPath $parent -Force -ErrorAction Stop } catch { break }; $parent = Split-Path -Parent $parent } }
function Invoke-UninstallStagedAssets {
    $installed = Get-InstalledFile; if (-not (Test-Path -LiteralPath $installed -PathType Leaf)) { return }
    $kept = New-Object System.Collections.Generic.List[string]
    foreach ($line in Get-Content -LiteralPath $installed) {
        $parts = $line -split "`t", 2; if ($parts.Count -ne 2 -or $parts[0] -in @('version', 'profile') -or $parts[0].StartsWith('#')) { continue }
        $path = $parts[0]; $hash = $parts[1]; if (-not (Test-SafeRelative $path)) { Fail "unsafe staged path in installed manifest: $path" }; $target = Join-Path $TargetDir $path
        if (-not (Test-Path -LiteralPath $target)) { Write-Output "SKIP: staged file already absent: $path" }
        elseif (-not (Test-Path -LiteralPath $target -PathType Leaf)) { Write-Output "KEPT: staged path is no longer a file: $path"; $kept.Add("$path`t$hash") }
        elseif ((Get-FileSha256 $target) -eq $hash) { if ($DryRun) { Write-Output "DRY-RUN: REMOVE: $path" } else { Remove-Item -LiteralPath $target -Force; Remove-EmptyParents $target; Write-Output "CHANGED: removed staged file: $path" } }
        else { Write-Output "KEPT: locally modified staged file: $path"; $kept.Add("$path`t$hash") }
    }
    if ($DryRun) { return }
    if ($kept.Count -eq 0) { Remove-Item -LiteralPath $installed -Force; Remove-EmptyParents $installed } else { $lines = @('# ctk installed assets', "version`t$Version", "profile`t$Profile") + @($kept); [IO.File]::WriteAllLines($installed, [string[]]$lines, [Text.UTF8Encoding]::new($false)) }
}
function Invoke-Uninstall {
    Ensure-WriteTarget; $file = Get-TargetFile; if (-not (Test-Path -LiteralPath $file)) { Fail "no target file to uninstall: $file" }; if ((Get-BlockState) -ne 'complete') { Fail 'uninstall requires one complete managed block' }
    $sepAdded = (Get-HeaderValue 'sep') -eq '1'
    if ($DryRun) { Write-Output "DRY-RUN: uninstall managed block from $file"; Invoke-UninstallStagedAssets; return }
    Confirm-Mutation "Remove managed block and staged assets from ${TargetDir}?"; $backup = Save-Backup $file
    $old = [IO.File]::ReadAllText($file)
    $match = [regex]::Match($old, '(?ms)^<!-- ctk:begin v=.*?^<!-- ctk:end -->\r?\n?')
    if (-not $match.Success) { Fail 'managed block not found for removal' }
    $before = $old.Substring(0, $match.Index)
    $after = $old.Substring($match.Index + $match.Length)
    if ($sepAdded) {
        if ($before.EndsWith("`r`n")) { $before = $before.Substring(0, $before.Length - 2) }
        elseif ($before.EndsWith("`n")) { $before = $before.Substring(0, $before.Length - 1) }
    }
    $new = $before + $after
    if ($new -match '\S') { Write-TargetText $new; Write-Output "CHANGED: removed managed block from $file (backup: $backup)" } else { Remove-Item -LiteralPath $file -Force; Write-Output "CHANGED: removed managed block and empty target $file (backup: $backup)" }
    Invoke-UninstallStagedAssets
}
function Get-LatestBackup { $dir = Get-BackupDir; if (-not (Test-Path -LiteralPath $dir)) { return $null }; Get-ChildItem -LiteralPath $dir -Filter 'CLAUDE.md.*' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1 }
function Invoke-Restore {
    Ensure-WriteTarget; $backup = Get-LatestBackup; if ($null -eq $backup) { Fail "no backup found in $(Get-BackupDir)" }; $file = Get-TargetFile
    if ($DryRun) { Write-Output "DRY-RUN: restore $file from $($backup.FullName)"; return }; Confirm-Mutation "Restore $file from $($backup.FullName)?"; New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null; $current = Save-Backup $file
    if ($backup.Length -gt 0) { Copy-Item -LiteralPath $backup.FullName -Destination $file -Force; Write-Output "CHANGED: restored $file from $($backup.FullName) (backup: $current)" } else { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue; Write-Output "CHANGED: restored absent target from $backup (backup: $current)" }
}
function Get-Bytes([string]$File) { if (Test-Path -LiteralPath $File -PathType Leaf) { return [int64](Get-Item -LiteralPath $File).Length }; return [int64]0 }
function Invoke-BudgetReport {
    Require-Core; $coreBytes = Get-Bytes $CoreFile; $stateFile = Get-StateFile; $stateBytes = Get-Bytes $stateFile; $coreTokens = [math]::Ceiling($coreBytes / 4.0); $stateTokens = [math]::Ceiling($stateBytes / 4.0); $failed = $false
    $coreLabel = if ($coreTokens -le $CoreLimit) { 'PASS' } else { $failed = $true; 'FAIL' }; $stateLabel = if ($stateTokens -le $StateLimit) { 'PASS' } else { $failed = $true; 'FAIL' }
    Write-Output "$coreLabel`: core $CoreFile`: $coreBytes bytes, $coreTokens estimated tokens (limit: $CoreLimit)"; if (Test-Path -LiteralPath $stateFile) { Write-Output "$stateLabel`: state $stateFile`: $stateBytes bytes, $stateTokens estimated tokens (limit: $StateLimit)" } else { Write-Output "$stateLabel`: state $stateFile`: absent, 0 bytes, 0 estimated tokens (limit: $StateLimit)" }; $totalLabel = if ($failed) { 'FAIL' } else { 'PASS' }; Write-Output "$totalLabel`: total always-loaded surface: $($coreBytes + $stateBytes) bytes, $($coreTokens + $stateTokens) estimated tokens"; $script:BudgetPassed = -not $failed
}
function Get-InstalledProfile { $file = Get-InstalledFile; if (Test-Path -LiteralPath $file) { foreach ($line in Get-Content -LiteralPath $file) { if ($line.StartsWith("profile`t")) { return $line.Substring(8) } } }; return '' }
function Get-InstalledCount { $file = Get-InstalledFile; if (-not (Test-Path -LiteralPath $file)) { return 0 }; $count = 0; foreach ($line in Get-Content -LiteralPath $file) { $parts = $line -split "`t", 2; if ($parts.Count -eq 2 -and $parts[0] -notin @('version', 'profile') -and -not $parts[0].StartsWith('#')) { $count++ } }; return $count }
function Test-InstalledAssets {
    $file = Get-InstalledFile; if (-not (Test-Path -LiteralPath $file)) { Write-Output 'PASS: no staged assets are recorded'; $script:InstalledAssetsPassed = $true; return }; $failed = $false
    foreach ($line in Get-Content -LiteralPath $file) { $parts = $line -split "`t", 2; if ($parts.Count -ne 2 -or $parts[0] -in @('version', 'profile') -or $parts[0].StartsWith('#')) { continue }; $path = $parts[0]; $hash = $parts[1]
        if (-not (Test-SafeRelative $path)) { Write-Output "FAIL: unsafe staged path in installed manifest: $path"; $failed = $true } elseif (-not (Test-Path -LiteralPath (Join-Path $TargetDir $path) -PathType Leaf)) { Write-Output "FAIL: staged asset is missing: $path"; $failed = $true } elseif ((Get-FileSha256 (Join-Path $TargetDir $path)) -eq $hash) { Write-Output "PASS: staged asset matches: $path" } else { Write-Output "FAIL: staged asset was locally modified: $path"; $failed = $true }
    }; $script:InstalledAssetsPassed = -not $failed
}
function Invoke-Doctor {
    Ensure-ReadTarget; $failed = $false; Write-Output "PASS: target directory exists: $TargetDir"; $state = Get-BlockState
    if ($state -eq 'absent') { Write-Output 'WARN: managed block is absent'; Write-Output 'PASS: no orphaned ctk markers detected' } elseif ($state -eq 'orphan') { Write-Output 'FAIL: orphaned ctk markers detected'; $failed = $true } else { Write-Output 'PASS: one complete managed block is present'; Write-Output 'PASS: no orphaned ctk markers detected'; if ((Get-HeaderValue 'hash') -eq (Get-CoreHash)) { Write-Output "PASS: managed hash matches current core ($(Get-CoreHash))" } else { Write-Output "FAIL: managed hash drift (recorded: $(Get-HeaderValue 'hash'), current: $(Get-CoreHash))"; $failed = $true }; if (-not $ProfileSet) { $script:Profile = Get-HeaderValue 'profile' }; Test-Profile; Test-ProfileAssets; if (-not $ProfileAssetsPassed) { $failed = $true } }
    Test-InstalledAssets; if (-not $InstalledAssetsPassed) { $failed = $true }; Invoke-BudgetReport; if (-not $BudgetPassed) { $failed = $true }; $backup = Get-LatestBackup; if ($null -eq $backup) { Write-Output "WARN: no backups present in $(Get-BackupDir)" } else { Write-Output "PASS: backup present: $($backup.FullName)" }; if ($failed) { exit 1 }
}
function Invoke-StateRotate {
    $stateFile = Get-StateFile; if (-not (Test-Path -LiteralPath $stateFile)) { Write-Output "SKIP: state file is absent: $stateFile"; return }; if ((Get-Bytes $stateFile) -le ($StateLimit * 4)) { Write-Output "SKIP: state is within budget: $(Get-Bytes $stateFile) bytes"; return }; if ($DryRun) { Write-Output "DRY-RUN: rotate $stateFile to the $StateLimit-token budget"; return }
    $lines = [IO.File]::ReadAllLines($stateFile); $encoding = [Text.UTF8Encoding]::new($false); $used = 0; $first = $lines.Length; for ($i = $lines.Length - 1; $i -ge 0; $i--) { $size = $encoding.GetByteCount($lines[$i] + [Environment]::NewLine); if (($used + $size) -gt ($StateLimit * 4)) { break }; $used += $size; $first = $i }; $stateDir = Split-Path -Parent $stateFile; $archiveDir = Join-Path $stateDir 'archive'; New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null; if ($first -gt 0) { [IO.File]::AppendAllLines((Join-Path $archiveDir ('STATE-' + [DateTime]::UtcNow.ToString('yyyyMMdd') + '.md')), $lines[0..($first - 1)], $encoding) }; if ($first -ge $lines.Length) { [IO.File]::WriteAllText($stateFile, '', $encoding) } else { [IO.File]::WriteAllLines($stateFile, $lines[$first..($lines.Length - 1)], $encoding) }; Write-Output "CHANGED: rotated state into $archiveDir"
}
function Invoke-State {
    Ensure-WriteTarget; $stateFile = Get-StateFile
    switch ($StateAction) { 'show' { if (Test-Path -LiteralPath $stateFile) { Get-Content -LiteralPath $stateFile } else { Write-Output 'SKIP: state is absent' } }; 'add' { if ($DryRun) { Write-Output "DRY-RUN: add one state entry to $stateFile"; return }; Confirm-Mutation "Add state entry to ${stateFile}?"; New-Item -ItemType Directory -Force -Path (Split-Path -Parent $stateFile) | Out-Null; [IO.File]::AppendAllText($stateFile, ([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ') + ' ' + $StateText + [Environment]::NewLine), [Text.UTF8Encoding]::new($false)); Write-Output "CHANGED: added state entry to $stateFile"; Invoke-StateRotate }; 'rotate' { if (-not $DryRun) { Confirm-Mutation "Rotate bounded state in ${stateFile}?" }; Invoke-StateRotate } }
}

$argList = New-Object System.Collections.Generic.List[string]; if ($Arguments) { $argList.AddRange([string[]]$Arguments) }
if ($Command -eq 'state') { if ($argList.Count -eq 0) { Fail 'state requires show, add, or rotate' }; $StateAction = $argList[0]; $argList.RemoveAt(0); if ($StateAction -eq 'add') { if ($argList.Count -eq 0) { Fail 'state add requires one line of text' }; $StateText = $argList[0]; $argList.RemoveAt(0); if ($StateText -match "[`r`n]") { Fail 'state entries must be one line' } } elseif ($StateAction -notin @('show', 'rotate')) { Fail 'state requires show, add, or rotate' } }
for ($i = 0; $i -lt $argList.Count; $i++) { switch ($argList[$i]) { '--link' { $Mode = 'link'; $ModeSet = $true }; '--embed' { $Mode = 'embed'; $ModeSet = $true }; '--global' { $GlobalTarget = $true }; '--profile' { $i++; if ($i -ge $argList.Count) { Fail '--profile requires a value' }; $Profile = $argList[$i]; $ProfileSet = $true }; '--module' { $i++; if ($i -ge $argList.Count) { Fail '--module requires a value' }; if ([string]::IsNullOrWhiteSpace($argList[$i]) -or $argList[$i] -match '[\\/]' -or $argList[$i].Contains('..')) { Fail "invalid module name: $($argList[$i])" }; $RequestedModules.Add($argList[$i]) }; '--no-modules' { $ModulesDisabled = $true }; '--target' { $i++; if ($i -ge $argList.Count) { Fail '--target requires a directory' }; $TargetDir = $argList[$i] }; '--dry-run' { $DryRun = $true }; '--yes' { $AssumeYes = $true }; '--help' { $Command = 'help' }; '-h' { $Command = 'help' }; default { Fail "unknown option: $($argList[$i])" } } }
if ($GlobalTarget) { $TargetDir = Join-Path $HOME '.claude' }
switch ($Command) { 'install' { Invoke-Install }; 'update' { Invoke-Update }; 'uninstall' { Invoke-Uninstall }; 'restore' { Invoke-Restore }; 'status' { Ensure-ReadTarget; $state = Get-BlockState; Write-Output "Target: $(Get-TargetFile)"; if ($state -eq 'complete') { Write-Output "Managed block: present (profile: $(Get-HeaderValue 'profile'), mode: $(Get-BlockMode), hash: $(Get-HeaderValue 'hash'))" } else { Write-Output "Managed block: $state" }; $installedProfile = Get-InstalledProfile; if ($installedProfile) { Write-Output "Installed profile: $installedProfile" } elseif ($state -eq 'complete') { Write-Output "Installed profile: $(Get-HeaderValue 'profile')" } else { Write-Output 'Installed profile: none' }; Write-Output "Staged files: $(Get-InstalledCount)" }; 'doctor' { Invoke-Doctor }; 'budget' { Ensure-ReadTarget; Invoke-BudgetReport; if (-not $BudgetPassed) { exit 1 } }; 'state' { Invoke-State }; 'version' { Write-Output "ctk $Version" }; 'help' { Show-Usage }; default { Fail "unknown command: $Command (run 'ctk help')" } }
