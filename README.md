# DREAM-Workspace

Maintainer convenience repo for co-developing the DREAM mod family in one place.

This repo is **not** a mod. It contains the mod repos as git submodules and provides:
- VS Code workspace settings (mirrors your current setup style)
- one-command sync to `~/Zomboid/Workshop` (default)
- one-terminal watcher that re-syncs all mods on change

## Documentation scope

- **User-facing suite overview + curated examples:** `external/pz-dream/` (DREAM meta-mod), and its Workshop item.
- **Module-specific docs and APIs:** in each module repo under `external/<RepoName>/`.
- **Maintainer coordination:** this repo (scripts, submodule policy, dev standards, and the workspace logbook).

Maintainer logbook: `logbook.md`.

## Included repos

**Main modules**
- `DREAM` (`pz-dream`) [![CI](https://github.com/christophstrasen/pz-dream/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/pz-dream/actions/workflows/ci.yml)
  - Convenient "bundle" that requires all other modules.
  - Comes with extra examples and high level intro.
- `WorldObserver` [![CI](https://github.com/christophstrasen/WorldObserver/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/WorldObserver/actions/workflows/ci.yml)
  - A cooperative *world-sensing engine*.
- `PromiseKeeper` [![CI](https://github.com/christophstrasen/PromiseKeeper/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/PromiseKeeper/actions/workflows/ci.yml)
  - A stateful situation-to-action orchestrator.
- `SceneBuilder` [![CI](https://github.com/christophstrasen/SceneBuilder/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/SceneBuilder/actions/workflows/ci.yml)
  - A declarative scene composition framework.

**Dependencies**

`DREAMBase` [![CI](https://github.com/christophstrasen/DREAMBase/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/DREAMBase/actions/workflows/ci.yml)
  - A small “base library” mod for the DREAM ecosystem (Build 42). 
  - dependency for All modules abov
- `LQR` [![CI](https://github.com/christophstrasen/LQR/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/LQR/actions/workflows/ci.yml)
  - For expressing SQL‑like joins and queries over ReactiveX observable streams. 
  - dependency for `WorldObserver`
- `reactivex` 
  - Gives Lua the power of Observables: data structures that represent a stream of values over time.
  - Handy for events, streams of data, asynchronous requests, and concurrency-like composition.
  - dependency for `WorldObserver`


## Clone

```bash
git clone git@github.com:christophstrasen/DREAM-Workspace.git
cd DREAM-Workspace
git submodule update --init
```

Note: avoid `--recursive` unless you explicitly want nested submodules inside the mod repos.

## Local deploy

One-off deploy all mods into `~/Zomboid/Workshop`:

```bash
./dev/sync-all.sh
```

Watch (single terminal):

```bash
./dev/watch-all.sh
```

Run loader smoke test (after syncing):

```bash
./dev/smoke.sh
```

Tip: you can switch the destination with `TARGET=mods` if you prefer `~/Zomboid/mods`.
