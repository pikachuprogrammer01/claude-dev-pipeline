# git-init — Project Pipeline Initializer

Sets up a new project with the full Claude Dev Pipeline: 9 git branches,
branch-specific CLAUDE files, project skills, git hooks, and README generation.

Read this file completely before starting. Execute all steps in order.
Do not skip steps or combine them.

---

## Prerequisites

Verify the pipeline is installed:
```bash
cat ~/.claude-pipeline-path
```
If this fails, stop and tell the user:
> "Pipeline not installed. Please run `install.sh` from the claude-dev-pipeline repo first."

Store the path for use throughout this session:
```bash
PIPELINE=$(cat ~/.claude-pipeline-path)
```

---

## Step 0 — Preflight Checks

```bash
ls -la
```

- If `.git/` already exists: ask the user if they want to reinitialize.
  If yes, continue. If no, stop.
- If `CLAUDE.md` already exists: warn the user this project may already be
  initialized. Confirm before continuing.
- If `--refresh` flag was passed: skip to Step 3 (skill refresh only).

---

## Step 1 — Project Config

Check whether `.claude/project.config.json` exists:
```bash
ls .claude/project.config.json 2>/dev/null && echo "EXISTS" || echo "MISSING"
```

**If MISSING:**
```bash
mkdir -p .claude
cp "$PIPELINE/config/project.config.template.json" .claude/project.config.json
```
Tell the user:
> "I've created `.claude/project.config.json`. Please fill in your project
> details (projectName, framework, packageManager, etc.) and confirm when ready."

Wait for confirmation before continuing.

**If EXISTS:** read the values and confirm them with the user.

Store key values:
```bash
PROJECT_NAME=$(python3 -c "import json; d=json.load(open('.claude/project.config.json')); print(d['projectName'])")
FRAMEWORK=$(python3 -c "import json; d=json.load(open('.claude/project.config.json')); print(d['framework'])")
PKG_MANAGER=$(python3 -c "import json; d=json.load(open('.claude/project.config.json')); print(d['packageManager'])")
SRC_DIR=$(python3 -c "import json; d=json.load(open('.claude/project.config.json')); print(d.get('srcDir','src'))")
```

---

## Step 2 — Git Init

```bash
git init
```

Write `.gitignore`:
```bash
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build outputs
dist/
build/
.next/
.nuxt/
out/

# Testing
coverage/

# Misc
.DS_Store
*.pem
.vercel
.turbo
EOF
```

---

## Step 3 — .claude/ Structure and Skills

```bash
mkdir -p .claude/skills
cp -r "$PIPELINE/skills/"* .claude/skills/
```

If `--refresh` flag was passed, stop here after the copy and tell the user:
> "Skills refreshed. Your branch structure and CLAUDE files are unchanged."

---

## Step 4 — Main Branch Setup

```bash
cp "$PIPELINE/templates/claude/main.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/main.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/SPEC.md"                            SPEC.md
cp "$PIPELINE/templates/docs/DEPLOYMENT.md"                      DEPLOYMENT.md

for f in CLAUDE.md CLAUDE-detailed.md SPEC.md DEPLOYMENT.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
```

Initial commit:
```bash
git add .
git commit -m "chore: init project with claude dev pipeline [main]"
```

---

## Step 5 — Feature Branch Creation

**Critical:** every branch is created from `main`. Always `git checkout main`
before creating a new branch. This ensures branches do not inherit each
other's commits.

### dev
```bash
git checkout main && git checkout -b dev
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/dev.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/dev.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/ARCHITECTURE.md"                   ARCHITECTURE.md
for f in CLAUDE.md CLAUDE-detailed.md ARCHITECTURE.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g; s/\{\{FRAMEWORK\}\}/${FRAMEWORK}/g; s/\{\{PKG_MANAGER\}\}/${PKG_MANAGER}/g" "$f"
done
git add . && git commit -m "chore: init dev branch"
```

### fix
```bash
git checkout main && git checkout -b fix
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/fix.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/fix.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/BUGLOG.md"                         BUGLOG.md
for f in CLAUDE.md CLAUDE-detailed.md BUGLOG.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init fix branch"
```

### refactor
```bash
git checkout main && git checkout -b refactor
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/refactor.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/refactor.CLAUDE-detailed.md" CLAUDE-detailed.md
for f in CLAUDE.md CLAUDE-detailed.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init refactor branch"
```

### version
```bash
git checkout main && git checkout -b version
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/version.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/version.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/CHANGELOG.md"                          CHANGELOG.md
for f in CLAUDE.md CLAUDE-detailed.md CHANGELOG.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init version branch"
```

