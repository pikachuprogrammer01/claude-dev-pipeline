# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Windows Installer
#
# Usage (from GitHub):
#   irm https://raw.githubusercontent.com/pikachuprogrammer01/claude-dev-pipeline/main/install.ps1 | iex
#
# Usage (from local clone):
#   .\install.ps1
# ─────────────────────────────────────────────────────────────────────────────
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/pikachuprogrammer01/claude-dev-pipeline"
$PIPELINE_DIR = Join-Path $HOME ".claude-pipeline"
$CLAUDE_SKILLS_DIR = Join-Path $HOME ".claude\skills"

# ── Colors ────────────────────────────────────────────────────────────────────
function info { param($msg) Write-Host "▸ $msg" -ForegroundColor Cyan }
function ok   { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function die  { param($msg) Write-Host "✗ $msg" -ForegroundColor Red; exit 1 }

# ── Prerequisites ───────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    die "git is required but not installed. Please install Git for Windows: https://git-scm.com/download/win"
}

# ── Locate source ───────────────────────────────────────────────────────────
$_src = $null
$_scriptPath = $PSCommandPath  # Full path to this script

if ($_scriptPath -and (Test-Path $_scriptPath)) {
    $_candidate = Split-Path -Parent $_scriptPath
    if (Test-Path (Join-Path $_candidate "skills\git-init\SKILL.md")) {
        $_src = $_candidate
    }
}

if ($_src) {
    # ── Running from a local clone ───────────────────────────────────────
    info "Installing from local repo: $_src"
    if ($_src -ne $PIPELINE_DIR) {
        info "Syncing to $PIPELINE_DIR..."
        if (-not (Test-Path $PIPELINE_DIR)) {
            New-Item -ItemType Directory -Path $PIPELINE_DIR -Force | Out-Null
        }
        # Remove existing content and copy fresh
        if (Test-Path $PIPELINE_DIR) {
            Remove-Item -Path "$PIPELINE_DIR\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -Path "$_src\*" -Destination $PIPELINE_DIR -Recurse -Force
    }
    ok "Source ready at $PIPELINE_DIR"
} else {
    # ── Running via irm | iex — clone or update from GitHub ──────────────
    if (Test-Path (Join-Path $PIPELINE_DIR ".git")) {
        info "Updating existing installation at $PIPELINE_DIR..."
        Push-Location $PIPELINE_DIR
        try {
            git pull --quiet --ff-only
        } finally {
            Pop-Location
        }
        ok "Updated to latest"
    } else {
        info "Cloning from $REPO_URL..."
        if (Test-Path $PIPELINE_DIR) {
            Remove-Item -Path $PIPELINE_DIR -Recurse -Force -ErrorAction SilentlyContinue
        }
        git clone --quiet $REPO_URL $PIPELINE_DIR
        ok "Cloned to $PIPELINE_DIR"
    }
}

# ── Install git-init skill globally (only this one is global) ────────────────
$gitInitSkillDir = Join-Path $CLAUDE_SKILLS_DIR "git-init"
if (-not (Test-Path $gitInitSkillDir)) {
    New-Item -ItemType Directory -Path $gitInitSkillDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $PIPELINE_DIR "skills\git-init\SKILL.md") -Destination (Join-Path $gitInitSkillDir "SKILL.md") -Force
ok "git-init skill installed → $gitInitSkillDir\SKILL.md"

# ── Make hook templates executable ──────────────────────────────────────────
$hooksDir = Join-Path $PIPELINE_DIR "templates\hooks"
if (Test-Path $hooksDir) {
    # On Windows, .ps1 and .cmd files don't need chmod +x
    # But we ensure they have proper execution policy handling
    Get-ChildItem -Path $hooksDir -File | ForEach-Object {
        # Unblock files downloaded from internet (if applicable)
        Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
    }
    ok "Hook templates are ready"
}

# ── Record pipeline path — read by git-init skill at runtime ────────────────
$pipelinePathFile = Join-Path $HOME ".claude-pipeline-path"
$PIPELINE_DIR | Out-File -FilePath $pipelinePathFile -Encoding utf8 -Force
ok "Pipeline path saved to $pipelinePathFile"

# ── Done ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Claude Dev Pipeline installed successfully" -ForegroundColor Green
Write-Host ""
Write-Host "  Start a new project:" -ForegroundColor White
Write-Host "    mkdir my-project; cd my-project" -ForegroundColor Gray
Write-Host "    claude              # open Claude Code" -ForegroundColor Gray
Write-Host "    > @git-init         # type this in Claude Code" -ForegroundColor Gray
Write-Host ""
Write-Host "  Manage:" -ForegroundColor White
Write-Host "    $PIPELINE_DIR\update.ps1      — pull latest changes" -ForegroundColor Gray
Write-Host "    $PIPELINE_DIR\uninstall.ps1   — remove installation" -ForegroundColor Gray