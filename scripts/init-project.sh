#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
TARGET_DIR="$(abs_dir "$TARGET")"
PROJECT_NAME="$(basename "$TARGET_DIR")"
NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

info "initializing agent team state in: $TARGET_DIR"

mkdir -p \
  "$TARGET_DIR/.agent-team/agent-results" \
  "$TARGET_DIR/.agent-team/tasks" \
  "$TARGET_DIR/.agent-team/templates" \
  "$TARGET_DIR/docs/product" \
  "$TARGET_DIR/docs/ux" \
  "$TARGET_DIR/docs/architecture" \
  "$TARGET_DIR/docs/data" \
  "$TARGET_DIR/docs/qa" \
  "$TARGET_DIR/docs/agent"

copy_if_missing "$PACKAGE_ROOT/templates/00-intake.md" "$TARGET_DIR/docs/product/00-intake.md"
copy_if_missing "$PACKAGE_ROOT/templates/01-problem-scenario.md" "$TARGET_DIR/docs/product/01-discovery.md"
copy_if_missing "$PACKAGE_ROOT/templates/02-clarifying-questions.md" "$TARGET_DIR/docs/product/02-clarifying-questions.md"
copy_if_missing "$PACKAGE_ROOT/templates/03-use-cases.md" "$TARGET_DIR/docs/product/03-use-cases.md"
copy_if_missing "$PACKAGE_ROOT/templates/product-scope.md" "$TARGET_DIR/docs/product/04-scope.md"
copy_if_missing "$PACKAGE_ROOT/templates/06-requirements.md" "$TARGET_DIR/docs/product/05-requirements.md"
copy_if_missing "$PACKAGE_ROOT/templates/04-user-journey.md" "$TARGET_DIR/docs/ux/01-user-journey.md"
copy_if_missing "$PACKAGE_ROOT/templates/05-screen-flow.md" "$TARGET_DIR/docs/ux/02-screen-flow.md"
copy_if_missing "$PACKAGE_ROOT/templates/state-and-empty-cases.md" "$TARGET_DIR/docs/ux/03-state-and-empty-cases.md"
copy_if_missing "$PACKAGE_ROOT/templates/system-blueprint.md" "$TARGET_DIR/docs/architecture/01-system-blueprint.md"
copy_if_missing "$PACKAGE_ROOT/templates/08-api-contract.md" "$TARGET_DIR/docs/architecture/02-api-contract.md"
copy_if_missing "$PACKAGE_ROOT/templates/security-and-permission.md" "$TARGET_DIR/docs/architecture/03-security-and-permission.md"
copy_if_missing "$PACKAGE_ROOT/templates/07-data-model.md" "$TARGET_DIR/docs/data/01-entity-model.md"
copy_if_missing "$PACKAGE_ROOT/templates/07-data-model.md" "$TARGET_DIR/docs/data/02-data-dictionary.md"
copy_if_missing "$PACKAGE_ROOT/templates/07-data-model.md" "$TARGET_DIR/docs/data/03-migration-plan.md"
copy_if_missing "$PACKAGE_ROOT/templates/09-test-plan.md" "$TARGET_DIR/docs/qa/01-acceptance-criteria.md"
copy_if_missing "$PACKAGE_ROOT/templates/09-test-plan.md" "$TARGET_DIR/docs/qa/02-test-cases.md"
copy_if_missing "$PACKAGE_ROOT/templates/09-test-plan.md" "$TARGET_DIR/docs/qa/03-edge-cases.md"
copy_if_missing "$PACKAGE_ROOT/templates/risk-review.md" "$TARGET_DIR/docs/qa/04-risk-review.md"
copy_if_missing "$PACKAGE_ROOT/docs/agent/human-approval-policy.md" "$TARGET_DIR/docs/agent/human-approval-policy.md"

for template in "$PACKAGE_ROOT"/templates/*.md; do
  copy_if_missing "$template" "$TARGET_DIR/.agent-team/templates/$(basename "$template")"
done

if [ ! -e "$TARGET_DIR/.agent-team/state.md" ]; then
  cat > "$TARGET_DIR/.agent-team/state.md" <<STATE
# Agent Team State

## Project

$PROJECT_NAME

## Current Phase

intake

## Package Root

$PACKAGE_ROOT

## Last Updated

$NOW
STATE
  info "created: $TARGET_DIR/.agent-team/state.md"
else
  info "exists: $TARGET_DIR/.agent-team/state.md"
fi

if [ ! -e "$TARGET_DIR/.agent-team/current-phase.md" ]; then
  cat > "$TARGET_DIR/.agent-team/current-phase.md" <<PHASE
# Current Phase

intake

## Gate

$(phase_gate intake)

## Status

open
PHASE
  info "created: $TARGET_DIR/.agent-team/current-phase.md"
else
  info "exists: $TARGET_DIR/.agent-team/current-phase.md"
fi

copy_if_missing "$PACKAGE_ROOT/templates/task-board.md" "$TARGET_DIR/.agent-team/task-board.md"
copy_if_missing "$PACKAGE_ROOT/templates/decision-log.md" "$TARGET_DIR/.agent-team/decision-log.md"
copy_if_missing "$PACKAGE_ROOT/templates/risk-register.md" "$TARGET_DIR/.agent-team/risk-register.md"
copy_if_missing "$PACKAGE_ROOT/templates/open-questions.md" "$TARGET_DIR/.agent-team/open-questions.md"
copy_if_missing "$PACKAGE_ROOT/templates/phase-history.md" "$TARGET_DIR/.agent-team/phase-history.md"
copy_if_missing "$PACKAGE_ROOT/templates/supervisor-status.md" "$TARGET_DIR/.agent-team/supervisor-status.md"

if [ ! -e "$TARGET_DIR/.agent-team/config.json" ]; then
  cat > "$TARGET_DIR/.agent-team/config.json" <<JSON
{
  "packageRoot": "$PACKAGE_ROOT",
  "project": "$PROJECT_NAME",
  "currentPhase": "intake",
  "createdAt": "$NOW",
  "roles": [
    "supervisor-orchestrator",
    "discovery-analyst",
    "product-manager",
    "ux-flow-designer",
    "solution-architect",
    "data-modeler",
    "qa-risk-reviewer",
    "implementation-worker",
    "code-reviewer"
  ]
}
JSON
  info "created: $TARGET_DIR/.agent-team/config.json"
else
  info "exists: $TARGET_DIR/.agent-team/config.json"
fi

info "done"
