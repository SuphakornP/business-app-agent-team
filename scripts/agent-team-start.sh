#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
. "$SCRIPT_DIR/lib.sh"

TARGET="."
PHASE=""
PRESET="auto"
ROLE_CSV=""
TIER="strong"
EFFORT="high"
GOAL=""
EXECUTE=0
INIT_IF_MISSING=1

usage() {
  cat <<'USAGE'
Usage: agent-team-start [project-path] [options]

Options:
  --phase <phase>          intake|discovery|scope|flow|blueprint|implementation|qa|delivery
  --preset <preset>        auto|discovery|planning|flow|blueprint|implementation|review
  --agents <a,b,c>         explicit agent list
  --tier <tier>            free|balanced|strong (default: strong)
  --effort <effort>        low|medium|high (default: high)
  --goal <text>            human goal for spawned workers
  --execute                start Herdr/Pi agents
  --dry-run                prepare tasks only (default)
  --no-init                fail if .agent-team is missing
USAGE
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "$#" -gt 0 ] && [[ "${1:-}" != --* ]]; then
  TARGET="$1"
  shift
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --phase)
      PHASE="$(normalize_phase "${2:-}")"
      [ -n "$PHASE" ] || die "--phase requires a value"
      shift 2
      ;;
    --preset)
      PRESET="${2:-}"
      [ -n "$PRESET" ] || die "--preset requires a value"
      shift 2
      ;;
    --agents|--roles)
      ROLE_CSV="${2:-}"
      [ -n "$ROLE_CSV" ] || die "$1 requires a comma-separated value"
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
    --goal)
      GOAL="${2:-}"
      [ -n "$GOAL" ] || die "--goal requires a value"
      shift 2
      ;;
    --execute)
      EXECUTE=1
      shift
      ;;
    --dry-run)
      EXECUTE=0
      shift
      ;;
    --no-init)
      INIT_IF_MISSING=0
      shift
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

TARGET_DIR="$(abs_dir "$TARGET")"
CONFIG_PATH="$(config_path_for_package "$PACKAGE_ROOT")"

if [ ! -d "$TARGET_DIR/.agent-team" ]; then
  if [ "$INIT_IF_MISSING" -eq 1 ]; then
    "$SCRIPT_DIR/init-project.sh" "$TARGET_DIR"
  else
    die ".agent-team is missing in $TARGET_DIR"
  fi
fi

if [ -z "$PHASE" ]; then
  preset_phase="$(preset_phase_from_config "$CONFIG_PATH" "$PRESET")"
  if [ "$preset_phase" = "current" ]; then
    PHASE="$(current_phase_for_project "$TARGET_DIR")"
    PHASE="${PHASE:-discovery}"
  else
    PHASE="$preset_phase"
  fi
fi
PHASE="$(normalize_phase "$PHASE")"

if [ "$PRESET" = "auto" ]; then
  case "$PHASE" in
    discovery) PRESET="discovery" ;;
    scope|requirements) PRESET="planning" ;;
    flow) PRESET="flow" ;;
    blueprint) PRESET="blueprint" ;;
    implementation) PRESET="implementation" ;;
    qa|delivery) PRESET="review" ;;
    *) PRESET="discovery" ;;
  esac
fi

NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p "$TARGET_DIR/.agent-team"
cat > "$TARGET_DIR/.agent-team/current-phase.md" <<PHASE_FILE
# Current Phase

$PHASE

## Gate

$(phase_gate "$PHASE")

## Status

open
PHASE_FILE

if [ -f "$TARGET_DIR/.agent-team/config.json" ]; then
  python3 - "$TARGET_DIR/.agent-team/config.json" "$PHASE" "$NOW" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
phase = sys.argv[2]
now = sys.argv[3]
data = json.loads(path.read_text())
data["currentPhase"] = phase
data["updatedAt"] = now
path.write_text(json.dumps(data, indent=2) + "\n")
PY
fi

cat > "$TARGET_DIR/.agent-team/last-run.md" <<RUN
# Last Agent Team Run

Started: $NOW
Project: $TARGET_DIR
Phase: $PHASE
Preset: $PRESET
Tier: $TIER
Effort: $EFFORT
Mode: $([ "$EXECUTE" -eq 1 ] && printf execute || printf dry-run)

## Goal

${GOAL:-No explicit goal provided.}
RUN

info "Agent team start"
info "project: $TARGET_DIR"
info "phase: $PHASE"
info "preset: $PRESET"
info "tier: $TIER"
info "effort: $EFFORT"
if [ -n "$GOAL" ]; then
  info "goal: $GOAL"
fi

spawn_args=("$TARGET_DIR" "$PHASE" "--preset" "$PRESET" "--tier" "$TIER" "--effort" "$EFFORT")
if [ -n "$ROLE_CSV" ]; then
  spawn_args+=("--roles" "$ROLE_CSV")
fi
if [ -n "$GOAL" ]; then
  spawn_args+=("--goal" "$GOAL")
fi
if [ "$EXECUTE" -eq 1 ]; then
  spawn_args+=("--execute")
else
  spawn_args+=("--dry-run")
fi

"$SCRIPT_DIR/spawn-agent-team.sh" "${spawn_args[@]}"

info ""
info "Ask progress later with:"
info "  agent-team-ask \"$TARGET_DIR\" \"งานถึงไหนแล้ว\""
