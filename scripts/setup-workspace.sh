#!/usr/bin/env bash
# Sets up a developer workspace: symlinks commands, creates settings.json and workspace CLAUDE.md.
# Usage: ./ai-platform/scripts/setup-workspace.sh [workspace-dir]
#        If workspace-dir is omitted, uses the current directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_PLATFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="${1:-$(pwd)}"

echo "ai-platform: setting up workspace at $WORKSPACE_DIR"
echo "ai-platform source: $AI_PLATFORM_DIR"
echo ""

# ── .claude directory ────────────────────────────────────────────────────────

mkdir -p "$WORKSPACE_DIR/.claude"

# Symlink commands directory
COMMANDS_LINK="$WORKSPACE_DIR/.claude/commands"
if [ -L "$COMMANDS_LINK" ]; then
  echo "  commands symlink already exists — updating"
  rm "$COMMANDS_LINK"
elif [ -d "$COMMANDS_LINK" ]; then
  echo "  ERROR: $COMMANDS_LINK exists as a real directory, not a symlink."
  echo "  Please remove or rename it manually, then re-run this script."
  exit 1
fi
ln -sf "$AI_PLATFORM_DIR/commands" "$COMMANDS_LINK"
echo "  ✓ commands → $AI_PLATFORM_DIR/commands"

# Symlink skills directory
SKILLS_LINK="$WORKSPACE_DIR/.claude/skills"
if [ -L "$SKILLS_LINK" ]; then
  echo "  skills symlink already exists — updating"
  rm "$SKILLS_LINK"
elif [ -d "$SKILLS_LINK" ]; then
  echo "  ERROR: $SKILLS_LINK exists as a real directory, not a symlink."
  echo "  Please remove or rename it manually, then re-run this script."
  exit 1
fi
ln -sf "$AI_PLATFORM_DIR/skills" "$SKILLS_LINK"
echo "  ✓ skills → $AI_PLATFORM_DIR/skills"

# Copy settings.json if not present
SETTINGS_FILE="$WORKSPACE_DIR/.claude/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  cp "$AI_PLATFORM_DIR/scripts/settings.template.json" "$SETTINGS_FILE"
  echo "  ✓ created .claude/settings.json (from template — review before use)"
else
  echo "  · .claude/settings.json already exists — skipping (run update-workspace.sh to sync)"
fi

# ── workspace CLAUDE.md ──────────────────────────────────────────────────────

WORKSPACE_CLAUDE="$WORKSPACE_DIR/CLAUDE.md"
if [ ! -f "$WORKSPACE_CLAUDE" ]; then
  cat > "$WORKSPACE_CLAUDE" << 'EOF'
# Workspace Configuration

@ai-platform/CLAUDE.md

## Services in this workspace

<!-- List the service repos present in this workspace, one per line.
     Example:
     - service-payments/  — payment processing service
     - service-users/     — user management service
-->

## Documentation repo

<!-- Path to the project docs repo, e.g.:
     - myproject-docs/
-->

## Workspace-specific context

<!-- Any conventions or context specific to this workspace that isn't
     covered by the platform rules. Keep this short — platform rules
     should cover most cases.
-->
EOF
  echo "  ✓ created workspace CLAUDE.md"
else
  echo "  · workspace CLAUDE.md already exists — skipping"
fi

# ── done ─────────────────────────────────────────────────────────────────────

echo ""
echo "Setup complete. Next steps:"
echo ""
echo "  1. Edit $WORKSPACE_CLAUDE"
echo "     → Fill in the list of services and docs repo."
echo ""
echo "  2. Review $SETTINGS_FILE"
echo "     → Adjust permissions for your environment."
echo "     → Plugins will be installed on first Claude Code launch."
echo ""
echo "  3. Install glab CLI if not already installed:"
echo "     → https://gitlab.com/gitlab-org/cli"
echo "     → Configure: glab auth login --hostname <your-gitlab-host>"
echo ""
echo "  4. Open Claude Code in $WORKSPACE_DIR and start working."
echo "     → Run /feature:analyze <idea> to start a new feature."
