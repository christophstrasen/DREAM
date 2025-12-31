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
PZ_WORKSHOP_DIR="${PZ_WORKSHOP_DIR:-$HOME/Zomboid/Workshop}"

missing=()
for p in \
  "$PZ_MODS_DIR/reactivex/42/media/lua/shared" \
  "$PZ_MODS_DIR/LQR/42/media/lua/shared" \
  "$PZ_MODS_DIR/DREAMBase/42/media/lua/shared"; do
  if [ "$SOURCE" != "mods" ]; then
    break
  fi
  if [ ! -d "$p" ]; then
    missing+=("$p")
  fi
done

for p in \
  "$PZ_WORKSHOP_DIR/reactivex/Contents/mods/reactivex/42/media/lua/shared" \
  "$PZ_WORKSHOP_DIR/LQR/Contents/mods/LQR/42/media/lua/shared" \
  "$PZ_WORKSHOP_DIR/DREAMBase/Contents/mods/DREAMBase/42/media/lua/shared"; do
  if [ "$SOURCE" != "workshop" ]; then
    break
  fi
  if [ ! -d "$p" ]; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "[smoke] missing dependencies for SOURCE=$SOURCE; syncing TARGET=$SOURCE first:"
  printf '  - %s\n' "${missing[@]}"
  TARGET="$SOURCE" "$REPO_ROOT/dev/sync-all.sh"
fi

(cd "$REPO_ROOT/external/WorldObserver" && SOURCE="$SOURCE" ./dev/smoke.sh)

if [ -f "$REPO_ROOT/external/DREAMBase/dev/smoke.sh" ]; then
  (cd "$REPO_ROOT/external/DREAMBase" && ./dev/smoke.sh)
else
  echo "[warn] missing DREAMBase smoke script: external/DREAMBase/dev/smoke.sh"
fi
