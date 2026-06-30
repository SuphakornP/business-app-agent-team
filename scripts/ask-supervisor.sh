#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
QUESTION="${2:-งานถึงไหนแล้ว ตอนนี้ทำอะไรอยู่ มี blocker หรือไม่}"
SEND=1
SUPERVISOR_NAME="supervisor-orchestrator"

shift $(( $# >= 1 ? 1 : 0 ))
if [ "$#" -gt 0 ] && [[ "${1:-}" != --* ]]; then
  QUESTION="$1"
  shift
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-send)
      SEND=0
      shift
      ;;
    --supervisor)
      SUPERVISOR_NAME="${2:-}"
      [ -n "$SUPERVISOR_NAME" ] || die "--supervisor requires a value"
      shift 2
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

TARGET_DIR="$(abs_dir "$TARGET")"
NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p "$TARGET_DIR/.agent-team"

cat >> "$TARGET_DIR/.agent-team/supervisor-questions.md" <<QUESTION_LOG

## $NOW

$QUESTION
QUESTION_LOG

cat > "$TARGET_DIR/.agent-team/supervisor-status-request.md" <<REQUEST
# Supervisor Status Request

Requested: $NOW
Question: $QUESTION

## Required Response

Please answer the human with:

- Current phase
- Active agents and what each is doing
- Latest completed artifacts
- Blockers or open questions
- Next expected step
- ETA or confidence, if known

Also update .agent-team/supervisor-status.md.
REQUEST

info "Local status snapshot"
info "---------------------"
"$SCRIPT_DIR/collect-agent-status.sh" "$TARGET_DIR"

if [ "$SEND" -eq 0 ]; then
  exit 0
fi

if ! command -v herdr >/dev/null 2>&1; then
  info ""
  info "Herdr CLI not found; status request was recorded locally only."
  exit 0
fi

MESSAGE="[STATUS_REQ]
Human question: $QUESTION
Project: $TARGET_DIR
Read: $TARGET_DIR/.agent-team/supervisor-status-request.md
Reply with a concise progress summary and update .agent-team/supervisor-status.md."

set +e
herdr agent send "$SUPERVISOR_NAME" "$MESSAGE" >/tmp/agent-team-ask-supervisor.out 2>/tmp/agent-team-ask-supervisor.err
rc=$?
set -e

if [ "$rc" -eq 0 ]; then
  info ""
  info "Sent status request to Herdr agent: $SUPERVISOR_NAME"
  exit 0
fi

if [ "$SUPERVISOR_NAME" != "supervisor" ]; then
  set +e
  herdr agent send "supervisor" "$MESSAGE" >/tmp/agent-team-ask-supervisor.out 2>/tmp/agent-team-ask-supervisor.err
  rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    info ""
    info "Sent status request to Herdr agent: supervisor"
    exit 0
  fi
fi

info ""
info "Could not send to a supervisor agent. Request was recorded at:"
info "$TARGET_DIR/.agent-team/supervisor-status-request.md"
info "Herdr error:"
sed -n '1,20p' /tmp/agent-team-ask-supervisor.err
