#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
PHASE="${2:-discovery}"
shift $(( $# >= 1 ? 1 : 0 ))
shift $(( $# >= 1 ? 1 : 0 ))

TARGET_DIR="$(abs_dir "$TARGET")"
PHASE="$(normalize_phase "$PHASE")"
DRY_RUN=1
ROLE_CSV=""
MODEL="opencode/minimax-m3-free"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --execute)
      DRY_RUN=0
      shift
      ;;
    --roles)
      ROLE_CSV="${2:-}"
      [ -n "$ROLE_CSV" ] || die "--roles requires a comma-separated value"
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      [ -n "$MODEL" ] || die "--model requires a value"
      shift 2
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

TASK_DIR="$TARGET_DIR/.agent-team/tasks"
mkdir -p "$TASK_DIR"

if [ -n "$ROLE_CSV" ]; then
  ROLES="$(printf '%s' "$ROLE_CSV" | tr ',' '\n')"
else
  ROLES="$(roles_for_phase "$PHASE")"
fi

PROJECT_NAME="$(basename "$TARGET_DIR")"
NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

create_task_file() {
  local role="$1"
  local task_file="$TASK_DIR/${PHASE}-${role}.md"
  cat > "$task_file" <<TASK
# Agent Task

ID: T-${PHASE}-${role}
Phase: $PHASE
Agent: $role
Created: $NOW

## Goal

Complete the assigned $PHASE work for $PROJECT_NAME using the role prompt and project artifacts.

## Expected Artifacts

$(required_artifacts_for_phase "$PHASE" | sed 's/^/- /')

## Done Criteria

- Required artifacts exist and contain project-specific content.
- Assumptions, risks, and open questions are explicit.
- Standard agent result contract is written to .agent-team/agent-results/${role}.md.
- Human approval items are marked instead of bypassed.

## Context

- Project root: $TARGET_DIR
- Package root: $PACKAGE_ROOT
- Phase gate: $(phase_gate "$PHASE")
- Approval policy: docs/agent/human-approval-policy.md

## Required Response

End with:

\`\`\`markdown
STATUS:
CONFIDENCE:
TASK_RECEIVED:
WHAT_I_DID:
ARTIFACTS_CREATED_OR_UPDATED:
KEY_DECISIONS:
ASSUMPTIONS:
RISKS:
TESTS_OR_CHECKS:
OPEN_QUESTIONS:
NEXT_RECOMMENDED_ACTION:
\`\`\`
TASK
  printf '%s\n' "$task_file"
}

if [ "$DRY_RUN" -eq 0 ]; then
  require_command herdr
  require_command pi
fi

while IFS= read -r role; do
  [ -n "$role" ] || continue
  prompt_file="$PACKAGE_ROOT/prompts/$(prompt_for_role "$role")"
  [ -e "$prompt_file" ] || die "missing prompt for role '$role': $prompt_file"
  task_file="$(create_task_file "$role")"
  result_path="$TARGET_DIR/.agent-team/agent-results/${role}.md"
  if [ ! -e "$result_path" ]; then
    cp "$PACKAGE_ROOT/templates/agent-result.md" "$result_path"
  fi

  command_text="pi --model \"$MODEL\" --prompt-template \"$prompt_file\" --name \"${role}_${PROJECT_NAME}\" -p \"Read $task_file and execute the task. Write artifacts into $TARGET_DIR.\""

  if [ "$DRY_RUN" -eq 1 ]; then
    info "prepared task: $task_file"
    info "dry-run command:"
    info "herdr agent start \"$role\" --cwd \"$TARGET_DIR\" --split right -- $command_text"
  else
    info "starting agent: $role"
    herdr agent start "$role" --cwd "$TARGET_DIR" --split right -- pi --model "$MODEL" --prompt-template "$prompt_file" --name "${role}_${PROJECT_NAME}" -p "Read $task_file and execute the task. Write artifacts into $TARGET_DIR."
  fi
done <<EOF_ROLES
$ROLES
EOF_ROLES