### test
```bash
git checkout main && git checkout -b test
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/test.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/test.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/TEST-PLAN.md"                       TEST-PLAN.md
for f in CLAUDE.md CLAUDE-detailed.md TEST-PLAN.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init test branch"
```

### docs
```bash
git checkout main && git checkout -b docs
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/docs.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/docs.CLAUDE-detailed.md" CLAUDE-detailed.md
mkdir -p docs/decisions
for f in CLAUDE.md CLAUDE-detailed.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init docs branch"
```

### perf
```bash
git checkout main && git checkout -b perf
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/perf.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/perf.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/BENCHMARK.md"                       BENCHMARK.md
for f in CLAUDE.md CLAUDE-detailed.md BENCHMARK.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init perf branch"
```

### security
```bash
git checkout main && git checkout -b security
rm -f DEPLOYMENT.md
cp "$PIPELINE/templates/claude/security.CLAUDE.md"                   CLAUDE.md
cp "$PIPELINE/templates/claude-detailed/security.CLAUDE-detailed.md" CLAUDE-detailed.md
cp "$PIPELINE/templates/docs/SECURITY.md"                            SECURITY.md
for f in CLAUDE.md CLAUDE-detailed.md SECURITY.md; do
  perl -i -pe "s/\{\{PROJECT_NAME\}\}/${PROJECT_NAME}/g" "$f"
done
git add . && git commit -m "chore: init security branch"
```

Return to main:
```bash
git checkout main
```

---

## Step 6 — Install Git Hooks

```bash
cp "$PIPELINE/templates/hooks/commit-msg"  .git/hooks/commit-msg
cp "$PIPELINE/templates/hooks/post-commit" .git/hooks/post-commit
cp "$PIPELINE/templates/hooks/pre-push"    .git/hooks/pre-push
chmod +x .git/hooks/commit-msg .git/hooks/post-commit .git/hooks/pre-push
```

---

## Step 7 — README and SPEC Generation

### Step 7a — README

Tell the user:
> "Repository structure is ready. To generate the project README, please
> describe:
> 1. What this project does
> 2. Main features
> 3. Who it is for
>
> I will generate it using the docs skill and sync it to all branches."

After the user provides the description, consult `.claude/skills/docs/SKILL.md`
to generate `README.md` on the `main` branch.

Commit and sync to all branches:
```bash
git add README.md
git commit -m "docs: add project README"

for branch in dev fix refactor version test docs perf security; do
  git checkout "$branch"
  git checkout main -- README.md
  git add README.md
  git commit -m "docs: sync README from main"
done

git checkout main
```

### Step 7b — SPEC

Tell the user:
> "Now let's populate SPEC.md. Please answer the following:
> 1. What problem does this project solve? (1–2 sentences)
> 2. Who are the primary users?
> 3. Core features — list 3–8 items
> 4. What is explicitly out of scope?
> 5. Any specific non-functional requirements? (performance targets,
>    browser support, accessibility, etc.)
>
> I will fill in SPEC.md and sync it to all branches. It will be
> maintained on `main` — never edit it directly on other branches."

Using the user's answers, fill in SPEC.md on `main`:
- Replace the Overview section with the project description and primary users
- Replace the Core Features list with the user's feature list
- Replace the Out of Scope section with the user's answer
- Fill in any stated non-functional requirements
- Leave the Decisions and Open Questions sections empty for now

Commit and sync to all branches:
```bash
git add SPEC.md
git commit -m "docs: populate SPEC with project details"

for branch in dev fix refactor version test docs perf security; do
  git checkout "$branch"
  git checkout main -- SPEC.md
  git add SPEC.md && git commit -m "docs: sync SPEC from main"
done

git checkout main
```

## Step 8 — Completion Report

Print this summary to the user:

```
Project: {{PROJECT_NAME}}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓  Git repository initialized
✓  9 branches created with dedicated CLAUDE files
✓  Git hooks installed (commit-msg, post-commit, pre-push)
✓  Project skills installed to .claude/skills/
✓  README generated and synced to all branches

Branch reference:
  main      → production / deployment (current)
  dev       → feature development
  fix       → bug investigation & fixes
  refactor  → code quality improvements
  version   → release management
  test      → testing & QA
  docs      → documentation
  perf      → performance optimization
  security  → security auditing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next: git checkout dev
```

Recommend that the user switch to `dev` to begin feature work, or `fix` to
begin working on a known bug.

---

## Refresh Mode

When invoked as `@git-init --refresh`:
- Run Steps 0, 3 (skill copy only), and 6 (hooks) only.
- Do not touch CLAUDE.md, branch structure, or any existing project files.
- Print: "Skills and hooks refreshed from latest pipeline version."

## Subdirectory READMEs

Once source files exist, suggest the user consult `.claude/skills/docs/SKILL.md`
for each major subdirectory to generate module-level README files.
