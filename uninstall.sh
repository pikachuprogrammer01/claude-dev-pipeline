#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Uninstaller
# Usage: ~/.claude-pipeline/uninstall.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PIPELINE_DIR="${HOME}/.claude-pipeline"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"

GRN='\033[0;32m'; YLW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GRN}✓${NC} $1"; }
warn() { echo -e "${YLW}!${NC} $1"; }

echo "The following will be removed:"
echo "  ${PIPELINE_DIR}"
echo "  ${CLAUDE_SKILLS_DIR}/git-init/"
echo "  ~/.claude-pipeline-path"
echo ""
warn "Existing project .claude/ directories are NOT affected."
echo ""
read -r -p "Continue? [y/N] " _confirm
[[ "${_confirm}" =~ ^[yY]$ ]] || { echo "Aborted."; exit 0; }

echo ""
if [[ -d "${PIPELINE_DIR}" ]]; then
  rm -rf "${PIPELINE_DIR}"
  ok "Removed ${PIPELINE_DIR}"
fi

if [[ -d "${CLAUDE_SKILLS_DIR}/git-init" ]]; then
  rm -rf "${CLAUDE_SKILLS_DIR}/git-init"
  ok "Removed global git-init skill"
fi

if [[ -f "${HOME}/.claude-pipeline-path" ]]; then
  rm -f "${HOME}/.claude-pipeline-path"
  ok "Removed ~/.claude-pipeline-path"
fi

echo ""
echo "Uninstalled cleanly. Run install.sh again to reinstall."
