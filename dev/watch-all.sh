#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

TARGET="${TARGET:-workshop}" # mods|workshop
WATCH_MODE="${WATCH_MODE:-payload}" # payload|repo
VERBOSE="${VERBOSE:-0}"

sync_all() {
  "$REPO_ROOT/dev/sync-all.sh"
}

watch_paths_payload() {
  cat <<EOF
$REPO_ROOT/external/WorldObserver/Contents/mods/WorldObserver
$REPO_ROOT/external/WorldObserver/workshop.txt
$REPO_ROOT/external/WorldObserver/preview.png
$REPO_ROOT/external/WorldObserver/256.svg
$REPO_ROOT/external/WorldObserver/512.svg
$REPO_ROOT/external/WorldObserver/64.svg

$REPO_ROOT/external/PromiseKeeper/Contents/mods/PromiseKeeper
$REPO_ROOT/external/PromiseKeeper/workshop.txt
$REPO_ROOT/external/PromiseKeeper/preview.png
$REPO_ROOT/external/PromiseKeeper/256.svg
$REPO_ROOT/external/PromiseKeeper/512.svg
$REPO_ROOT/external/PromiseKeeper/64.svg

$REPO_ROOT/external/SceneBuilder/Contents/mods/SceneBuilder
$REPO_ROOT/external/SceneBuilder/workshop.txt
$REPO_ROOT/external/SceneBuilder/preview.png
$REPO_ROOT/external/SceneBuilder/256.svg
$REPO_ROOT/external/SceneBuilder/512.svg
$REPO_ROOT/external/SceneBuilder/64.svg

$REPO_ROOT/external/pz-reactivex/Contents/mods/reactivex
$REPO_ROOT/external/pz-reactivex/workshop.txt
$REPO_ROOT/external/pz-reactivex/preview.png
$REPO_ROOT/external/pz-reactivex/256.svg
$REPO_ROOT/external/pz-reactivex/512.svg
$REPO_ROOT/external/pz-reactivex/64.svg
$REPO_ROOT/external/pz-reactivex/external/lua-reactivex

$REPO_ROOT/external/pz-lqr/Contents/mods/LQR
$REPO_ROOT/external/pz-lqr/workshop.txt
$REPO_ROOT/external/pz-lqr/preview.png
$REPO_ROOT/external/pz-lqr/256.svg
$REPO_ROOT/external/pz-lqr/512.svg
$REPO_ROOT/external/pz-lqr/64.svg
$REPO_ROOT/external/pz-lqr/external/LQR

$REPO_ROOT/external/pz-dream/Contents/mods/DREAM
$REPO_ROOT/external/pz-dream/workshop.txt
$REPO_ROOT/external/pz-dream/preview.png
$REPO_ROOT/external/pz-dream/256.svg
$REPO_ROOT/external/pz-dream/512.svg
$REPO_ROOT/external/pz-dream/64.svg
EOF
}

if ! command -v inotifywait >/dev/null; then
  echo "[error] inotifywait not found; install inotify-tools or use each repo's dev/watch.sh"
  exit 1
fi

echo "Watching all mods (TARGET=$TARGET, WATCH_MODE=$WATCH_MODE)…"
sync_all

case "$WATCH_MODE" in
  payload)
    mapfile -t WATCH_PATHS < <(watch_paths_payload | sed '/^$/d')
    ;;
  repo)
    WATCH_PATHS=("$REPO_ROOT/external")
    ;;
  *)
    echo "[error] unknown WATCH_MODE='$WATCH_MODE' (expected 'payload' or 'repo')"
    exit 1
    ;;
esac

echo "Watching paths:"
printf '  - %s\n' "${WATCH_PATHS[@]}"

# Avoid `attrib` events: some tooling updates atime/metadata on read, which can self-trigger loops.
# Avoid `modify` events: they can fire many times during a single save; `close_write`/`move` is enough.
inotifywait -m -q -r -e close_write,create,delete,move \
  --format '%w%f' \
  "${WATCH_PATHS[@]}" 2>/dev/null |
  while IFS= read -r path; do
    if [ "$VERBOSE" = "1" ]; then
      echo "[change] $path"
    fi

    # Coalesce short bursts of file events into a single sync run.
    # (Editors often trigger multiple events per save.)
    while IFS= read -r -t 0.1 path; do
      if [ "$VERBOSE" = "1" ]; then
        echo "[change] $path"
      fi
    done

    sync_all
  done
