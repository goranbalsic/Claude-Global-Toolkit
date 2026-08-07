<#
.SYNOPSIS
    Mechanical repository health check for the Claude Global Toolkit.

.DESCRIPTION
    Read-only. Runs a fixed set of mechanical checks per
    chapters/05-repository-health-check.md and reports pass/fail/skip for
    each, plus a final summary. Never modifies any file. Does not authorize
    corrective changes on its own — findings still need review and, for
    anything beyond this repository, approval per PROJECT_CONSTITUTION.md.

    Checks:
      1. Required root files present.
      2. README.md's structure table matches the actual top-level tree
         (no missing, no untracked extras).
      3. Frontmatter version/last_reviewed consistent across CLAUDE.md,
         GLOBAL_CLAUDE.md, PROJECT_CONSTITUTION.md, and README.md's plain-
         text "Toolkit version" line.
      4. No empty or near-empty files under chapters/, prompts/, templates/,
         checklists/, reviews/, summaries/, session_logs/ (a heuristic:
         fewer than 3 non-blank lines).
      5. Internal Markdown cross-references (backtick-quoted repo-relative
         paths ending in .md, and standard [text](path.md) links) resolve
         to real files. Best-effort: external URLs, absolute paths outside
         this repository, and template placeholders (e.g. "YYYY-MM-DD",
         "<...>") are skipped, not flagged, since they are not meant to
         resolve. See "Known limitations" below.

.PARAMETER RepoRoot
    Path to the repository root. Defaults to this script's parent directory.

.EXAMPLE
    .\scripts\health-check.ps1

.NOTES
    Known limitations (documented per this toolkit's own "do not fake
    automation" rule): the cross-reference check is a best-effort regex
    scan, not a full Markdown parser — it can miss references embedded in
    unusual formatting, and its placeholder/external-link filters are
    heuristic. Treat a clean run as "no obvious breakage found," not as a
    substitute for the judgment-level review in
    reviews/PRINCIPAL_ENGINEER_REVIEW.md.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot ".."))
)

$ErrorActionPreference = "Stop"
$script:FailCount = 0
$script:PassCount = 0
$script:SkipCount = 0

function Write-Result {
    param([string]$Name, [ValidateSet("PASS","FAIL","SKIP")][string]$Status, [string]$Detail = "")
    $line = "[{0}] {1}" -f $Status, $Name
    if ($Detail) { $line += " - $Detail" }
    Write-Output $line
    switch ($Status) {
        "PASS" { $script:PassCount++ }
        "FAIL" { $script:FailCount++ }
        "SKIP" { $script:SkipCount++ }
    }
}

Write-Output "Claude Global Toolkit health check"
Write-Output "  Repo root: $RepoRoot"
Write-Output ""

# --- Check 1: required root files present ---
Write-Output "-- Check 1: required root files --"
$requiredRootFiles = @(
    "README.md","GLOBAL_CLAUDE.md","CLAUDE.md","PROJECT_CONSTITUTION.md",
    "PROJECT_CONTEXT.md","PROJECT_RULES.md","DECISIONS.md","PROMPTS.md",
    "IDEAS.md","OPEN_QUESTIONS.md","SOURCE_REGISTER.md","PROJECT_STATUS.md",
    "ROADMAP.md","CHANGELOG.md","HOW_TO_USE.md","HOW_TO_BUILD.md"
)
foreach ($f in $requiredRootFiles) {
    $p = Join-Path $RepoRoot $f
    if (Test-Path -LiteralPath $p -PathType Leaf) {
        Write-Result -Name "root file present: $f" -Status PASS
    } else {
        Write-Result -Name "root file present: $f" -Status FAIL -Detail "not found"
    }
}
Write-Output ""

