#!/usr/bin/env bash
# Updates an existing workspace after ai-platform changes.
# Refreshes the commands and skills symlinks. Does NOT overwrite settings.json or CLAUDE.md.
# Usage: ./ai-platform/scripts/update-workspace.sh [workspace-dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_PLATFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="${1:-$(pwd)}"

echo "ai-platform: updating workspace at $WORKSPACE_DIR"

# ── commands symlink ─────────────────────────────────────────────────────────

COMMANDS_LINK="$WORKSPACE_DIR/.claude/commands"
if [ -L "$COMMANDS_LINK" ]; then
  rm "$COMMANDS_LINK"
  ln -sf "$AI_PLATFORM_DIR/commands" "$COMMANDS_LINK"
  echo "  ✓ commands symlink updated → $AI_PLATFORM_DIR/commands"
elif [ ! -e "$COMMANDS_LINK" ]; then
  echo "  · commands symlink not found — run setup-workspace.sh first"
else
  echo "  ERROR: $COMMANDS_LINK is not a symlink. Run setup-workspace.sh to inspect."
  exit 1
fi

# ── skills symlink ────────────────────────────────────────────────────────────

SKILLS_LINK="$WORKSPACE_DIR/.claude/skills"
if [ -L "$SKILLS_LINK" ]; then
  rm "$SKILLS_LINK"
  ln -sf "$AI_PLATFORM_DIR/skills" "$SKILLS_LINK"
  echo "  ✓ skills symlink updated → $AI_PLATFORM_DIR/skills"
elif [ ! -e "$SKILLS_LINK" ]; then
  echo "  · skills symlink not found — run setup-workspace.sh first"
else
  echo "  ERROR: $SKILLS_LINK is not a symlink. Run setup-workspace.sh to inspect."
  exit 1
fi

# ── settings merge hint ──────────────────────────────────────────────────────

TEMPLATE="$AI_PLATFORM_DIR/scripts/settings.template.json"
SETTINGS="$WORKSPACE_DIR/.claude/settings.json"

if [ -f "$SETTINGS" ] && [ -f "$TEMPLATE" ]; then
  echo ""
  echo "  Note: settings.json was NOT overwritten."
  echo "  Check if the template has new permissions you want to add:"
  echo "    diff $TEMPLATE $SETTINGS"
fi

echo ""
echo "Update complete."
