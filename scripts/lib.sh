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
