# DREAM — Development Standards

This document is the shared development + release hygiene for the DREAM mod family.
It captures the conventions that are **standard across repos** and what contributors can rely on.

## Repos and purpose

The DREAM suite is split into individual mods so each can be developed and shipped independently:

- `WorldObserver` — shared world sensing engine (Build 42, SP-first).
- `PromiseKeeper` — persisted “situations → actions” runner (Build 42, SP-first).
- `SceneBuilder` — declarative scene placement library (Build 42).
- `reactivex` (`pz-reactivex`) — ReactiveX for Lua, packaged as a PZ mod.
- `LQR` (`pz-lqr`) — query/ingest engine for Lua, packaged as a PZ mod.
- `DREAM` (`pz-dream`) — meta-mod that depends on the other mods and ships examples/material.

This repo (`DREAM-Workspace`) is a **maintainer convenience repo** that pulls all mod repos in as git submodules and provides “sync all” + “watch all”.

## Canonical on-disk layout

All mods follow the Build 42 payload convention:

```
Contents/mods/<ModId>/
  42/
    mod.info
    poster.png
    icon_64.png
    media/...
  common/
```

Notes:
- The `common/` folder must exist (even if empty). We keep it tracked via a `.gitkeep`.
- `mod.info:id` is the **Mod ID** (in-game mod ID). Display names can include build tags like `[42]` / `[42SP]`.
- Lua `require("...")` is determined by the shipped Lua file paths, not by the mod ID.
- Mod dependencies should be declared via `mod.info` `require=\OtherModId` (comma-separated). (Exception: `SceneBuilder` is already published and keeps its existing `mod.info` unchanged.)

## Local deploy targets

We support two destinations:

1) **Workshop wrapper folder** (default for dev scripts)

```
~/Zomboid/Workshop/<WrapperName>/
  workshop.txt
  preview.png
  Contents/mods/<ModId>/...
```

2) **Mods folder**

```
~/Zomboid/mods/<ModId>/...
```

Environment variables used everywhere:
- `PZ_WORKSHOP_DIR` (default: `$HOME/Zomboid/Workshop`)
- `PZ_MODS_DIR` (default: `$HOME/Zomboid/mods`)
- `WRAPPER_NAME` (default: `<ModId>`) — workshop wrapper folder name

## Standard dev scripts (single repo)

Each mod repo ships a common set of scripts under `dev/`:

- `dev/build-assets.sh`
  - Uses `inkscape` to export PNGs from `512.svg`, `256.svg`, `64.svg`.
  - Writes:
    - `Contents/mods/<ModId>/42/poster.png`
    - `Contents/mods/<ModId>/42/icon_64.png`
    - `preview.png` (wrapper preview)
- `dev/sync-workshop.sh` (default target)
  - Builds assets (and any generated Lua payload for packaging repos), then syncs to the Workshop wrapper.
- `dev/sync-mods.sh`
  - Builds assets (and any generated Lua payload for packaging repos), then syncs to `~/Zomboid/mods`.
- `dev/watch.sh`
  - Watches the repo payload (or the whole repo) and re-syncs on change.
  - Defaults: `TARGET=workshop`, `WATCH_MODE=payload`.
  - Set `WATCH_MODE=repo` to watch everything.

Tooling prerequisites (for the scripts):
- `rsync`
- `inotifywait` (`inotify-tools`) for watch mode
- `inkscape` for asset exports

### Packaging repos: `pz-reactivex` and `pz-lqr`

These two repos package upstream libraries as PZ mods:

- `pz-reactivex` packages `lua-reactivex`
- `pz-lqr` packages `LQR`

They include:
- `dev/build.sh` — copies Lua-only payload from the upstream submodule into `Contents/mods/.../42/media/lua/shared`.
- Their `dev/sync-*.sh` scripts run `dev/build.sh` automatically.

If you want to change the actual library code, prefer contributing upstream and then updating the packaging repo:
- `lua-reactivex` upstream: https://github.com/christophstrasen/lua-reactivex
- `LQR` upstream: https://github.com/christophstrasen/LQR

## Standard workflow: develop a single repo

This is the contributor-friendly path: clone **one** repo and iterate.

1) Clone the repo, init submodules (if any):

```bash
git clone <repo-url>
cd <repo>
git submodule update --init
```

2) Run the watcher (defaults to Workshop wrapper deploy):

```bash
./dev/watch.sh
```

3) Enable the mod(s) in-game and test.

If you prefer deploying to `~/Zomboid/mods`:

```bash
TARGET=mods ./dev/watch.sh
```

## Maintainer workflow: DREAM-Workspace (multi-repo)

This path is for co-developing multiple mods at once with one terminal:

```bash
git clone git@github.com:christophstrasen/DREAM-Workspace.git
cd DREAM-Workspace
git submodule update --init
```

One-off deploy everything (default: Workshop):

```bash
./dev/sync-all.sh
```

Watch everything:

```bash
./dev/watch-all.sh
```

Notes:
- Avoid `--recursive` unless you explicitly want nested submodules inside packaging repos.
- `dev/sync-all.sh` initializes only the nested submodules it needs (reactivex/LQR upstream sources).

## Tests and confidence checks

Not every repo has a full headless test suite yet, but we standardize expectations:

- **WorldObserver:** `busted tests`
- **PromiseKeeper:** `busted tests`
- **Suite loader smoke test (recommended after require/path changes):**
  - From `DREAM-Workspace`: `./dev/smoke.sh`
