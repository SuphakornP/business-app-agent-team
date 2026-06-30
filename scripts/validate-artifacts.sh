#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
PHASE="${2:-intake}"
TARGET_DIR="$(abs_dir "$TARGET")"
PHASE="$(normalize_phase "$PHASE")"
FAILURES=0

info "validating phase '$PHASE' in $TARGET_DIR"

check_file() {
  local rel="$1"
  local file="$TARGET_DIR/$rel"
  if [ ! -e "$file" ]; then
    printf 'missing: %s\n' "$rel" >&2
    FAILURES=$((FAILURES + 1))
    return
  fi
  if ! file_has_real_content "$file"; then
    printf 'incomplete_or_placeholder: %s\n' "$rel" >&2
    FAILURES=$((FAILURES + 1))
    return
  fi
  printf 'ok: %s\n' "$rel"
}

while IFS= read -r artifact; do
  [ -n "$artifact" ] || continue
  check_file "$artifact"
done <<EOF_ARTIFACTS
$(required_artifacts_for_phase "$PHASE")
EOF_ARTIFACTS

while IFS= read -r result; do
  [ -n "$result" ] || continue
  file="$TARGET_DIR/$result"
  if [ ! -e "$file" ]; then
    printf 'missing_result: %s\n' "$result" >&2
    FAILURES=$((FAILURES + 1))
    continue
  fi
  if ! agent_result_has_contract "$file"; then
    printf 'invalid_result_contract: %s\n' "$result" >&2
    FAILURES=$((FAILURES + 1))
  else
    printf 'ok_result_contract: %s\n' "$result"
  fi
done <<EOF_RESULTS
$(result_files_for_phase "$PHASE")
EOF_RESULTS

if [ -e "$TARGET_DIR/.agent-team/open-questions.md" ]; then
  if grep -Eq '\|[[:space:]]*Open[[:space:]]*\||- \[ \]' "$TARGET_DIR/.agent-team/open-questions.md"; then
    printf 'open_questions_present: .agent-team/open-questions.md\n' >&2
    FAILURES=$((FAILURES + 1))
  fi
fi

if [ "$FAILURES" -gt 0 ]; then
  die "phase '$PHASE' failed validation with $FAILURES issue(s)"
fi

info "phase '$PHASE' passed validation"
