#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -f "$REPO_ROOT/external/WorldObserver/dev/smoke.sh" ]; then
  echo "[error] missing WorldObserver smoke script (did you init submodules?): external/WorldObserver/dev/smoke.sh"
  exit 1
fi

SOURCE="${SOURCE:-workshop}" # mods|workshop

PZ_MODS_DIR="${PZ_MODS_DIR:-$HOME/Zomboid/mods}"

missing=()
for p in \
  "$PZ_MODS_DIR/reactivex/42/media/lua/shared" \
  "$PZ_MODS_DIR/LQR/42/media/lua/shared" \
  "$PZ_MODS_DIR/DREAMBase/42/media/lua/shared"; do
  if [ ! -d "$p" ]; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "[smoke] missing dependencies under PZ_MODS_DIR; syncing TARGET=mods first:"
  printf '  - %s\n' "${missing[@]}"
  TARGET=mods "$REPO_ROOT/dev/sync-all.sh"
fi

(cd "$REPO_ROOT/external/WorldObserver" && SOURCE="$SOURCE" ./dev/smoke.sh)
