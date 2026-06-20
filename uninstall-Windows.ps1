#!/usr/bin/env pwsh
#Requires -Version 5.1
# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Windows Uninstaller
# Usage: ~\.claude-pipeline\uninstall.ps1
# ─────────────────────────────────────────────────────────────────────────────
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PIPELINE_DIR = Join-Path $HOME ".claude-pipeline"
$CLAUDE_SKILLS_DIR = Join-Path $HOME ".claude\skills"
$PIPELINE_PATH_FILE = Join-Path $HOME ".claude-pipeline-path"

# ── Colors ────────────────────────────────────────────────────────────────────
function ok   { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function warn { param($msg) Write-Host "! $msg" -ForegroundColor Yellow }

Write-Host "The following will be removed:"
Write-Host "  $PIPELINE_DIR"
Write-Host "  $(Join-Path $CLAUDE_SKILLS_DIR 'git-init\')"
Write-Host "  $PIPELINE_PATH_FILE"
Write-Host ""
warn "Existing project .claude/ directories are NOT affected."
Write-Host ""

$_confirm = Read-Host "Continue? [y/N]"
if ($_confirm -notmatch '^[yY]$') {
    Write-Host "Aborted."
    exit 0
}

Write-Host ""
if (Test-Path $PIPELINE_DIR) {
    Remove-Item -Path $PIPELINE_DIR -Recurse -Force
    ok "Removed $PIPELINE_DIR"
}

$gitInitDir = Join-Path $CLAUDE_SKILLS_DIR "git-init"
if (Test-Path $gitInitDir) {
    Remove-Item -Path $gitInitDir -Recurse -Force
    ok "Removed global git-init skill"
}

if (Test-Path $PIPELINE_PATH_FILE) {
    Remove-Item -Path $PIPELINE_PATH_FILE -Force
    ok "Removed $PIPELINE_PATH_FILE"
}

Write-Host ""
Write-Host "Uninstalled cleanly. Run install.ps1 again to reinstall."