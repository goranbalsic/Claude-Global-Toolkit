<#
.SYNOPSIS
    Install GLOBAL_CLAUDE.md into a target repository as CLAUDE.md.

.DESCRIPTION
    Additive-only installer for the Claude Global Toolkit baseline.
    - Creates directories without deleting unrelated files.
    - Detects an existing target CLAUDE.md and never overwrites it silently.
    - Creates a timestamped backup before any overwrite.
    - Shows a diff/proposal and requires explicit confirmation before writing,
      unless -Yes is passed (still an explicit, informed choice — not automatic).
    - Never installs packages or touches anything outside -TargetRepo.
    - Reports exactly what changed.

.PARAMETER TargetRepo
    Path to the repository that should receive the baseline CLAUDE.md.

.PARAMETER SourceFile
    Path to GLOBAL_CLAUDE.md to install. Defaults to the copy alongside this
    script (..\GLOBAL_CLAUDE.md).

.PARAMETER Yes
    Skip the interactive confirmation prompt. Still shows the proposal and
    still creates a backup before any overwrite. Use for scripted/CI-style
    invocations where the caller has already reviewed the proposal.

.EXAMPLE
    .\install.ps1 -TargetRepo "C:\path\to\other\repo"

.EXAMPLE
    .\install.ps1 -TargetRepo "C:\path\to\other\repo" -Yes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,

    [string]$SourceFile = (Join-Path $PSScriptRoot "..\GLOBAL_CLAUDE.md"),

    [switch]$Yes
)

$ErrorActionPreference = "Stop"

function Write-Report {
    param([string]$Message)
    Write-Output $Message
}

# --- Validate source ---
if (-not (Test-Path -LiteralPath $SourceFile -PathType Leaf)) {
    Write-Error "Source file not found: $SourceFile. Nothing was changed."
    exit 1
}
$SourceFile = (Resolve-Path -LiteralPath $SourceFile).ProviderPath

# --- Validate target ---
if (-not (Test-Path -LiteralPath $TargetRepo -PathType Container)) {
    Write-Error "Target repository directory does not exist: $TargetRepo. Nothing was changed. (This script creates files inside an existing repository directory; it does not create the repository itself.)"
    exit 1
}
$TargetRepo = (Resolve-Path -LiteralPath $TargetRepo).ProviderPath
$TargetFile = Join-Path $TargetRepo "CLAUDE.md"

# --- Build proposal ---
$sourceContent = Get-Content -LiteralPath $SourceFile -Raw
$targetExists = Test-Path -LiteralPath $TargetFile -PathType Leaf
$backupPath = $null

$sourceVersion = "Unknown"
$versionMatch = [regex]::Match($sourceContent, '(?m)^version:\s*(.+)\s*$')
if ($versionMatch.Success) {
    $sourceVersion = $versionMatch.Groups[1].Value.Trim()
}

Write-Report "Claude Global Toolkit installer"
Write-Report "  Source: $SourceFile (version $sourceVersion)"
Write-Report "  Target: $TargetFile"
Write-Report ""

if ($targetExists) {
    $existingContent = Get-Content -LiteralPath $TargetFile -Raw
    if ($existingContent -eq $sourceContent) {
        Write-Report "Target CLAUDE.md is already identical to the source. No change needed. Nothing was written."
        exit 0
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$TargetFile.bak.$timestamp"

    Write-Report "An existing CLAUDE.md was found at the target."
    Write-Report "It will be backed up to: $backupPath"
    Write-Report ""
    Write-Report "--- Diff (existing vs. proposed), context 3 lines ---"
    $existingLines = $existingContent -split "`r?`n"
    $sourceLines = $sourceContent -split "`r?`n"
    Compare-Object -ReferenceObject $existingLines -DifferenceObject $sourceLines |
        ForEach-Object {
            $marker = if ($_.SideIndicator -eq "=>") { "+" } else { "-" }
            Write-Report "$marker $($_.InputObject)"
        }
    Write-Report "--- End diff ---"
} else {
    Write-Report "No existing CLAUDE.md found at the target. This will create a new file; no backup needed."
}

Write-Report ""

# --- Confirm ---
if (-not $Yes) {
    $response = Read-Host "Proceed with writing $TargetFile ? [y/N]"
    if ($response -notmatch '^(y|Y|yes|Yes)$') {
        Write-Report "Aborted by user. Nothing was changed."
        exit 0
    }
}

# --- Backup (if needed), then write ---
if ($targetExists) {
    Copy-Item -LiteralPath $TargetFile -Destination $backupPath -Force
}
Copy-Item -LiteralPath $SourceFile -Destination $TargetFile -Force

# --- Report exactly what changed ---
Write-Report ""
Write-Report "Done."
if ($targetExists) {
    Write-Report "  Backed up previous CLAUDE.md to: $backupPath"
    Write-Report "  Overwrote: $TargetFile"
} else {
    Write-Report "  Created: $TargetFile"
}
Write-Report "  No packages were installed. No files outside the target repository were touched."
Write-Report "  Next step (manual, not performed by this script): review $TargetFile in the target repository and adopt the rest of the reusable structure from HOW_TO_USE.md if desired."
