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

$Version = '3.3.0'
$CoreLimit = 1200
$StateLimit = 400
$GoalLimit = 300
$ManifestSchema = 1
$BootstrapSchema = 1
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
$SessionSync = $false
$BootstrapRoot = $null
$AutoApply = $false
$StateAction = $null
$StateText = $null
$GoalAction = $null
$GoalObjective = $null
$GoalAcceptance = $null
$GoalPhase = $null
$GoalNext = $null
$GoalEvidence = $null
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
  goal          goal set|show|pause|complete|cancel|clear
  bootstrap     Register this checkout, a global SessionStart router, and global /ctk:* slash commands, once per machine.
  disable       Remove the registration, router, and global commands installed by bootstrap.
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
  --session-sync            update: non-interactive safe sync, fails closed on conflict.
  --root DIR                bootstrap: register DIR instead of this script's own checkout.
  --auto-apply              bootstrap: record auto_apply_managed_ctk=true (opt-in).
  --objective TEXT          goal set: the objective (required).
  --acceptance TEXT         goal set: the acceptance check (required).
  --phase TEXT              goal set/pause: the current phase.
  --next TEXT               goal set: the next verifiable action.
  --evidence TEXT           goal complete: the test/build evidence (required).

Exit codes for 'update --session-sync':
  0  current, or safe synchronization completed
  10 first install needs in-chat approval; no write performed
  11 locally modified managed content; no write performed
  12 unknown/legacy/ambiguous state; no write performed
  14 post-sync health check failed; backup preserved
'@ | Write-Output
}

