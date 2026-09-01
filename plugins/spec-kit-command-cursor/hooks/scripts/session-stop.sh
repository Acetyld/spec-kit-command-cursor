#!/bin/sh
# Fail-open: never block, never /sdd-complete. Touch a checkpoint timestamp if one exists.
set -f
payload=$(cat)

if command -v python3 >/dev/null 2>&1; then
  python3 - "$payload" <<'PY' || exit 0
import json, os, sys, datetime
raw = sys.argv[1] if len(sys.argv) > 1 else "{}"
try:
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    data = {}
cwd = (
    (data.get("cwd") if isinstance(data, dict) else None)
    or os.environ.get("CURSOR_PROJECT_DIR")
    or os.getcwd()
)
if not cwd or not os.path.isdir(str(cwd)):
    sys.exit(0)
stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
note = f"\n- hook session stop {stamp}\n"

def walk(base):
    if not os.path.isdir(base):
        return
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in (".git", "node_modules")]
        if "execution-checkpoint.json" in files:
            path = os.path.join(root, "execution-checkpoint.json")
            try:
                with open(path, encoding="utf-8") as f:
                    ck = json.load(f)
                if isinstance(ck, dict):
                    ck["lastSessionStop"] = stamp
                    with open(path, "w", encoding="utf-8") as f:
                        json.dump(ck, f, indent=2)
                        f.write("\n")
            except Exception:
                pass
            return
        if "todo-list.md" in files:
            path = os.path.join(root, "todo-list.md")
            try:
                with open(path, "a", encoding="utf-8") as f:
                    f.write(note)
            except Exception:
                pass
            return

walk(os.path.join(cwd, "specs"))
sys.exit(0)
PY
fi
exit 0
