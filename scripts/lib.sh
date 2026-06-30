#!/usr/bin/env bash

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

abs_dir() {
  local path="$1"
  mkdir -p "$path"
  (cd "$path" && pwd -P)
}

normalize_phase() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr ' _' '--'
}

next_phase() {
  case "$(normalize_phase "$1")" in
    intake) printf '%s\n' "discovery" ;;
    discovery) printf '%s\n' "scope" ;;
    scope) printf '%s\n' "flow" ;;
    flow) printf '%s\n' "requirements" ;;
    requirements) printf '%s\n' "blueprint" ;;
    blueprint) printf '%s\n' "implementation-plan" ;;
    implementation-plan) printf '%s\n' "implementation" ;;
    implementation) printf '%s\n' "qa" ;;
    qa) printf '%s\n' "delivery" ;;
    delivery) printf '%s\n' "done" ;;
    *) die "unknown phase: $1" ;;
  esac
}

phase_gate() {
  case "$(normalize_phase "$1")" in
    intake) printf '%s\n' "Gate 0: Intake Complete" ;;
    discovery) printf '%s\n' "Gate 1: Discovery Approved" ;;
    scope) printf '%s\n' "Gate 2: Scope Approved" ;;
    flow) printf '%s\n' "Gate 3: Flow Approved" ;;
    requirements) printf '%s\n' "Gate 3: Flow Approved" ;;
    blueprint) printf '%s\n' "Gate 4: Technical Blueprint Approved" ;;
    implementation-plan) printf '%s\n' "Gate 5: Implementation Ready" ;;
    implementation) printf '%s\n' "Gate 6: Delivery Ready" ;;
    qa) printf '%s\n' "Gate 6: Delivery Ready" ;;
    delivery) printf '%s\n' "Gate 6: Delivery Ready" ;;
    done) printf '%s\n' "Closed" ;;
    *) die "unknown phase: $1" ;;
  esac
}

required_artifacts_for_phase() {
  case "$(normalize_phase "$1")" in
    intake)
      printf '%s\n' \
        ".agent-team/state.md" \
        ".agent-team/current-phase.md" \
        ".agent-team/task-board.md" \
        "docs/product/00-intake.md"
      ;;
    discovery)
      printf '%s\n' \
        "docs/product/01-discovery.md" \
        "docs/product/02-clarifying-questions.md" \
        "docs/product/03-use-cases.md"
      ;;
    scope)
      printf '%s\n' \
        "docs/product/04-scope.md" \
        "docs/product/05-requirements.md"
      ;;
    flow)
      printf '%s\n' \
        "docs/ux/01-user-journey.md" \
        "docs/ux/02-screen-flow.md" \
        "docs/ux/03-state-and-empty-cases.md"
      ;;
    requirements)
      printf '%s\n' \
        "docs/product/05-requirements.md" \
        "docs/qa/01-acceptance-criteria.md"
      ;;
    blueprint)
      printf '%s\n' \
        "docs/architecture/01-system-blueprint.md" \
        "docs/architecture/02-api-contract.md" \
        "docs/architecture/03-security-and-permission.md" \
        "docs/data/01-entity-model.md" \
        "docs/data/02-data-dictionary.md" \
        "docs/data/03-migration-plan.md"
      ;;
    implementation-plan)
      printf '%s\n' \
        "docs/qa/01-acceptance-criteria.md" \
        "docs/qa/02-test-cases.md" \
        "docs/qa/03-edge-cases.md"
      ;;
    implementation)
      printf '%s\n' \
        ".agent-team/agent-results/implementation-worker.md"
      ;;
    qa)
      printf '%s\n' \
        "docs/qa/04-risk-review.md" \
        ".agent-team/agent-results/qa-risk-reviewer.md"
      ;;
    delivery)
      printf '%s\n' \
        "docs/qa/04-risk-review.md" \
        ".agent-team/agent-results/code-reviewer.md" \
        ".agent-team/phase-history.md"
      ;;
    *) die "unknown phase: $1" ;;
  esac
}

result_files_for_phase() {
  case "$(normalize_phase "$1")" in
    discovery) printf '%s\n' ".agent-team/agent-results/discovery-analyst.md" ;;
    scope) printf '%s\n' ".agent-team/agent-results/product-manager.md" ;;
    flow) printf '%s\n' ".agent-team/agent-results/ux-flow-designer.md" ;;
    requirements) printf '%s\n' ".agent-team/agent-results/product-manager.md" ;;
    blueprint)
      printf '%s\n' \
        ".agent-team/agent-results/solution-architect.md" \
        ".agent-team/agent-results/data-modeler.md"
      ;;
    implementation-plan) printf '%s\n' ".agent-team/agent-results/qa-risk-reviewer.md" ;;
    implementation) printf '%s\n' ".agent-team/agent-results/implementation-worker.md" ;;
    qa) printf '%s\n' ".agent-team/agent-results/qa-risk-reviewer.md" ;;
    delivery) printf '%s\n' ".agent-team/agent-results/code-reviewer.md" ;;
    *) ;;
  esac
}

