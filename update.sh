#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Updater
# Usage: ~/.claude-pipeline/update.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PIPELINE_DIR="${HOME}/.claude-pipeline"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"

GRN='\033[0;32m'; BLU='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${BLU}▸${NC} $1"; }
ok()   { echo -e "${GRN}✓${NC} $1"; }
die()  { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }

[[ -d "${PIPELINE_DIR}/.git" ]] || die "Pipeline not installed. Run install.sh first."

# ── Pull latest ───────────────────────────────────────────────────────────────
info "Pulling latest changes..."
git -C "${PIPELINE_DIR}" pull --ff-only
ok "Repository updated"

# ── Refresh global git-init skill ─────────────────────────────────────────────
info "Refreshing global git-init skill..."
mkdir -p "${CLAUDE_SKILLS_DIR}/git-init"
cp "${PIPELINE_DIR}/skills/git-init/SKILL.md" "${CLAUDE_SKILLS_DIR}/git-init/SKILL.md"
ok "git-init skill refreshed"

# ── Re-ensure hooks are executable ────────────────────────────────────────────
if [[ -d "${PIPELINE_DIR}/templates/hooks" ]]; then
  find "${PIPELINE_DIR}/templates/hooks" -type f -exec chmod +x {} \; 2>/dev/null || true
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
ok "Pipeline updated"
echo ""
echo "Note: existing projects keep their currently installed skill versions."
echo "To refresh a specific project's skills, cd into it and run @git-init --refresh in Claude Code."
