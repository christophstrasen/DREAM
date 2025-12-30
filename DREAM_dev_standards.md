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

We support two destinations (default is the Workshop wrapper folder):

1) **Workshop wrapper folder** (default for dev scripts)

```
~/Zomboid/Workshop/<WrapperName>/
  workshop.txt
  preview.png
  Contents/mods/<ModId>/...
```

2) **Optional: Mods folder** (set `TARGET=mods`)

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
- `dev/sync-mods.sh` (optional)
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
- See “Git submodules in DREAM-Workspace” below for how/when to use `--recursive` (rare).
- `dev/sync-all.sh` initializes only the nested submodules it needs for packaging repos (not a full `--recursive`).

## Git submodules in DREAM-Workspace

This workspace uses submodules in two layers:

1) **Workspace layer:** `DREAM-Workspace/.gitmodules` pins each mod repo under `external/<RepoName>/`.
2) **Packaging layer (inside some repos):** packaging repos pin upstream library sources as *their own* nested submodules:
   - `external/pz-reactivex` pins `external/lua-reactivex` (upstream library)
   - `external/pz-lqr` pins `external/LQR` (upstream library)

Some repos (notably `WorldObserver`) may also declare nested submodules for convenience when the repo is cloned standalone.
In the workspace, those duplicates are usually left **uninitialized** to avoid clutter and confusion.

### Key principles

- **Reproducibility over “floating”:** a submodule is always pinned by the parent repo to a specific commit SHA.
  - In Git terms, the parent repo records “use commit `<SHA>` of that submodule”, not “track branch `main`”.
  - Seeing `main` in VS Code just means *your local checkout* in that submodule currently has `main` checked out at the pinned SHA.
  - Submodules in a **detached HEAD** state are normal and expected.
- **Non-recursive by default (workspace root):** maintainers should generally run:

  ```bash
  git submodule update --init
  ```

  and avoid `--recursive` at the workspace root.
- **Wrappers are canonical for vendored libraries:** treat `pz-reactivex` and `pz-lqr` as the authoritative places to bump/update the upstream libraries they ship.
- **Avoid initializing duplicate nested submodules:** if multiple repos vendor the same upstream (e.g. `WorldObserver` and `pz-lqr` both reference `LQR`), prefer initializing only the one you actively use (typically the packaging repo’s copy).

### How to tell what’s initialized

Use:

```bash
git submodule status --recursive
```

Useful cues:
- A leading `-` means the submodule is declared but **not initialized** (no checkout on disk yet).
- A leading space means it is initialized at the commit recorded by the parent.

### Scenarios

#### Scenario: default maintainer workflow (recommended)

This is the common case: work on multiple DREAM repos, and only pull nested upstream libraries when a packaging repo actually needs them.

Day 0 (fresh workspace checkout):

```bash
git submodule update --init
./dev/sync-all.sh
```

`./dev/sync-all.sh` will initialize only the nested submodules required to build the packaging repos (currently `pz-reactivex` → `lua-reactivex`, and `pz-lqr` → `LQR`).

Ongoing work (develop mod repos, not upstream libraries):

- Don’t run `git submodule update --init --recursive` at the workspace root.
- Let `./dev/sync-all.sh` initialize only what it needs for the packaging repos.
- Avoid initializing nested duplicates under other repos (like `external/WorldObserver/external/LQR`) unless you have a specific reason.

#### Scenario: bump the upstream library version shipped by a packaging repo

Example: you want `pz-lqr` to ship a newer `LQR`.

Recommended workflow:

1) Update the upstream checkout inside the packaging repo (the nested submodule):
   - `external/pz-lqr/external/LQR/` for `LQR`
   - `external/pz-reactivex/external/lua-reactivex/` for `lua-reactivex`
2) Commit the *submodule pointer change* in the packaging repo (`external/pz-lqr` or `external/pz-reactivex`).
3) Commit the updated packaging repo pointer in the workspace (this repo).

This keeps the “what ships” decision in the wrapper repo that actually produces the mod payload.

#### Scenario: rare upstream library development (LQR / lua-reactivex)

If you need to change upstream library code:

- Prefer doing it in the wrapper repo’s copy of the upstream (e.g. `external/pz-lqr/external/LQR`), create a branch, push upstream, then bump the wrapper’s pinned SHA.
- Avoid also initializing `WorldObserver`’s duplicate copy unless you’re specifically validating `WorldObserver` standalone.

This avoids diverging multiple local copies of the same upstream library.

#### Scenario: you want to work on a repo standalone (outside the workspace assumptions)

Sometimes you want `WorldObserver` (or another repo) to be self-contained when opened/cloned alone.
In that case, initialize submodules *within that repo*:

```bash
git -C external/WorldObserver submodule update --init
```

Only add `--recursive` if that repo itself has deeper nested submodules you actually need.

### VS Code: why some submodules appear as repos (and others don’t)

VS Code’s Source Control / “Repositories” tree is driven by what Git repositories exist **on disk** and what VS Code chooses to scan.
Two practical implications:

- If a nested submodule hasn’t been initialized (leading `-` in `git submodule status --recursive`), VS Code usually won’t show it because there’s no checkout.
- If you do a full recursive init, VS Code will often show many more repos (including duplicates), which can feel noisy.

If VS Code is not discovering the repos you expect, check these settings:
- `git.autoRepositoryDetection` (recommend `subFolders` for this workspace)
- `git.repositoryScanMaxDepth` (needs to include `external/<RepoName>`)
- `git.detectSubmodules` (enable)
- `git.ignoredRepositories` / `git.repositoryScanIgnoredFolders` (don’t ignore `external/`)

## Tests and confidence checks

Not every repo has a full headless test suite yet, but we standardize expectations:

- **WorldObserver:** `busted tests`
- **PromiseKeeper:** `busted tests`
- **Suite loader smoke test (recommended after require/path changes):**
  - From `DREAM-Workspace`: `./dev/smoke.sh`