# --- Check 2: README structure table vs actual top-level tree ---
Write-Output "-- Check 2: README.md structure table vs actual tree --"
$readmePath = Join-Path $RepoRoot "README.md"
if (Test-Path -LiteralPath $readmePath) {
    $readmeContent = Get-Content -LiteralPath $readmePath -Raw
    $tablePaths = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($m in [regex]::Matches($readmeContent, '(?m)^\|\s*`([^`]+)`\s*\|')) {
        [void]$tablePaths.Add($m.Groups[1].Value.TrimEnd('/'))
    }
    if ($tablePaths.Count -eq 0) {
        Write-Result -Name "README structure table parsed" -Status FAIL -Detail "no `` `path` `` rows found - table format may have changed"
    } else {
        Write-Result -Name "README structure table parsed" -Status PASS -Detail "$($tablePaths.Count) entries"
        foreach ($tp in $tablePaths) {
            $full = Join-Path $RepoRoot $tp
            if (Test-Path -LiteralPath $full) {
                Write-Result -Name "table entry exists on disk: $tp" -Status PASS
            } else {
                Write-Result -Name "table entry exists on disk: $tp" -Status FAIL -Detail "listed in README.md but not found"
            }
        }
        # Actual top-level entries (files and dirs), excluding .git and gitignored cruft
        $actualTop = Get-ChildItem -LiteralPath $RepoRoot -Force |
            Where-Object { $_.Name -ne ".git" -and $_.Name -ne ".gitignore" -and $_.Name -ne "README.md" } |
            ForEach-Object { $_.Name }
        foreach ($item in $actualTop) {
            if (-not $tablePaths.Contains($item)) {
                Write-Result -Name "top-level item documented: $item" -Status FAIL -Detail "exists on disk but not listed in README.md's structure table"
            }
        }
    }
} else {
    Write-Result -Name "README.md structure table" -Status SKIP -Detail "README.md not found"
}
Write-Output ""

# --- Check 3: frontmatter version/date consistency ---
Write-Output "-- Check 3: frontmatter version/last_reviewed consistency --"
$versionedFiles = @("CLAUDE.md", "GLOBAL_CLAUDE.md", "PROJECT_CONSTITUTION.md")
$versions = @{}
foreach ($f in $versionedFiles) {
    $p = Join-Path $RepoRoot $f
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Result -Name "frontmatter readable: $f" -Status SKIP -Detail "file not found"
        continue
    }
    $content = Get-Content -LiteralPath $p -Raw
    $vMatch = [regex]::Match($content, '(?m)^version:\s*(.+?)\s*$')
    $rMatch = [regex]::Match($content, '(?m)^last_reviewed:\s*(.+?)\s*$')
    if ($vMatch.Success -and $rMatch.Success) {
        $versions[$f] = @{ Version = $vMatch.Groups[1].Value; Reviewed = $rMatch.Groups[1].Value }
        Write-Result -Name "frontmatter readable: $f" -Status PASS -Detail "version=$($vMatch.Groups[1].Value) last_reviewed=$($rMatch.Groups[1].Value)"
    } else {
        Write-Result -Name "frontmatter readable: $f" -Status FAIL -Detail "missing version and/or last_reviewed frontmatter field"
    }
}
$readmeVerMatch = $null
if (Test-Path -LiteralPath $readmePath) {
    $readmeVerMatch = [regex]::Match((Get-Content -LiteralPath $readmePath -Raw), 'Toolkit version:\s*([\d.]+)\s*.\s*Last reviewed:\s*(\S+)')
    if ($readmeVerMatch.Success) {
        $versions["README.md"] = @{ Version = $readmeVerMatch.Groups[1].Value; Reviewed = $readmeVerMatch.Groups[2].Value }
        Write-Result -Name "version line readable: README.md" -Status PASS -Detail "version=$($readmeVerMatch.Groups[1].Value) last_reviewed=$($readmeVerMatch.Groups[2].Value)"
    } else {
        Write-Result -Name "version line readable: README.md" -Status FAIL -Detail "'Toolkit version: X . Last reviewed: Y' line not found or format changed"
    }
}
if ($versions.Count -gt 1) {
    $distinctVersions = $versions.Values.Version | Select-Object -Unique
    $distinctReviewed = $versions.Values.Reviewed | Select-Object -Unique
    if ($distinctVersions.Count -eq 1 -and $distinctReviewed.Count -eq 1) {
        Write-Result -Name "versions consistent across all files" -Status PASS -Detail "all at $($distinctVersions[0]), reviewed $($distinctReviewed[0])"
    } else {
        Write-Result -Name "versions consistent across all files" -Status FAIL -Detail "mismatch found: $($versions.Keys | ForEach-Object { "$_=$($versions[$_].Version)/$($versions[$_].Reviewed)" } | Join-String -Separator '; ')"
    }
}
Write-Output ""

