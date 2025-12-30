#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

TARGET="${TARGET:-workshop}" # mods|workshop

ensure_nested_submodules() {
  # The packaging repos use upstream sources as nested submodules.
  # We initialize only the required nested submodules (not a full --recursive).
  if [ -d "$REPO_ROOT/external/pz-reactivex" ] && [ ! -d "$REPO_ROOT/external/pz-reactivex/external/lua-reactivex/reactivex" ]; then
    echo "[init] pz-reactivex nested submodule external/lua-reactivex"
    (cd "$REPO_ROOT/external/pz-reactivex" && git submodule update --init external/lua-reactivex)
  fi
  if [ -d "$REPO_ROOT/external/pz-lqr" ] && [ ! -d "$REPO_ROOT/external/pz-lqr/external/LQR/LQR" ]; then
    echo "[init] pz-lqr nested submodule external/LQR"
    (cd "$REPO_ROOT/external/pz-lqr" && git submodule update --init external/LQR)
  fi
}

run_sync() {
  local repo="$1"
  local label="$2"

  local script="$REPO_ROOT/external/$repo/dev/sync-$TARGET.sh"
  if [ ! -f "$script" ]; then
    echo "[error] missing $label script: $script"
    exit 1
  fi

  (cd "$REPO_ROOT/external/$repo" && "$script")
}

ensure_nested_submodules

run_sync "WorldObserver" "WorldObserver"
run_sync "PromiseKeeper" "PromiseKeeper"
run_sync "pz-reactivex" "reactivex"
run_sync "pz-lqr" "LQR"
run_sync "pz-dream" "DREAM"

echo "[ok] synced all (TARGET=$TARGET)"
