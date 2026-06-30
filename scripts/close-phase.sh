#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="${1:-.}"
PHASE="${2:-intake}"
NEXT="${3:-}"
TARGET_DIR="$(abs_dir "$TARGET")"
PHASE="$(normalize_phase "$PHASE")"
NEXT="${NEXT:-$(next_phase "$PHASE")}"
NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

"$SCRIPT_DIR/validate-artifacts.sh" "$TARGET_DIR" "$PHASE"

cat >> "$TARGET_DIR/.agent-team/phase-history.md" <<HISTORY
| $NOW | $PHASE | closed | validation passed | Next: $NEXT |
HISTORY

cat > "$TARGET_DIR/.agent-team/current-phase.md" <<PHASE_FILE
# Current Phase

$NEXT

## Gate

$(phase_gate "$NEXT")

## Status

open
PHASE_FILE

python3 - "$TARGET_DIR/.agent-team/config.json" "$NEXT" "$NOW" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
next_phase = sys.argv[2]
now = sys.argv[3]
data = json.loads(path.read_text())
data["currentPhase"] = next_phase
data["updatedAt"] = now
path.write_text(json.dumps(data, indent=2) + "\n")
PY

info "closed phase '$PHASE'; current phase is '$NEXT'"
