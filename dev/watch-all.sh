#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

WATCH_MODE="${WATCH_MODE:-payload}" # payload|repo
VERBOSE="${VERBOSE:-0}"
RUN_ONCE="${RUN_ONCE:-0}" # 1 = run pipeline once, then exit (no watch)

RUN_ASSETS="${RUN_ASSETS:-1}"
RUN_LINT="${RUN_LINT:-1}"
RUN_TESTS="${RUN_TESTS:-1}"
RUN_SYNC="${RUN_SYNC:-1}"
RUN_SMOKE="${RUN_SMOKE:-1}"

COLOR="${COLOR:-auto}" # auto|1|0

if [ "$COLOR" = "auto" ]; then
  if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ] && [ -z "${NO_COLOR:-}" ]; then
    COLOR="1"
  else
    COLOR="0"
  fi
fi

if [ "$COLOR" = "1" ]; then
  C_RESET=$'\033[0m'
  C_GREEN=$'\033[32m'
  C_RED=$'\033[31m'
  C_YELLOW=$'\033[33m'
  C_DIM=$'\033[2m'
else
  C_RESET=""
  C_GREEN=""
  C_RED=""
  C_YELLOW=""
  C_DIM=""
fi

REPOS=(
  "WorldObserver"
  "PromiseKeeper"
  "SceneBuilder"
  "DREAMBase"
  "pz-reactivex"
  "pz-lqr"
  "pz-dream"
)

declare -A REPO_PATH=(
  ["WorldObserver"]="$REPO_ROOT/external/WorldObserver"
  ["PromiseKeeper"]="$REPO_ROOT/external/PromiseKeeper"
  ["SceneBuilder"]="$REPO_ROOT/external/SceneBuilder"
  ["DREAMBase"]="$REPO_ROOT/external/DREAMBase"
  ["pz-reactivex"]="$REPO_ROOT/external/pz-reactivex"
  ["pz-lqr"]="$REPO_ROOT/external/pz-lqr"
  ["pz-dream"]="$REPO_ROOT/external/pz-dream"
)

declare -A STATUS_ASSETS STATUS_LINT STATUS_TESTS STATUS_SYNC STATUS_SMOKE

run_counter=0
print_run_header() {
  run_counter=$((run_counter + 1))
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || true)"
  if [ -n "$ts" ]; then
    echo "${C_DIM}--- run #$run_counter @ $ts ---${C_RESET}"
  else
    echo "${C_DIM}--- run #$run_counter ---${C_RESET}"
  fi
}

init_statuses() {
  for repo in "${REPOS[@]}"; do
    STATUS_ASSETS["$repo"]="-"
    STATUS_LINT["$repo"]="-"
    STATUS_TESTS["$repo"]="-"
    STATUS_SYNC["$repo"]="-"
    STATUS_SMOKE["$repo"]="-"
  done
}

tmp_root=""
ensure_tmp_root() {
  if [ -n "${tmp_root:-}" ]; then
    return 0
  fi
  tmp_root="$(mktemp -d)"
  trap 'rm -rf "$tmp_root"' EXIT
}

run_cmd() {
  local repo="$1"
  local step="$2"
  local cwd="$3"
  shift 3

  ensure_tmp_root
  local log="$tmp_root/${repo//\//_}.${step}.log"

  if (cd "$cwd" && "$@") >"$log" 2>&1; then
    return 0
  fi

  local code=$?
  echo "${C_RED}[error]${C_RESET} $repo $step failed (exit=$code)"
  sed 's/^/  | /' "$log"
  return 1
}