# --- Check 4: no empty/near-empty files in content directories ---
Write-Output "-- Check 4: no empty or near-empty planned deliverables --"
$contentDirs = @("chapters","prompts","templates","checklists","reviews","summaries","session_logs")
foreach ($dir in $contentDirs) {
    $dirPath = Join-Path $RepoRoot $dir
    if (-not (Test-Path -LiteralPath $dirPath)) {
        Write-Result -Name "directory scanned: $dir" -Status SKIP -Detail "not found"
        continue
    }
    $mdFiles = Get-ChildItem -LiteralPath $dirPath -Filter "*.md" -File
    foreach ($file in $mdFiles) {
        $nonBlankLines = (Get-Content -LiteralPath $file.FullName | Where-Object { $_.Trim() -ne "" }).Count
        $rel = $file.FullName.Substring($RepoRoot.Length + 1)
        if ($nonBlankLines -lt 3) {
            Write-Result -Name "non-empty: $rel" -Status FAIL -Detail "only $nonBlankLines non-blank line(s)"
        } else {
            Write-Result -Name "non-empty: $rel" -Status PASS
        }
    }
}
Write-Output ""

# --- Check 5: internal cross-references resolve (best-effort) ---
Write-Output "-- Check 5: internal Markdown cross-references resolve (best-effort) --"
$allMdFiles = Get-ChildItem -LiteralPath $RepoRoot -Filter "*.md" -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }
$topLevelDirs = [System.Collections.Generic.HashSet[string]]::new(
    [string[]](Get-ChildItem -LiteralPath $RepoRoot -Directory | ForEach-Object { $_.Name }))
$allBasenames = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]($allMdFiles | ForEach-Object { $_.Name }), [System.StringComparer]::OrdinalIgnoreCase)

$refPattern = '`([A-Za-z0-9_][A-Za-z0-9_./\\-]*\.md)`|\]\(([A-Za-z0-9_][A-Za-z0-9_./\\-]*\.md)\)'
$brokenCount = 0
$checkedCount = 0
foreach ($file in $allMdFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $fileDir = Split-Path $file.FullName -Parent
    foreach ($m in [regex]::Matches($content, $refPattern)) {
        $ref = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
        # Skip placeholders
        if ($ref -match 'YYYY|NN|<|>|\.\.\.') { continue }

        $hasSlash = $ref -match '[/\\]'
        if ($hasSlash) {
            $firstSegment = ($ref -split '[/\\]')[0]
            if (-not $topLevelDirs.Contains($firstSegment)) {
                # Not a path under this repo's own top-level dirs (e.g. an
                # external repo path like salary-currency-pro/CLAUDE.md) -
                # out of scope for this check, not a broken reference.
                continue
            }
            $checkedCount++
            $candidates = @((Join-Path $fileDir $ref), (Join-Path $RepoRoot $ref))
            $resolved = $false
            foreach ($c in $candidates) {
                if (Test-Path -LiteralPath $c) { $resolved = $true; break }
            }
        } else {
            # Bare filename shorthand (e.g. a comma-separated list relying on
            # a preceding item's directory context) - resolve if a file with
            # this exact name exists anywhere in the repository.
            $checkedCount++
            $resolved = $allBasenames.Contains($ref)
        }
        if (-not $resolved) {
            $brokenCount++
            $relSource = $file.FullName.Substring($RepoRoot.Length + 1)
            Write-Result -Name "cross-reference resolves" -Status FAIL -Detail "'$ref' referenced in $relSource does not resolve"
        }
    }
}
if ($checkedCount -gt 0 -and $brokenCount -eq 0) {
    Write-Result -Name "all $checkedCount checked cross-references resolve" -Status PASS
} elseif ($checkedCount -eq 0) {
    Write-Result -Name "cross-reference scan" -Status SKIP -Detail "no matching references found - regex may need adjustment"
}
Write-Output ""

# --- Summary ---
Write-Output "== Summary =="
Write-Output "  Pass: $script:PassCount"
Write-Output "  Fail: $script:FailCount"
Write-Output "  Skip: $script:SkipCount"
Write-Output ""
Write-Output "This check is diagnostic only. It does not authorize corrective"
Write-Output "changes on its own - review findings and apply this repository's"
Write-Output "own approval rules before acting on them."

if ($script:FailCount -gt 0) { exit 1 } else { exit 0 }
