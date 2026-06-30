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
MODEL=""
TIER="balanced"
EFFORT="medium"
PRESET=""
GOAL=""
CONFIG_PATH="$(config_path_for_package "$PACKAGE_ROOT")"

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
    --preset)
      PRESET="${2:-}"
      [ -n "$PRESET" ] || die "--preset requires a value"
      shift 2
      ;;
    --tier)
      TIER="${2:-}"
      [ -n "$TIER" ] || die "--tier requires a value"
      shift 2
      ;;
    --effort)
      EFFORT="${2:-}"
      [ -n "$EFFORT" ] || die "--effort requires a value"
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      [ -n "$MODEL" ] || die "--model requires a value"
      shift 2
      ;;
    --goal)
      GOAL="${2:-}"
      [ -n "$GOAL" ] || die "--goal requires a value"
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
elif [ -n "$PRESET" ] && [ "$PRESET" != "auto" ]; then
  ROLES="$(preset_agents_from_config "$CONFIG_PATH" "$PRESET")"
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

${GOAL:-Complete the assigned $PHASE work for $PROJECT_NAME using the role prompt and project artifacts.}

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
- Model tier: $TIER
- Effort: $EFFORT
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
  task_id="T-${PHASE}-${role}"
  result_path="$TARGET_DIR/.agent-team/agent-results/${role}.md"
  if [ ! -e "$result_path" ]; then
    cp "$PACKAGE_ROOT/templates/agent-result.md" "$result_path"
  fi
  if [ -n "$MODEL" ]; then
    selected_model="$MODEL"
  else
    selected_model="$(model_for_role_from_config "$CONFIG_PATH" "$role" "$TIER" "$EFFORT")"
  fi
  update_task_board_row "$TARGET_DIR" "$task_id" "$PHASE" "$role" "${GOAL:-Run $PHASE work}" "queued" "$task_file" "-"

  command_text="pi --model \"$selected_model\" --prompt-template \"$prompt_file\" --name \"${role}_${PROJECT_NAME}\" -p \"Read $task_file and execute the task. Write artifacts into $TARGET_DIR.\""

  if [ "$DRY_RUN" -eq 1 ]; then
    info "prepared task: $task_file"
    info "selected model: $selected_model (tier=$TIER effort=$EFFORT role=$role)"
    info "dry-run command:"
    info "herdr agent start \"$role\" --cwd \"$TARGET_DIR\" --split right -- $command_text"
  else
    info "starting agent: $role"
    update_task_board_row "$TARGET_DIR" "$task_id" "$PHASE" "$role" "${GOAL:-Run $PHASE work}" "working" "$task_file" "-"
    herdr agent start "$role" --cwd "$TARGET_DIR" --split right -- pi --model "$selected_model" --prompt-template "$prompt_file" --name "${role}_${PROJECT_NAME}" -p "Read $task_file and execute the task. Write artifacts into $TARGET_DIR."
  fi
done <<EOF_ROLES
$ROLES
EOF_ROLES
