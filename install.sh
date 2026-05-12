#!/usr/bin/env bash
set -euo pipefail

REPO="caphugh/kt-agent"
VERSION="main"
DRY_RUN=false
FORCE=false
TARGET_DIR="$(pwd)"

usage() {
  cat <<EOF
Usage: install.sh [options]

Options:
  --version <tag>   Install specific release tag (default: main)
  --force           Overwrite user-data files (persona.md, knowledge/)
  --dry-run         Print what would be installed, make no changes
  --target <dir>    Install into directory (default: current directory)
  --help            Show this help

Examples:
  curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash
  curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash -s -- --version v1.0.0
  bash install.sh --dry-run
  bash install.sh --force --target /path/to/my-project
EOF
}

# ── Argument parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)  VERSION="${2:?'--version requires a value'}"; shift 2 ;;
    --force)    FORCE=true; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --target)   TARGET_DIR="${2:?'--target requires a value'}"; shift 2 ;;
    --help|-h)  usage; exit 0 ;;
    *)          echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

BASE_URL="https://raw.githubusercontent.com/${REPO}/${VERSION}"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "  $*"; }
info() { echo "$*"; }
ok()   { echo "  ✓ $*"; }
skip() { echo "  - $*  (skipped)"; }
dry()  { echo "  ~ $*  [dry-run]"; }

# Fetch a file from the release and write it to dest.
# Creates parent directories as needed.
fetch_asset() {
  local src_path="$1"   # path within repo, e.g. .claude/agents/kt-agent.md
  local dest="$2"       # absolute destination path

  if [[ "$DRY_RUN" == true ]]; then
    dry "overwrite  ${dest#"$TARGET_DIR/"}"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  local url="${BASE_URL}/${src_path}"
  if ! curl -fsSL "$url" -o "$dest"; then
    echo "  ERROR: failed to fetch ${url}" >&2
    exit 1
  fi
  ok "overwrite  ${dest#"$TARGET_DIR/"}"
}

# Create a file only if it doesn't exist (or --force).
# Content provided via stdin.
create_if_missing() {
  local dest="$1"
  local label="${dest#"$TARGET_DIR/"}"

  if [[ -f "$dest" && "$FORCE" == false ]]; then
    skip "$label"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    if [[ -f "$dest" ]]; then
      dry "overwrite  $label  (--force)"
    else
      dry "create     $label"
    fi
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cat > "$dest"
  if [[ -f "$dest" && "$FORCE" == true ]]; then
    ok "overwrite  $label  (--force)"
  else
    ok "create     $label"
  fi
}

# Create a directory (and .gitkeep) only if missing.
create_dir() {
  local dir="$1"
  local label="${dir#"$TARGET_DIR/"}"

  if [[ -d "$dir" ]]; then
    skip "$dir  (exists)"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    dry "mkdir      $label"
    return
  fi

  mkdir -p "$dir"
  touch "$dir/.gitkeep"
  ok "mkdir      $label"
}

# ── Preflight ─────────────────────────────────────────────────────────────────

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "ERROR: curl is required but not found in PATH" >&2
  exit 1
fi

# ── Main ──────────────────────────────────────────────────────────────────────

echo ""
echo "kt-agent installer"
echo "  repo:    ${REPO}"
echo "  version: ${VERSION}"
echo "  target:  ${TARGET_DIR}"
[[ "$DRY_RUN" == true ]] && echo "  mode:    dry-run (no files written)"
[[ "$FORCE"   == true ]] && echo "  mode:    force (user-data files will be overwritten)"
echo ""

# ── Versioned assets (always overwrite) ──────────────────────────────────────

info "Installing versioned assets..."

fetch_asset ".claude/agents/kt-agent.md"                  "$TARGET_DIR/.claude/agents/kt-agent.md"
fetch_asset ".claude/commands/kt-agent/ingest.md"         "$TARGET_DIR/.claude/commands/kt-agent/ingest.md"
fetch_asset ".claude/commands/kt-agent/interview.md"      "$TARGET_DIR/.claude/commands/kt-agent/interview.md"
fetch_asset ".claude/commands/kt-agent/cleanse.md"        "$TARGET_DIR/.claude/commands/kt-agent/cleanse.md"
fetch_asset ".claude/skills/kt-parse/SKILL.md"      "$TARGET_DIR/.claude/skills/kt-parse/SKILL.md"
fetch_asset ".claude/skills/kt-categorize/SKILL.md" "$TARGET_DIR/.claude/skills/kt-categorize/SKILL.md"
fetch_asset ".claude/skills/kt-persona/SKILL.md"    "$TARGET_DIR/.claude/skills/kt-persona/SKILL.md"

echo ""

# ── User-data files (create if missing, respect --force) ─────────────────────

info "Initializing user-data files..."

create_if_missing "$TARGET_DIR/persona.md" <<'EOF'
# KT-Agent Persona

## Domain Knowledge Summary

No knowledge areas documented yet. This section is auto-updated by the persona skill as knowledge is ingested.

## Communication Style

- Default: clear, direct, technical
- Adapts as interviews reveal user's natural communication patterns

## Areas of Expertise

No areas documented yet. Populated as the knowledge base grows through interviews and file ingestion.
EOF

create_if_missing "$TARGET_DIR/knowledge/INDEX.md" <<'EOF'
# Knowledge Base Index

## projects/

## references/

## troubleshooting/

## workflows/
EOF

echo ""

# ── Directories ───────────────────────────────────────────────────────────────

info "Creating directories..."

create_dir "$TARGET_DIR/inbox/processed"
create_dir "$TARGET_DIR/knowledge/projects"
create_dir "$TARGET_DIR/knowledge/references"
create_dir "$TARGET_DIR/knowledge/troubleshooting"
create_dir "$TARGET_DIR/knowledge/workflows"

echo ""

# ── Done ──────────────────────────────────────────────────────────────────────

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry-run complete. No files were written."
  echo ""
  exit 0
fi

echo "kt-agent installed (${VERSION})"
echo ""
echo "Next steps:"
echo "  1. Open this project in Claude Code"
echo "  2. Run /kt-agent/interview to capture your first knowledge topic"
echo "  3. Run /kt-agent/ingest to process it into the knowledge base"
echo "  4. Invoke 'kt-agent' to query what you've captured"
echo ""
