#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
TARGET_DIR="$(abs_dir "$TARGET")"

info "Agent team status: $TARGET_DIR"
info ""

if [ -e "$TARGET_DIR/.agent-team/current-phase.md" ]; then
  sed -n '1,40p' "$TARGET_DIR/.agent-team/current-phase.md"
else
  info "missing .agent-team/current-phase.md"
fi

info ""
info "Task board:"
if [ -e "$TARGET_DIR/.agent-team/task-board.md" ]; then
  sed -n '1,40p' "$TARGET_DIR/.agent-team/task-board.md"
else
  info "missing .agent-team/task-board.md"
fi

info ""
info "Agent results:"
if ls "$TARGET_DIR/.agent-team/agent-results/"*.md >/dev/null 2>&1; then
  for result in "$TARGET_DIR/.agent-team/agent-results/"*.md; do
    name="$(basename "$result")"
    status="$(awk -F': *' '/^STATUS:/ {print $2; exit}' "$result")"
    confidence="$(awk -F': *' '/^CONFIDENCE:/ {print $2; exit}' "$result")"
    printf '%s status=%s confidence=%s\n' "$name" "${status:-unknown}" "${confidence:-unknown}"
  done
else
  info "no agent result files yet"
fi

info ""
if command -v herdr >/dev/null 2>&1; then
  info "Herdr agents:"
  set +e
  herdr agent list
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    info "herdr agent list failed; Herdr may not be running"
  fi
else
  info "Herdr CLI not found; local artifact status only"
fi
