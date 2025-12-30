#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -f "$REPO_ROOT/external/WorldObserver/dev/smoke.sh" ]; then
  echo "[error] missing WorldObserver smoke script (did you init submodules?): external/WorldObserver/dev/smoke.sh"
  exit 1
fi

(cd "$REPO_ROOT/external/WorldObserver" && ./dev/smoke.sh)

