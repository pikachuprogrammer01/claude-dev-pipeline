#!/usr/bin/env pwsh
#Requires -Version 5.1
# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Windows Updater
# Usage: ~\.claude-pipeline\update.ps1
# ─────────────────────────────────────────────────────────────────────────────
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PIPELINE_DIR = Join-Path $HOME ".claude-pipeline"
$CLAUDE_SKILLS_DIR = Join-Path $HOME ".claude\skills"

# ── Colors ────────────────────────────────────────────────────────────────────
function info { param($msg) Write-Host "▸ $msg" -ForegroundColor Cyan }
function ok   { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function die  { param($msg) Write-Host "✗ $msg" -ForegroundColor Red; exit 1 }

# ── Check installation ────────────────────────────────────────────────────────
if (-not (Test-Path (Join-Path $PIPELINE_DIR ".git"))) {
    die "Pipeline not installed. Run install.ps1 first."
}

# ── Pull latest ─────────────────────────────────────────────────────────────
info "Pulling latest changes..."
Push-Location $PIPELINE_DIR
try {
    git pull --ff-only
} finally {
    Pop-Location
}
ok "Repository updated"

# ── Refresh global git-init skill ───────────────────────────────────────────
info "Refreshing global git-init skill..."
$gitInitSkillDir = Join-Path $CLAUDE_SKILLS_DIR "git-init"
if (-not (Test-Path $gitInitSkillDir)) {
    New-Item -ItemType Directory -Path $gitInitSkillDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $PIPELINE_DIR "skills\git-init\SKILL.md") `
    -Destination (Join-Path $gitInitSkillDir "SKILL.md") -Force
ok "git-init skill refreshed"

# ── Re-ensure hooks are ready ─────────────────────────────────────────────────
$hooksDir = Join-Path $PIPELINE_DIR "templates\hooks"
if (Test-Path $hooksDir) {
    Get-ChildItem -Path $hooksDir -File | ForEach-Object {
        Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
    }
}

# ── Done ────────────────────────────────────────────────────────────────────
Write-Host ""
ok "Pipeline updated"
Write-Host ""
Write-Host "Note: existing projects keep their currently installed skill versions."
Write-Host "To refresh a specific project's skills, cd into it and run @git-init --refresh in Claude Code."