roles_for_phase() {
  case "$(normalize_phase "$1")" in
    intake) printf '%s\n' "supervisor-orchestrator" ;;
    discovery) printf '%s\n' "discovery-analyst" ;;
    scope)
      printf '%s\n' "product-manager" "qa-risk-reviewer"
      ;;
    flow)
      printf '%s\n' "ux-flow-designer" "qa-risk-reviewer"
      ;;
    requirements)
      printf '%s\n' "product-manager" "qa-risk-reviewer"
      ;;
    blueprint)
      printf '%s\n' "solution-architect" "data-modeler" "qa-risk-reviewer"
      ;;
    implementation-plan)
      printf '%s\n' "qa-risk-reviewer"
      ;;
    implementation)
      printf '%s\n' "implementation-worker" "code-reviewer"
      ;;
    qa)
      printf '%s\n' "qa-risk-reviewer" "code-reviewer"
      ;;
    delivery)
      printf '%s\n' "qa-risk-reviewer"
      ;;
    *) die "unknown phase: $1" ;;
  esac
}

prompt_for_role() {
  case "$1" in
    supervisor-orchestrator) printf '%s\n' "supervisor.md" ;;
    *) printf '%s\n' "$1.md" ;;
  esac
}

config_path_for_package() {
  local package_root="$1"
  printf '%s\n' "$package_root/config/agent-team.json"
}

current_phase_for_project() {
  local target_dir="$1"
  if [ -f "$target_dir/.agent-team/config.json" ]; then
    python3 - "$target_dir/.agent-team/config.json" <<'PY' 2>/dev/null || true
import json
import sys

data = json.load(open(sys.argv[1]))
print(data.get("currentPhase", ""))
PY
    return 0
  fi
  if [ -f "$target_dir/.agent-team/current-phase.md" ]; then
    awk 'NR > 1 && $0 !~ /^#/ && $0 !~ /^$/ {print; exit}' "$target_dir/.agent-team/current-phase.md"
    return 0
  fi
}

preset_phase_from_config() {
  local config="$1"
  local preset="$2"
  python3 - "$config" "$preset" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
preset = sys.argv[2]
entry = data.get("presets", {}).get(preset)
if not entry:
    raise SystemExit(f"unknown preset: {preset}")
print(entry.get("phase", "current"))
PY
}

preset_agents_from_config() {
  local config="$1"
  local preset="$2"
  python3 - "$config" "$preset" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
preset = sys.argv[2]
entry = data.get("presets", {}).get(preset)
if not entry:
    raise SystemExit(f"unknown preset: {preset}")
for agent in entry.get("agents", []):
    print(agent)
PY
}

model_for_role_from_config() {
  local config="$1"
  local role="$2"
  local tier="$3"
  local effort="$4"
  python3 - "$config" "$role" "$tier" "$effort" <<'PY'
import json
import sys

config_path, role, tier, effort = sys.argv[1:5]
data = json.load(open(config_path))
roles = data.get("roles", {})
profiles = data.get("modelProfiles", {})
role_cfg = roles.get(role, {})
tier = tier or role_cfg.get("defaultTier") or "balanced"
effort = effort or role_cfg.get("defaultEffort") or "medium"
if tier not in profiles:
    raise SystemExit(f"unknown model tier: {tier}")
role_models = role_cfg.get("models", {})
model = role_models.get(tier) or profiles[tier].get("efforts", {}).get(effort)
if not model:
    raise SystemExit(f"no model for role={role} tier={tier} effort={effort}")
print(model)
PY
}

update_task_board_row() {
  local target_dir="$1"
  local task_id="$2"
  local phase="$3"
  local agent="$4"
  local task="$5"
  local status="$6"
  local artifact="$7"
  local blocker="${8:--}"
  local board="$target_dir/.agent-team/task-board.md"
  mkdir -p "$(dirname "$board")"
  if [ ! -f "$board" ]; then
    cat > "$board" <<'BOARD'
# Agent Task Board

| ID | Phase | Agent | Task | Status | Artifact | Blocker |
|---|---|---|---|---|---|---|
BOARD
  fi
  if grep -q "^| $task_id |" "$board"; then
    python3 - "$board" "$task_id" "$phase" "$agent" "$task" "$status" "$artifact" "$blocker" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
task_id, phase, agent, task, status, artifact, blocker = sys.argv[2:]
replacement = f"| {task_id} | {phase} | {agent} | {task} | {status} | {artifact} | {blocker} |"
lines = path.read_text().splitlines()
lines = [replacement if line.startswith(f"| {task_id} |") else line for line in lines]
path.write_text("\n".join(lines) + "\n")
PY
  else
    printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$task_id" "$phase" "$agent" "$task" "$status" "$artifact" "$blocker" >> "$board"
  fi
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    info "exists: $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  info "created: $dest"
}

file_has_real_content() {
  local file="$1"
  [ -s "$file" ] || return 1
  if grep -Eq '(^|[[:space:]])(TBD|TODO)([[:space:]]|$)|\[ \] TBD' "$file"; then
    return 1
  fi
  return 0
}

agent_result_has_contract() {
  local file="$1"
  local field
  for field in \
    "STATUS:" \
    "CONFIDENCE:" \
    "TASK_RECEIVED:" \
    "WHAT_I_DID:" \
    "ARTIFACTS_CREATED_OR_UPDATED:" \
    "KEY_DECISIONS:" \
    "ASSUMPTIONS:" \
    "RISKS:" \
    "TESTS_OR_CHECKS:" \
    "OPEN_QUESTIONS:" \
    "NEXT_RECOMMENDED_ACTION:"; do
    grep -q "^${field}" "$file" || return 1
  done
}
