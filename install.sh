#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Dev Pipeline — Installer
#
# Usage (from GitHub):
#   curl -fsSL https://raw.githubusercontent.com/pikachuprogrammer01/claude-dev-pipeline/main/install.sh | bash
#
# Usage (from local clone):
#   ./install.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_URL="https://github.com/pikachuprogrammer01/claude-dev-pipeline"
PIPELINE_DIR="${HOME}/.claude-pipeline"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"

# ── Colors ────────────────────────────────────────────────────────────────────
GRN='\033[0;32m'; BLU='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${BLU}▸${NC} $1"; }
ok()   { echo -e "${GRN}✓${NC} $1"; }
die()  { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || die "git is required but not installed"

# ── Locate source ─────────────────────────────────────────────────────────────
# When piped via curl | bash, BASH_SOURCE[0] is empty or "bash" — fall through to clone
_src=""
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" ]]; then
  _candidate="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
  if [[ -f "${_candidate}/skills/git-init/SKILL.md" ]]; then
    _src="${_candidate}"
  fi
fi

if [[ -n "${_src}" ]]; then
  # ── Running from a local clone ───────────────────────────────────────────
  info "Installing from local repo: ${_src}"
  if [[ "${_src}" != "${PIPELINE_DIR}" ]]; then
    info "Syncing to ${PIPELINE_DIR}..."
    mkdir -p "${PIPELINE_DIR}"
    cp -r "${_src}/." "${PIPELINE_DIR}/"
  fi
  ok "Source ready at ${PIPELINE_DIR}"
else
  # ── Running via curl — clone or update from GitHub ───────────────────────
  if [[ -d "${PIPELINE_DIR}/.git" ]]; then
    info "Updating existing installation at ${PIPELINE_DIR}..."
    git -C "${PIPELINE_DIR}" pull --quiet --ff-only
    ok "Updated to latest"
  else
    info "Cloning from ${REPO_URL}..."
    git clone --quiet "${REPO_URL}" "${PIPELINE_DIR}"
    ok "Cloned to ${PIPELINE_DIR}"
  fi
fi

# ── Install git-init skill globally (only this one is global) ─────────────────
mkdir -p "${CLAUDE_SKILLS_DIR}/git-init"
cp "${PIPELINE_DIR}/skills/git-init/SKILL.md" "${CLAUDE_SKILLS_DIR}/git-init/SKILL.md"
ok "git-init skill installed → ${CLAUDE_SKILLS_DIR}/git-init/SKILL.md"

# ── Make hook templates executable ────────────────────────────────────────────
if [[ -d "${PIPELINE_DIR}/templates/hooks" ]]; then
  find "${PIPELINE_DIR}/templates/hooks" -type f -exec chmod +x {} \;
  ok "Hook templates are executable"
fi

# ── Record pipeline path — read by git-init skill at runtime ──────────────────
echo "${PIPELINE_DIR}" > "${HOME}/.claude-pipeline-path"
ok "Pipeline path saved to ~/.claude-pipeline-path"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GRN}Claude Dev Pipeline installed successfully${NC}"
echo ""
echo "  Start a new project:"
echo "    mkdir my-project && cd my-project"
echo "    claude              # open Claude Code"
echo "    > @git-init         # type this in Claude Code"
echo ""
echo "  Manage:"
echo "    ${PIPELINE_DIR}/update.sh      — pull latest changes"
echo "    ${PIPELINE_DIR}/uninstall.sh   — remove installation"