status_cell() {
  local value="$1"
  local colored="$value"

  case "$value" in
    ok) colored="${C_GREEN}${value}${C_RESET}" ;;
    fail) colored="${C_RED}${value}${C_RESET}" ;;
    -) colored="${C_DIM}${value}${C_RESET}" ;;
    *) colored="${C_YELLOW}${value}${C_RESET}" ;;
  esac

  local pad=$((4 - ${#value}))
  if [ "$pad" -gt 0 ]; then
    printf '%s%*s' "$colored" "$pad" ""
  else
    printf '%s' "$colored"
  fi
}

run_assets() {
  local repo="$1"
  local root="${REPO_PATH[$repo]}"
  if [ "$RUN_ASSETS" != "1" ]; then
    STATUS_ASSETS["$repo"]="-"
    return 0
  fi
  if [ ! -f "$root/dev/build-assets.sh" ]; then
    STATUS_ASSETS["$repo"]="-"
    return 0
  fi
  if run_cmd "$repo" "assets" "$root" ./dev/build-assets.sh; then
    STATUS_ASSETS["$repo"]="ok"
  else
    STATUS_ASSETS["$repo"]="fail"
  fi
}

run_lint() {
  local repo="$1"
  local root="${REPO_PATH[$repo]}"
  if [ "$RUN_LINT" != "1" ]; then
    STATUS_LINT["$repo"]="-"
    return 0
  fi

  case "$repo" in
    WorldObserver)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/WorldObserver/42/media/lua/shared/WorldObserver \
        Contents/mods/WorldObserver/42/media/lua/shared/WorldObserver.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    PromiseKeeper)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/PromiseKeeper/42/media/lua/shared/PromiseKeeper \
        Contents/mods/PromiseKeeper/42/media/lua/shared/PromiseKeeper.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    SceneBuilder)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/SceneBuilder/42/media/lua/shared/SceneBuilder \
        Contents/mods/SceneBuilder/42/media/lua/shared/SceneBuilder.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    DREAMBase)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase \
        Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    pz-reactivex)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/reactivex/42/media/lua/shared/reactivex \
        Contents/mods/reactivex/42/media/lua/shared/reactivex.lua \
        Contents/mods/reactivex/42/media/lua/shared/operators.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    pz-lqr)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/LQR/42/media/lua/shared/LQR \
        Contents/mods/LQR/42/media/lua/shared/LQR.lua; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    pz-dream)
      if run_cmd "$repo" "lint" "$root" luacheck \
        Contents/mods/DREAM/42/media/lua/shared/examples; then
        STATUS_LINT["$repo"]="ok"
      else
        STATUS_LINT["$repo"]="fail"
      fi
      ;;
    *)
      STATUS_LINT["$repo"]="-"
      ;;
  esac
}

run_tests() {
  local repo="$1"
  local root="${REPO_PATH[$repo]}"
  if [ "$RUN_TESTS" != "1" ]; then
    STATUS_TESTS["$repo"]="-"
    return 0
  fi

  case "$repo" in
    WorldObserver|PromiseKeeper|SceneBuilder|DREAMBase|pz-dream)
      if [ ! -d "$root/tests/unit" ] || [ ! -f "$root/tests/helper.lua" ]; then
        STATUS_TESTS["$repo"]="-"
        return 0
      fi
      if run_cmd "$repo" "tests" "$root" busted --helper=tests/helper.lua tests/unit; then
        STATUS_TESTS["$repo"]="ok"
      else
        STATUS_TESTS["$repo"]="fail"
      fi
      ;;
    pz-reactivex)
      if [ ! -f "$root/external/lua-reactivex/tests/runner.lua" ]; then
        STATUS_TESTS["$repo"]="-"
        return 0
      fi
      if run_cmd "$repo" "tests" "$root/external/lua-reactivex" lua tests/runner.lua; then
        STATUS_TESTS["$repo"]="ok"
      else
        STATUS_TESTS["$repo"]="fail"
      fi
      ;;
    pz-lqr)
      if [ ! -d "$root/external/LQR/tests/unit" ]; then
        STATUS_TESTS["$repo"]="-"
        return 0
      fi
      if run_cmd "$repo" "tests" "$root/external/LQR" busted tests/unit; then
        STATUS_TESTS["$repo"]="ok"
      else
        STATUS_TESTS["$repo"]="fail"
      fi
      ;;
    *)
      STATUS_TESTS["$repo"]="-"
      ;;
  esac
}

