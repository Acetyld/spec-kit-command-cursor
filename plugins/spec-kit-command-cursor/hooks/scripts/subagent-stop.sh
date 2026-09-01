#!/bin/sh
# Fail-open: never block the agent. Writes a short note when a verifier (or task-id) stops.
set -f
payload=$(cat)
[ -z "$payload" ] && exit 0

if command -v python3 >/dev/null 2>&1; then
  python3 - "$payload" <<'PY' || exit 0
import json, os, sys, datetime
raw = sys.argv[1] if len(sys.argv) > 1 else ""
try:
    data = json.loads(raw)
except Exception:
    sys.exit(0)
if not isinstance(data, dict):
    sys.exit(0)

sub = str(
    data.get("subagent_type")
    or data.get("subagentType")
    or data.get("subagent")
    or data.get("agent_type")
    or ""
)
prompt = str(data.get("prompt") or data.get("task") or "")
blob = (sub + " " + prompt).lower()
if "sdd-verifier" not in blob and "task-" not in blob and "verifier" not in sub.lower():
    sys.exit(0)

cwd = (
    data.get("cwd")
    or data.get("workspace")
    or (data.get("workspace_roots") or [None])[0]
    or os.environ.get("CURSOR_PROJECT_DIR")
    or os.getcwd()
)
if not cwd or not os.path.isdir(str(cwd)):
    sys.exit(0)

stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
line = f"\n- hook subagentStop {stamp} type={sub or 'unknown'}\n"

def append_if_exists(path):
    if os.path.isfile(path):
        with open(path, "a", encoding="utf-8") as f:
            f.write(line)
        return True
    return False

# Prefer existing SDD logs; never create a new tree.
for root, dirs, files in os.walk(os.path.join(cwd, "specs"), topdown=True):
    dirs[:] = [d for d in dirs if d not in (".git", "node_modules")]
    if "progress.md" in files:
        append_if_exists(os.path.join(root, "progress.md"))
        sys.exit(0)
    if "execution-log.md" in files:
        append_if_exists(os.path.join(root, "execution-log.md"))
        sys.exit(0)
sys.exit(0)
PY
fi
exit 0
