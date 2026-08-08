# Requires -Version 5.1
# Global SessionStart router, registered once by `ctk.ps1 bootstrap` into
# %USERPROFILE%\.claude\settings.json. Runs on every Claude Code session, in
# every project, so it stays tiny and silent unless there is something to
# report.
#
# It never stages files itself and never duplicates install/update logic: for
# an already CTK-managed project it defers entirely to the tested
# `ctk.ps1 update --session-sync`. For a first-time project it only prints a
# one-line approval signal (or, if auto_apply_managed_ctk=true was explicitly
# set at bootstrap, runs the ordinary `ctk.ps1 install`) and never invents a
# second write path of its own.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status([string]$Text) { Write-Output $Text }

$homeBase = if ($env:CTK_HOME) { $env:CTK_HOME } else { $HOME }
if ([string]::IsNullOrWhiteSpace($homeBase)) { exit 0 }
$registration = Join-Path $homeBase '.claude\ctk\registration.txt'
if (-not (Test-Path -LiteralPath $registration -PathType Leaf)) { exit 0 }

$root = ''
$autoApply = ''
foreach ($line in Get-Content -LiteralPath $registration) {
    $parts = $line -split "`t", 2
    if ($parts.Count -ne 2) { continue }
    if ($parts[0] -eq 'root') { $root = $parts[1] }
    if ($parts[0] -eq 'auto_apply_managed_ctk') { $autoApply = $parts[1] }
}
if (-not $root) { exit 0 }

$ctkScript = Join-Path $root 'bin\ctk.ps1'
if (-not (Test-Path -LiteralPath $ctkScript -PathType Leaf) -or -not (Test-Path -LiteralPath (Join-Path $root 'core\CLAUDE.core.md') -PathType Leaf)) {
    Write-Status "CTK: registered checkout is missing or moved ($root); run bootstrap again once it is available."
    exit 0
}

$projectDir = $env:CLAUDE_PROJECT_DIR
if ([string]::IsNullOrWhiteSpace($projectDir)) { exit 0 }
if (-not (Test-Path -LiteralPath $projectDir -PathType Container)) { exit 0 }

function Get-DetectedProfile([string]$Root, [string]$ProjectDir) {
    $profile = 'standard'
    $modulesDir = Join-Path $Root 'modules'
    if (-not (Test-Path -LiteralPath $modulesDir -PathType Container)) { return $profile }
    foreach ($moduleDir in Get-ChildItem -LiteralPath $modulesDir -Directory) {
        $moduleFile = Join-Path $moduleDir.FullName 'module.md'
        if (-not (Test-Path -LiteralPath $moduleFile -PathType Leaf)) { continue }
        $match = Select-String -LiteralPath $moduleFile -Pattern '^detect:\s*(?:"(.+)"|(.+?))\s*$' | Select-Object -First 1
        if ($null -eq $match) { continue }
        $rule = if ($match.Matches[0].Groups[1].Value) { $match.Matches[0].Groups[1].Value } else { $match.Matches[0].Groups[2].Value }
        if ($rule -match '^(.+) contains (.+)$') {
            $ruleFile = Join-Path $ProjectDir $matches[1]
            if ((Test-Path -LiteralPath $ruleFile -PathType Leaf) -and (Select-String -LiteralPath $ruleFile -SimpleMatch $matches[2] -Quiet)) { $profile = 'full' }
        } elseif ($rule -match '^(.+) exists$') {
            if (Test-Path -LiteralPath (Join-Path $ProjectDir $matches[1])) { $profile = 'full' }
        }
    }
    return $profile
}

$claudeMd = Join-Path $projectDir 'CLAUDE.md'
$hasBlock = (Test-Path -LiteralPath $claudeMd -PathType Leaf) -and (Select-String -LiteralPath $claudeMd -Pattern '^<!-- ctk:begin v=' -Quiet)

if (-not $hasBlock) {
    # No managed block: only speak up for something that looks like a real,
    # git-tracked project. A random directory stays completely silent.
    if (-not (Test-Path -LiteralPath (Join-Path $projectDir '.git'))) { exit 0 }
    $profile = Get-DetectedProfile $root $projectDir
    if ($autoApply -eq 'true') {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $ctkScript install --profile $profile --target $projectDir --yes *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "CTK: installed ($profile profile) under auto_apply_managed_ctk; restart once to pick up new slash commands."
        } else {
            Write-Status "CTK: auto_apply install failed for this project; run 'ctk doctor --target $projectDir' to inspect."
        }
    } else {
        Write-Status "CTK: setup available for this project ($profile profile); approval required before CTK-managed files are added."
    }
    exit 0
}

$syncOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $ctkScript update --session-sync --target $projectDir --yes 2>&1
$syncCode = $LASTEXITCODE
switch ($syncCode) {
    0 { Write-Status (($syncOutput | Select-Object -Last 1) -join ' ') }
    11 { Write-Status 'CTK: locally modified managed file detected; sync skipped, nothing overwritten. Run "ctk doctor" for detail.' }
    12 { Write-Status 'CTK: unrecognized or legacy CTK state in this project; run "ctk doctor" then resolve manually.' }
    14 { Write-Status 'CTK: sync applied but the health check failed; a backup was preserved. Run "ctk doctor" to inspect.' }
    10 { Write-Status 'CTK: setup available for this project; approval required before CTK-managed files are added.' }
    default { Write-Status "CTK: session sync check failed (exit $syncCode); run 'ctk doctor --target $projectDir'." }
}
exit 0