run_sync() {
  local repo="$1"
  local root="${REPO_PATH[$repo]}"
  if [ "$RUN_SYNC" != "1" ]; then
    STATUS_SYNC["$repo"]="-"
    return 0
  fi

  local script="$root/dev/sync-workshop.sh"
  if [ ! -f "$script" ]; then
    echo "[error] missing sync script for $repo: $script"
    STATUS_SYNC["$repo"]="fail"
    return 0
  fi
  if run_cmd "$repo" "sync" "$root" "$script"; then
    STATUS_SYNC["$repo"]="ok"
  else
    STATUS_SYNC["$repo"]="fail"
  fi
}

ensure_nested_submodules() {
  if [ -d "$REPO_ROOT/external/pz-reactivex" ] && [ ! -d "$REPO_ROOT/external/pz-reactivex/external/lua-reactivex/reactivex" ]; then
    if ! run_cmd "workspace" "init" "$REPO_ROOT/external/pz-reactivex" git submodule update --init external/lua-reactivex; then
      echo "[warn] failed to init pz-reactivex nested submodule external/lua-reactivex"
    fi
  fi
  if [ -d "$REPO_ROOT/external/pz-lqr" ] && [ ! -d "$REPO_ROOT/external/pz-lqr/external/LQR/LQR" ]; then
    if ! run_cmd "workspace" "init" "$REPO_ROOT/external/pz-lqr" git submodule update --init external/LQR; then
      echo "[warn] failed to init pz-lqr nested submodule external/LQR"
    fi
  fi
}

run_smoke() {
  if [ "$RUN_SMOKE" != "1" ]; then
    return 0
  fi

  local wo_root="${REPO_PATH[WorldObserver]}"
  local db_root="${REPO_PATH[DREAMBase]}"

  local wo_smoke="-"
  local db_smoke="-"

  if [ -f "$wo_root/dev/smoke.sh" ]; then
    if run_cmd "WorldObserver" "smoke" "$wo_root" env "SOURCE=workshop" ./dev/smoke.sh; then
      wo_smoke="ok"
    else
      wo_smoke="fail"
    fi
  fi

  if [ -f "$db_root/dev/smoke.sh" ]; then
    if run_cmd "DREAMBase" "smoke" "$db_root" env "SOURCE=workshop" ./dev/smoke.sh; then
      db_smoke="ok"
    else
      db_smoke="fail"
    fi
  fi

  # Assign smoke status to repos that are actually covered.
  STATUS_SMOKE["WorldObserver"]="$wo_smoke"
  STATUS_SMOKE["pz-reactivex"]="$wo_smoke"
  STATUS_SMOKE["pz-lqr"]="$wo_smoke"

  STATUS_SMOKE["DREAMBase"]="$db_smoke"
  STATUS_SMOKE["PromiseKeeper"]="$db_smoke"
  STATUS_SMOKE["SceneBuilder"]="$db_smoke"
}

print_status_lines() {
  for repo in "${REPOS[@]}"; do
    printf '%-12s tests:%s lint:%s assets:%s sync:%s smoke:%s\n' \
      "$repo" \
      "$(status_cell "${STATUS_TESTS[$repo]}")" \
      "$(status_cell "${STATUS_LINT[$repo]}")" \
      "$(status_cell "${STATUS_ASSETS[$repo]}")" \
      "$(status_cell "${STATUS_SYNC[$repo]}")" \
      "$(status_cell "${STATUS_SMOKE[$repo]}")"
  done
}

run_pipeline() {
  init_statuses
  ensure_nested_submodules

  for repo in "${REPOS[@]}"; do
    run_assets "$repo"
    run_lint "$repo"
    run_tests "$repo"
    run_sync "$repo"
  done

  run_smoke
  print_status_lines
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

$REPO_ROOT/external/DREAMBase/Contents/mods/DREAMBase
$REPO_ROOT/external/DREAMBase/workshop.txt
$REPO_ROOT/external/DREAMBase/preview.png
$REPO_ROOT/external/DREAMBase/256.svg
$REPO_ROOT/external/DREAMBase/512.svg
$REPO_ROOT/external/DREAMBase/64.svg

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

echo "Watching all mods (TARGET=workshop, WATCH_MODE=$WATCH_MODE)…"
print_run_header
run_pipeline

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

if [ "$RUN_ONCE" = "1" ]; then
  exit 0
fi

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

    print_run_header
    run_pipeline
  done
