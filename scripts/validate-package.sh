#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

echo "validating JSON files"
python3 - "$PACKAGE_ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
json_files = [root / "package.json"]
json_files.extend(sorted((root / "schemas").glob("*.json")))
json_files.extend(sorted((root / "config").glob("*.json")))
for path in json_files:
    json.loads(path.read_text())
    print(f"ok: {path.relative_to(root)}")
PY

echo "validating shell syntax"
for script in "$PACKAGE_ROOT"/scripts/*.sh; do
  bash -n "$script"
  echo "ok: ${script#$PACKAGE_ROOT/}"
done

echo "validating skills"
python3 - "$PACKAGE_ROOT" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
for skill in sorted((root / "skills").iterdir()):
    if not skill.is_dir():
        continue
    path = skill / "SKILL.md"
    if not path.exists():
        raise SystemExit(f"missing SKILL.md: {skill.relative_to(root)}")
    text = path.read_text()
    match = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not match:
        raise SystemExit(f"invalid frontmatter: {path.relative_to(root)}")
    frontmatter = match.group(1)
    fields = {}
    for line in frontmatter.splitlines():
        if ":" not in line:
            raise SystemExit(f"invalid frontmatter line in {path.relative_to(root)}: {line}")
        key, value = line.split(":", 1)
        fields[key.strip()] = value.strip()
    name = fields.get("name", "")
    description = fields.get("description", "")
    if not re.match(r"^[a-z0-9-]{1,64}$", name):
        raise SystemExit(f"invalid skill name in {path.relative_to(root)}: {name}")
    if not description or "TODO" in description or len(description) > 1024:
        raise SystemExit(f"invalid skill description in {path.relative_to(root)}")
    print(f"ok: {skill.relative_to(root)}")
PY

echo "package validation passed"