function Get-TargetFile { Join-Path $script:TargetDir 'CLAUDE.md' }
function Get-BackupDir { Join-Path $script:TargetDir '.ctk-backup' }
function Get-StateFile { Join-Path $script:TargetDir '.claude\ctk\STATE.md' }
function Get-InstalledFile { Join-Path $script:TargetDir '.claude\ctk\installed.txt' }
function Get-GoalFile { Join-Path $script:TargetDir '.claude\ctk\GOAL.md' }
function Require-Core { if (-not (Test-Path -LiteralPath $CoreFile -PathType Leaf)) { Fail "core file is missing: $CoreFile" } }
function Get-FileSha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-CoreHash { Require-Core; (Get-FileSha256 $CoreFile).Substring(0, 12) }
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
            if ($parts.Count -eq 2 -and $parts[0] -notin @('version', 'profile', 'schema') -and -not $parts[0].StartsWith('#')) { $script:StageRecords[$parts[0]] = $parts[1] }
        }
    }
}
function Write-InstalledManifest {
    $installed = Get-InstalledFile
    if ($StageRecords.Count -eq 0) { Remove-Item -LiteralPath $installed -Force -ErrorAction SilentlyContinue; return }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $installed) | Out-Null
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# ctk installed assets'); $lines.Add("schema`t$ManifestSchema"); $lines.Add("version`t$Version"); $lines.Add("profile`t$Profile")
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
    # STATE.md is live data `ctk goal`/`state add` own, not a template to
    # reset: once it exists at all, install/update must never overwrite it,
    # only record whatever it currently contains. Comparing it against the
    # pristine boilerplate hash here previously meant any accumulated
    # checkpoint history was silently wiped back to empty on every update.
    $relative = '.claude/ctk/STATE.md'; $destination = Get-StateFile
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { Fail "cannot stage state over non-file: $destination" }
        $StageRecords[$relative] = Get-FileSha256 $destination
        if ($DryRun) { Write-Output "DRY-RUN: SKIP: state file already present: $relative" } else { Write-Output "SKIP: state file already present: $relative" }
        return
    } else {
        if ($DryRun) { Write-Output "DRY-RUN: STAGE: @state -> $relative"; return }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        [IO.File]::WriteAllText($destination, "# ctk bounded session state$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))
        $StageRecords[$relative] = Get-FileSha256 $destination; Write-Output "CHANGED: staged $relative"
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
        if (Test-Path -LiteralPath (Join-Path $moduleDir 'skills') -PathType Container) { Stage-Directory (Join-Path $moduleDir 'skills') ".claude/skills/$module" }
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
# Reused by Invoke-SessionSync only: mirrors Test-InstalledAssets' hash check
# but stops and reports the first mismatch, since sync must fail closed before
# writing anything rather than enumerate every drift.
function Test-SessionSyncConflict {
    $installed = Get-InstalledFile
    foreach ($line in Get-Content -LiteralPath $installed) {
        $parts = $line -split "`t", 2
        if ($parts.Count -ne 2 -or $parts[0] -in @('version', 'profile', 'schema') -or $parts[0].StartsWith('#')) { continue }
        $path = $parts[0]; $hash = $parts[1]
        if ($path -eq '.claude/ctk/STATE.md') { continue }
        if (-not (Test-SafeRelative $path)) { return $path }
        $target = Join-Path $TargetDir $path
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { continue }
        if ((Get-FileSha256 $target) -ne $hash) { return $path }
    }
    return $null
}
# Non-interactive counterpart to Invoke-Update for an automated SessionStart
# router. Reuses Get-BlockState/New-Block/Save-Backup/Stage-SelectedProfile
# unchanged; the only new behavior is the conflict pre-flight and the
# machine-readable exit codes a router can act on without a console prompt.
# Global slash-command files are *copies* placed under $HOME\.claude by
# bootstrap, so updating the CTK checkout alone used to leave them stale --
# the exact failure mode behind the "--target requires a non-empty directory"
# crash, where a fixed template sat in the checkout while the old one still
# ran. Session sync refreshes CTK-owned global files in place whenever this
# checkout is the registered root and a file has drifted. Refresh only, never
# create: bootstrap still owns first installation and disable stays final.
$script:GlobalRefreshCount = 0
function Update-GlobalCommandsQuiet {
    $script:GlobalRefreshCount = 0
    $base = if ($env:CTK_HOME) { $env:CTK_HOME } else { $HOME }
    if ([string]::IsNullOrWhiteSpace($base)) { return }
    $ctkHome = Join-Path $base '.claude'
    $regFile = Join-Path $ctkHome 'ctk\registration.txt'
    if (-not (Test-Path -LiteralPath $regFile -PathType Leaf)) { return }
    $regRoot = $null
    foreach ($line in Get-Content -LiteralPath $regFile) {
        $parts = $line -split "`t", 2
        if ($parts.Count -eq 2 -and $parts[0] -eq 'root') { $regRoot = $parts[1]; break }
    }
    if ([string]::IsNullOrWhiteSpace($regRoot)) { return }
    # A checkout that is not the registered one must never rewrite the
    # machine's global commands behind the registered checkout's back.
    if (-not [string]::Equals(($regRoot.TrimEnd('\', '/')), ($RootDir.TrimEnd('\', '/')), [StringComparison]::OrdinalIgnoreCase)) { return }
    $pairs = @(@{ src = 'router\global-router.sh'; dst = 'ctk\global-router.sh' })
    foreach ($name in $GlobalCommandNames) {
        $pairs += @{ src = "global-commands\$name.md"; dst = "commands\ctk\$name.md" }
    }
    foreach ($pair in $pairs) {
        $src = Join-Path $RootDir $pair.src
        $dst = Join-Path $ctkHome $pair.dst
        if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { continue }
        if (-not (Test-Path -LiteralPath $dst -PathType Leaf)) { continue }
        if ((Get-FileSha256 $src) -eq (Get-FileSha256 $dst)) { continue }
        try {
            Save-HomeBackup $dst $ctkHome | Out-Null
            Copy-Item -LiteralPath $src -Destination $dst -Force
            $script:GlobalRefreshCount++
        } catch { continue }
    }
}
function Get-GlobalRefreshNote {
    if ($script:GlobalRefreshCount -gt 0) { return " Refreshed $($script:GlobalRefreshCount) global command file(s); restart Claude Code once to load them." }
    return ''
}
function Invoke-SessionSync {
    Update-GlobalCommandsQuiet
    Ensure-WriteTarget
    $state = Get-BlockState
    if ($state -eq 'absent') { Write-Output "CTK: no managed block present; first install requires approval.$(Get-GlobalRefreshNote)"; exit 10 }
    if ($state -eq 'orphan') { Write-Output "CTK: orphaned ctk markers in $(Get-TargetFile); run 'ctk doctor', then resolve manually."; exit 12 }
    Choose-ExistingSettings
    if (-not (Test-Path -LiteralPath (Get-InstalledFile) -PathType Leaf)) { Write-Output "CTK: managed block present with no install manifest; run 'ctk doctor' then 'ctk update --yes' manually once to establish one."; exit 12 }
    $conflict = Test-SessionSyncConflict
    if ($null -ne $conflict) { Write-Output "CTK: locally modified managed file detected ($conflict); sync skipped, nothing overwritten."; exit 11 }
    if ((Get-HeaderValue 'hash') -eq (Get-CoreHash) -and (Get-InstalledVersion) -eq $Version) { Write-Output "CTK: current ($Version, $(Get-InstalledProfile) profile).$(Get-GlobalRefreshNote)"; exit 0 }
    $file = Get-TargetFile
    $existingSep = (Get-HeaderValue 'sep') -eq '1'
    $backup = Save-Backup $file
    $old = [IO.File]::ReadAllText($file)
    $new = [regex]::Replace($old, '(?ms)^<!-- ctk:begin v=.*?^<!-- ctk:end -->\r?\n?', (New-Block $existingSep), 1)
    Write-TargetText $new
    Stage-SelectedProfile
    $healthOk = ((Get-HeaderValue 'hash') -eq (Get-CoreHash))
    Invoke-BudgetReport | Out-Null
    if (-not $BudgetPassed) { $healthOk = $false }
    if (-not $healthOk) { Write-Output "CTK: sync applied but health check failed; backup at $backup. Run 'ctk doctor' to inspect."; exit 14 }
    Write-Output "CTK: updated to $Version ($(Get-InstalledProfile) profile); project state healthy.$(Get-GlobalRefreshNote)"
    exit 0
}
function Remove-EmptyParents([string]$Path) { $parent = Split-Path -Parent $Path; while ($parent -and -not [string]::Equals($parent, $TargetDir, [StringComparison]::OrdinalIgnoreCase)) { try { Remove-Item -LiteralPath $parent -Force -ErrorAction Stop } catch { break }; $parent = Split-Path -Parent $parent } }
function Invoke-UninstallStagedAssets {
    $installed = Get-InstalledFile; if (-not (Test-Path -LiteralPath $installed -PathType Leaf)) { return }
    $kept = New-Object System.Collections.Generic.List[string]
    foreach ($line in Get-Content -LiteralPath $installed) {
        $parts = $line -split "`t", 2; if ($parts.Count -ne 2 -or $parts[0] -in @('version', 'profile', 'schema') -or $parts[0].StartsWith('#')) { continue }
        $path = $parts[0]; $hash = $parts[1]; if (-not (Test-SafeRelative $path)) { Fail "unsafe staged path in installed manifest: $path" }; $target = Join-Path $TargetDir $path
        if (-not (Test-Path -LiteralPath $target)) { Write-Output "SKIP: staged file already absent: $path" }
        elseif (-not (Test-Path -LiteralPath $target -PathType Leaf)) { Write-Output "KEPT: staged path is no longer a file: $path"; $kept.Add("$path`t$hash") }
        elseif ((Get-FileSha256 $target) -eq $hash) { if ($DryRun) { Write-Output "DRY-RUN: REMOVE: $path" } else { Remove-Item -LiteralPath $target -Force; Remove-EmptyParents $target; Write-Output "CHANGED: removed staged file: $path" } }
        else { Write-Output "KEPT: locally modified staged file: $path"; $kept.Add("$path`t$hash") }
    }
    if ($DryRun) { return }
    if ($kept.Count -eq 0) { Remove-Item -LiteralPath $installed -Force; Remove-EmptyParents $installed } else { $lines = @('# ctk installed assets', "schema`t$ManifestSchema", "version`t$Version", "profile`t$Profile") + @($kept); [IO.File]::WriteAllLines($installed, [string[]]$lines, [Text.UTF8Encoding]::new($false)) }
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
function Get-InstalledVersion { $file = Get-InstalledFile; if (Test-Path -LiteralPath $file) { foreach ($line in Get-Content -LiteralPath $file) { if ($line.StartsWith("version`t")) { return $line.Substring(8) } } }; return '' }
function Get-InstalledSchema { $file = Get-InstalledFile; if (Test-Path -LiteralPath $file) { foreach ($line in Get-Content -LiteralPath $file) { if ($line.StartsWith("schema`t")) { return $line.Substring(7) } } }; return '' }
function Get-InstalledCount { $file = Get-InstalledFile; if (-not (Test-Path -LiteralPath $file)) { return 0 }; $count = 0; foreach ($line in Get-Content -LiteralPath $file) { $parts = $line -split "`t", 2; if ($parts.Count -eq 2 -and $parts[0] -notin @('version', 'profile', 'schema') -and -not $parts[0].StartsWith('#')) { $count++ } }; return $count }
function Test-InstalledAssets {
    $file = Get-InstalledFile; if (-not (Test-Path -LiteralPath $file)) { Write-Output 'PASS: no staged assets are recorded'; $script:InstalledAssetsPassed = $true; return }; $failed = $false
    if (-not (Get-InstalledSchema)) { Write-Output "WARN: installed manifest predates schema versioning (run 'ctk update' to migrate)" }
    foreach ($line in Get-Content -LiteralPath $file) { $parts = $line -split "`t", 2; if ($parts.Count -ne 2 -or $parts[0] -in @('version', 'profile', 'schema') -or $parts[0].StartsWith('#')) { continue }; $path = $parts[0]; $hash = $parts[1]
        if (-not (Test-SafeRelative $path)) { Write-Output "FAIL: unsafe staged path in installed manifest: $path"; $failed = $true } elseif (-not (Test-Path -LiteralPath (Join-Path $TargetDir $path) -PathType Leaf)) { Write-Output "FAIL: staged asset is missing: $path"; $failed = $true } elseif ($path -eq '.claude/ctk/STATE.md') { Write-Output "PASS: state file present: $path" } elseif ((Get-FileSha256 (Join-Path $TargetDir $path)) -eq $hash) { Write-Output "PASS: staged asset matches: $path" } else { Write-Output "FAIL: staged asset was locally modified: $path"; $failed = $true }
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
function Get-GoalField([string]$Key) {
    $file = Get-GoalFile; if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return '' }
    $prefix = $Key + ': '
    foreach ($line in Get-Content -LiteralPath $file) { if ($line.StartsWith($prefix)) { return $line.Substring($prefix.Length) } }
    return ''
}
# A goal record is a data file only: it is never wired into hooks/session-start.sh
# or ctk budget, and it never triggers unattended follow-on action.
function New-GoalContent([string]$Status, [string]$Objective, [string]$Acceptance, [string]$Phase, [string]$Next, [string]$Evidence) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("objective: $Objective"); $lines.Add("acceptance: $Acceptance"); $lines.Add("phase: $Phase"); $lines.Add("next_action: $Next"); $lines.Add("status: $Status")
    if ($Evidence) { $lines.Add("evidence: $Evidence") }
    $lines.Add("updated: $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))")
    return ($lines -join [Environment]::NewLine)
}
function Write-Goal([string]$Status, [string]$Objective, [string]$Acceptance, [string]$Phase, [string]$Next, [string]$Evidence, [string]$Prompt, [string]$Verb) {
    $goalFile = Get-GoalFile
    $content = New-GoalContent $Status $Objective $Acceptance $Phase $Next $Evidence
    $bytes = [Text.UTF8Encoding]::new($false).GetByteCount($content + [Environment]::NewLine)
    $limitBytes = $GoalLimit * 4
    if ($bytes -gt $limitBytes) { Fail "goal is too large: $bytes bytes (limit: $limitBytes bytes / $GoalLimit estimated tokens); shorten the goal text" }
    if ($DryRun) { Write-Output "DRY-RUN: $Verb $goalFile"; return }
    Confirm-Mutation $Prompt
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $goalFile) | Out-Null
    [IO.File]::WriteAllText($goalFile, $content + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
    Write-Output "CHANGED: $Verb $goalFile"
}
function Invoke-Goal {
    Ensure-WriteTarget; $goalFile = Get-GoalFile
    switch ($GoalAction) {
        'show' { if (Test-Path -LiteralPath $goalFile -PathType Leaf) { Get-Content -LiteralPath $goalFile } else { Write-Output 'SKIP: no active goal' } }
        'set' {
            if (-not $GoalObjective) { Fail 'goal set requires --objective' }
            if (-not $GoalAcceptance) { Fail 'goal set requires --acceptance' }
            $phase = if ($GoalPhase) { $GoalPhase } else { 'not started' }
            Write-Goal 'active' $GoalObjective $GoalAcceptance $phase $GoalNext '' "Set active goal in ${goalFile}?" 'wrote active goal to'
        }
        { $_ -in @('pause', 'cancel') } {
            if (-not (Test-Path -LiteralPath $goalFile -PathType Leaf)) { Fail "no active goal to update: $goalFile" }
            $newStatus = if ($GoalAction -eq 'pause') { 'paused' } else { 'cancelled' }
            Write-Goal $newStatus (Get-GoalField 'objective') (Get-GoalField 'acceptance') (Get-GoalField 'phase') (Get-GoalField 'next_action') '' "Set goal status to $newStatus in ${goalFile}?" "updated goal status to $newStatus in"
        }
        'complete' {
            if (-not (Test-Path -LiteralPath $goalFile -PathType Leaf)) { Fail "no active goal to complete: $goalFile" }
            if (-not $GoalEvidence) { Fail 'goal complete requires --evidence (record test/build proof, not a time or token budget)' }
            Write-Goal 'completed' (Get-GoalField 'objective') (Get-GoalField 'acceptance') (Get-GoalField 'phase') (Get-GoalField 'next_action') $GoalEvidence "Mark goal complete in ${goalFile}?" 'marked goal complete in'
        }
        'clear' {
            if (-not (Test-Path -LiteralPath $goalFile -PathType Leaf)) { Write-Output 'SKIP: no active goal to clear'; return }
            if ($DryRun) { Write-Output "DRY-RUN: remove $goalFile"; return }
            Confirm-Mutation "Clear active goal ${goalFile}?"
            Remove-Item -LiteralPath $goalFile -Force
            Write-Output "CHANGED: cleared goal $goalFile"
        }
    }
}

# --- machine-level bootstrap/disable (registers a global SessionStart router; ---
# --- never writes to a project directory, never uses TargetDir/--target).    ---
function Get-CtkHomeDir {
    $base = if ($env:CTK_HOME) { $env:CTK_HOME } else { $HOME }
    if ([string]::IsNullOrWhiteSpace($base)) { Fail 'HOME is not set; set an env:CTK_HOME override or a user profile' }
    return (Join-Path $base '.claude')
}
# A tiny home-scoped counterpart to Save-Backup, which is hard-wired to
# TargetDir. Bootstrap/disable touch $HOME/.claude, not a project, so they get
# their own timestamped backup under the same directory they mutate.
function Save-HomeBackup([string]$Source, [string]$HomeRoot) {
    $backupDir = Join-Path $HomeRoot '.ctk-backup'
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    $name = Split-Path -Leaf $Source
    $backup = Join-Path $backupDir ($name + '.' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ'))
    $n = 1
    while (Test-Path -LiteralPath $backup) { $backup = Join-Path $backupDir ($name + '.' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ') + '-' + $n); $n++ }
    Copy-Item -LiteralPath $Source -Destination $backup
    return $backup
}
function Test-CtkRoot([string]$Candidate) {
    if (-not (Test-Path -LiteralPath (Join-Path $Candidate 'bin\ctk.ps1') -PathType Leaf)) { Fail "not a CTK checkout (missing bin\ctk.ps1): $Candidate" }
    if (-not (Test-Path -LiteralPath (Join-Path $Candidate 'core\CLAUDE.core.md') -PathType Leaf)) { Fail "not a CTK checkout (missing core\CLAUDE.core.md): $Candidate" }
    $router = Join-Path $Candidate 'router\session-sync-router.ps1'
    if (-not (Test-Path -LiteralPath $router -PathType Leaf)) { Fail "CTK checkout is missing the session-sync router: $router" }
    $globalRouter = Join-Path $Candidate 'router\global-router.sh'
    if (-not (Test-Path -LiteralPath $globalRouter -PathType Leaf)) { Fail "CTK checkout is missing the global command router: $globalRouter" }
    $globalCommands = Join-Path $Candidate 'global-commands'
    if (-not (Test-Path -LiteralPath $globalCommands -PathType Container)) { Fail "CTK checkout is missing global command templates: $globalCommands" }
}
# Global Claude Code slash-command source of truth: bootstrap copies these
# files, byte for byte, out of the registered checkout into
# $ctkHome\commands\ctk\ and $ctkHome\ctk\global-router.sh. Disable removes
# exactly this named set and nothing a user may have placed alongside them.
$GlobalCommandNames = @('install', 'update', 'doctor', 'status', 'resume', 'checkpoint', 'goal', 'refine')
# A tiny home-scoped counterpart to Stage-File, which is hard-wired to
# TargetDir/Save-Backup. Global command/router files live under $ctkHome,
# not a project, so they get their own backup-on-change via Save-HomeBackup.
function Stage-HomeFile([string]$Source, [string]$RelativeDestination, [string]$HomeRoot) {
    $destination = Join-Path $HomeRoot $RelativeDestination
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { Fail "cannot stage global file over non-file: $destination" }
        if ((Get-FileSha256 $Source) -eq (Get-FileSha256 $destination)) { Write-Output "SKIP: identical global file: $RelativeDestination"; return }
        $backup = Save-HomeBackup $destination $HomeRoot
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $Source -Destination $destination -Force
        Write-Output "CHANGED: installed global file: $RelativeDestination (backup: $backup)"
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $Source -Destination $destination
        Write-Output "CHANGED: installed global file: $RelativeDestination"
    }
}
function Install-GlobalCommands([string]$BootRoot, [string]$CtkHome) {
    New-Item -ItemType Directory -Force -Path (Join-Path $CtkHome 'commands\ctk') | Out-Null
    Stage-HomeFile (Join-Path $BootRoot 'router\global-router.sh') 'ctk\global-router.sh' $CtkHome
    $installedList = @()
    foreach ($name in $GlobalCommandNames) {
        Stage-HomeFile (Join-Path $BootRoot "global-commands\$name.md") "commands\ctk\$name.md" $CtkHome
        $installedList += "/ctk:$name"
    }
    Write-Output "Global commands available (after one Claude Code restart): $($installedList -join ' ')"
}
function Remove-GlobalCommands([string]$CtkHome) {
    $removed = $false
    $routerFile = Join-Path $CtkHome 'ctk\global-router.sh'
    if (Test-Path -LiteralPath $routerFile -PathType Leaf) { Remove-Item -LiteralPath $routerFile -Force; Write-Output "CHANGED: removed $routerFile"; $removed = $true }
    $commandsDir = Join-Path $CtkHome 'commands\ctk'
    foreach ($name in $GlobalCommandNames) {
        $cmdFile = Join-Path $commandsDir "$name.md"
        if (Test-Path -LiteralPath $cmdFile -PathType Leaf) { Remove-Item -LiteralPath $cmdFile -Force; Write-Output "CHANGED: removed $cmdFile"; $removed = $true }
    }
    if (Test-Path -LiteralPath $commandsDir -PathType Container) {
        # Only removes the directory when empty, so a user file dropped
        # alongside the CTK-owned ones is left in place and the directory survives.
        if (@(Get-ChildItem -LiteralPath $commandsDir -Force).Count -eq 0) { Remove-Item -LiteralPath $commandsDir -Force }
    }
    if (-not $removed) { Write-Output "SKIP: no CTK global commands found under $commandsDir" }
}
# Set-StrictMode -Version Latest throws on member-enumeration (bare `.Name`)
# over a collection that turns out to be empty, and on accessing a property
# that a dynamically-parsed PSCustomObject (arbitrary user JSON) may not have.
# These two helpers are the strict-mode-safe replacement for both patterns;
# every property access below on parsed JSON goes through them.
function Test-HasProperty($Obj, [string]$Name) {
    if ($null -eq $Obj) { return $false }
    return [bool]($Obj.PSObject.Properties | Where-Object { $_.Name -eq $Name })
}
function Get-PropertyOrDefault($Obj, [string]$Name, $Default) {
    if (Test-HasProperty $Obj $Name) { return $Obj.$Name }
    return $Default
}
# PowerShell 5.1+ ships ConvertFrom-Json/ConvertTo-Json, so unlike the POSIX
# CLI (which only has jq optionally), settings.json can always be parsed and
# rewritten safely here rather than needing a jq-or-fail-safe fallback.
function Get-SettingsObject([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $raw = [IO.File]::ReadAllText($Path)
        if ([string]::IsNullOrWhiteSpace($raw)) { return [PSCustomObject]@{} }
        try { return ($raw | ConvertFrom-Json) } catch { Fail "existing settings file is not valid JSON: $Path" }
    }
    return [PSCustomObject]@{}
}
function Save-SettingsObject([string]$Path, $Object) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    # -Depth 20: the default depth of 2 silently truncates nested hook
    # structures, which would corrupt anything but the simplest settings file.
    $json = $Object | ConvertTo-Json -Depth 20
    [IO.File]::WriteAllText($Path, $json, [Text.UTF8Encoding]::new($false))
}
function Test-SessionStartEntryMatchesRouter($Entry) {
    $entryHooks = Get-PropertyOrDefault $Entry 'hooks' @()
    return [bool](@($entryHooks) | Where-Object { (Get-PropertyOrDefault $_ 'command' '') -like '*session-sync-router*' })
}
function Merge-SettingsHook([string]$SettingsFile, [string]$CommandStr) {
    $settings = Get-SettingsObject $SettingsFile
    if (-not (Test-HasProperty $settings 'hooks')) { $settings | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }
    $hooks = $settings.hooks
    $existingStart = Get-PropertyOrDefault $hooks 'SessionStart' @()
    $filtered = @($existingStart) | Where-Object { -not (Test-SessionStartEntryMatchesRouter $_) }
    $newEntry = [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = 'command'; command = $CommandStr }) }
    $merged = @($filtered) + @($newEntry)
    if (Test-HasProperty $hooks 'SessionStart') { $hooks.SessionStart = $merged } else { $hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue $merged }
    Save-SettingsObject $SettingsFile $settings
}
function Remove-SettingsHook([string]$SettingsFile) {
    if (-not (Test-Path -LiteralPath $SettingsFile -PathType Leaf)) { return }
    $settings = Get-SettingsObject $SettingsFile
    if (-not (Test-HasProperty $settings 'hooks')) { return }
    $hooks = $settings.hooks
    if (-not (Test-HasProperty $hooks 'SessionStart')) { return }
    # The @() around the whole pipeline is required, not decorative: a
    # Where-Object result with exactly one match unwraps to a bare object,
    # and ConvertTo-Json would then serialize SessionStart as an object
    # instead of a single-element array, silently changing its JSON shape.
    $hooks.SessionStart = @(@($hooks.SessionStart) | Where-Object { -not (Test-SessionStartEntryMatchesRouter $_) })
    Save-SettingsObject $SettingsFile $settings
}
function Invoke-Bootstrap {
    $bootRoot = if ($BootstrapRoot) { $BootstrapRoot } else { $RootDir }
    if (-not (Test-Path -LiteralPath $bootRoot -PathType Container)) { Fail "--root is not a directory: $bootRoot" }
    $bootRoot = (Resolve-Path -LiteralPath $bootRoot).Path
    Test-CtkRoot $bootRoot
    $routerScript = Join-Path $bootRoot 'router\session-sync-router.ps1'
    $routerCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$routerScript`""
    $ctkHome = Get-CtkHomeDir
    $regFile = Join-Path $ctkHome 'ctk\registration.txt'
    $settingsFile = Join-Path $ctkHome 'settings.json'
    if ($DryRun) { Write-Output "DRY-RUN: register CTK root $bootRoot in $regFile"; Write-Output "DRY-RUN: install SessionStart router in $settingsFile"; Write-Output "DRY-RUN: install global commands in $(Join-Path $ctkHome 'commands\ctk')\ ($($GlobalCommandNames -join ' '))"; return }
    Confirm-Mutation "Register CTK root $bootRoot and install the global SessionStart router?"
    New-Item -ItemType Directory -Force -Path (Join-Path $ctkHome 'ctk') | Out-Null
    $regBackup = $null
    if (Test-Path -LiteralPath $regFile -PathType Leaf) { $regBackup = Save-HomeBackup $regFile $ctkHome }
    $settingsBackup = $null
    if (Test-Path -LiteralPath $settingsFile -PathType Leaf) { $settingsBackup = Save-HomeBackup $settingsFile $ctkHome }
    Merge-SettingsHook $settingsFile $routerCommand
    $lines = @(
        '# ctk machine registration',
        "schema`t$BootstrapSchema",
        "root`t$bootRoot",
        "version`t$Version",
        "auto_apply_managed_ctk`t$($AutoApply.ToString().ToLowerInvariant())",
        "registered`t$([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    )
    [IO.File]::WriteAllLines($regFile, [string[]]$lines, [Text.UTF8Encoding]::new($false))
    if ($regBackup) { Write-Output "CHANGED: registered CTK root $bootRoot in $regFile (backup: $regBackup)" } else { Write-Output "CHANGED: registered CTK root $bootRoot in $regFile" }
    if ($settingsBackup) { Write-Output "CHANGED: installed global SessionStart router in $settingsFile (backup: $settingsBackup)" } else { Write-Output "CHANGED: installed global SessionStart router in $settingsFile" }
    Install-GlobalCommands $bootRoot $ctkHome
    Write-Output 'Setup complete. Restart Claude Code once to use the /ctk:* commands and automatic project sync in any project.'
}
function Invoke-Disable {
    $ctkHome = Get-CtkHomeDir
    $regFile = Join-Path $ctkHome 'ctk\registration.txt'
    $settingsFile = Join-Path $ctkHome 'settings.json'
    if ($DryRun) { Write-Output "DRY-RUN: remove CTK registration $regFile"; Write-Output "DRY-RUN: remove CTK SessionStart router from $settingsFile"; Write-Output "DRY-RUN: remove CTK global commands from $(Join-Path $ctkHome 'commands\ctk')\ and $(Join-Path $ctkHome 'ctk\global-router.sh')"; return }
    Confirm-Mutation 'Disable CTK global session sync (remove machine registration, router hook, and global commands)?'
    $hasHook = (Test-Path -LiteralPath $settingsFile -PathType Leaf) -and (Select-String -LiteralPath $settingsFile -Pattern 'session-sync-router' -Quiet)
    if ((Test-Path -LiteralPath $settingsFile -PathType Leaf) -and -not $hasHook) {
        Write-Output "SKIP: no CTK router hook found in $settingsFile"
    } elseif (Test-Path -LiteralPath $settingsFile -PathType Leaf) {
        $settingsBackup = Save-HomeBackup $settingsFile $ctkHome
        Remove-SettingsHook $settingsFile
        Write-Output "CHANGED: removed CTK SessionStart router from $settingsFile (backup: $settingsBackup)"
    } else {
        Write-Output "SKIP: no settings file at $settingsFile"
    }
    if (Test-Path -LiteralPath $regFile -PathType Leaf) {
        Remove-Item -LiteralPath $regFile -Force
        Write-Output "CHANGED: removed CTK registration $regFile"
    } else {
        Write-Output "SKIP: no CTK registration found at $regFile"
    }
    Remove-GlobalCommands $ctkHome
}

$argList = New-Object System.Collections.Generic.List[string]; if ($Arguments) { $argList.AddRange([string[]]$Arguments) }
if ($Command -eq 'state') { if ($argList.Count -eq 0) { Fail 'state requires show, add, or rotate' }; $StateAction = $argList[0]; $argList.RemoveAt(0); if ($StateAction -eq 'add') { if ($argList.Count -eq 0) { Fail 'state add requires one line of text' }; $StateText = $argList[0]; $argList.RemoveAt(0); if ($StateText -match "[`r`n]") { Fail 'state entries must be one line' } } elseif ($StateAction -notin @('show', 'rotate')) { Fail 'state requires show, add, or rotate' } }
if ($Command -eq 'goal') { if ($argList.Count -eq 0) { Fail 'goal requires set, show, pause, complete, cancel, or clear' }; $GoalAction = $argList[0]; $argList.RemoveAt(0); if ($GoalAction -notin @('set', 'show', 'pause', 'complete', 'cancel', 'clear')) { Fail 'goal requires set, show, pause, complete, cancel, or clear' } }
function Test-OneLine([string]$Name, [string]$Value) { if ($Value -match "[`r`n]") { Fail "$Name must be one line" } }
for ($i = 0; $i -lt $argList.Count; $i++) { switch ($argList[$i]) { '--link' { $Mode = 'link'; $ModeSet = $true }; '--embed' { $Mode = 'embed'; $ModeSet = $true }; '--global' { $GlobalTarget = $true }; '--profile' { $i++; if ($i -ge $argList.Count) { Fail '--profile requires a value' }; $Profile = $argList[$i]; $ProfileSet = $true }; '--module' { $i++; if ($i -ge $argList.Count) { Fail '--module requires a value' }; if ([string]::IsNullOrWhiteSpace($argList[$i]) -or $argList[$i] -match '[\\/]' -or $argList[$i].Contains('..')) { Fail "invalid module name: $($argList[$i])" }; $RequestedModules.Add($argList[$i]) }; '--no-modules' { $ModulesDisabled = $true }; '--session-sync' { $SessionSync = $true }; '--root' { $i++; if ($i -ge $argList.Count) { Fail '--root requires a directory' }; if ([string]::IsNullOrWhiteSpace($argList[$i])) { Fail '--root requires a non-empty directory' }; $BootstrapRoot = $argList[$i] }; '--auto-apply' { $AutoApply = $true }; '--target' { $i++; if ($i -ge $argList.Count) { Fail '--target requires a directory' }; if ([string]::IsNullOrWhiteSpace($argList[$i])) { Fail '--target requires a non-empty directory' }; $TargetDir = $argList[$i] }; '--dry-run' { $DryRun = $true }; '--yes' { $AssumeYes = $true }; '--objective' { $i++; if ($i -ge $argList.Count) { Fail '--objective requires a value' }; Test-OneLine '--objective' $argList[$i]; $GoalObjective = $argList[$i] }; '--acceptance' { $i++; if ($i -ge $argList.Count) { Fail '--acceptance requires a value' }; Test-OneLine '--acceptance' $argList[$i]; $GoalAcceptance = $argList[$i] }; '--phase' { $i++; if ($i -ge $argList.Count) { Fail '--phase requires a value' }; Test-OneLine '--phase' $argList[$i]; $GoalPhase = $argList[$i] }; '--next' { $i++; if ($i -ge $argList.Count) { Fail '--next requires a value' }; Test-OneLine '--next' $argList[$i]; $GoalNext = $argList[$i] }; '--evidence' { $i++; if ($i -ge $argList.Count) { Fail '--evidence requires a value' }; Test-OneLine '--evidence' $argList[$i]; $GoalEvidence = $argList[$i] }; '--help' { $Command = 'help' }; '-h' { $Command = 'help' }; default { Fail "unknown option: $($argList[$i])" } } }
if ($GlobalTarget) { $TargetDir = Join-Path $HOME '.claude' }
# A caller that passes a forward-slash path (e.g. a POSIX shell invoking this
# script through `powershell -File`, which is exactly how the global /ctk:*
# command router does it) leaves $TargetDir with forward slashes while
# Join-Path (used throughout for derived paths like Get-TargetFile) always
# normalizes to backslash. Save-Backup's prefix check then compares a
# forward-slash prefix against a backslash path and fails closed on every
# write. Normalizing once here, before any derived path is built, keeps the
# rest of the script's separator-sensitive string comparisons correct
# regardless of which slash style the caller used.
$TargetDir = $TargetDir.Replace('/', '\')
switch ($Command) { 'install' { Invoke-Install }; 'update' { if ($SessionSync) { Invoke-SessionSync } else { Invoke-Update } }; 'uninstall' { Invoke-Uninstall }; 'restore' { Invoke-Restore }; 'status' { Ensure-ReadTarget; $state = Get-BlockState; Write-Output "Target: $(Get-TargetFile)"; if ($state -eq 'complete') { Write-Output "Managed block: present (profile: $(Get-HeaderValue 'profile'), mode: $(Get-BlockMode), hash: $(Get-HeaderValue 'hash'))" } else { Write-Output "Managed block: $state" }; $installedProfile = Get-InstalledProfile; if ($installedProfile) { Write-Output "Installed profile: $installedProfile" } elseif ($state -eq 'complete') { Write-Output "Installed profile: $(Get-HeaderValue 'profile')" } else { Write-Output 'Installed profile: none' }; Write-Output "Staged files: $(Get-InstalledCount)" }; 'doctor' { Invoke-Doctor }; 'budget' { Ensure-ReadTarget; Invoke-BudgetReport; if (-not $BudgetPassed) { exit 1 } }; 'state' { Invoke-State }; 'goal' { Invoke-Goal }; 'bootstrap' { Invoke-Bootstrap }; 'disable' { Invoke-Disable }; 'version' { Write-Output "ctk $Version" }; 'help' { Show-Usage }; default { Fail "unknown command: $Command (run 'ctk help')" } }
