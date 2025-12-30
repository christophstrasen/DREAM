# DREAM-Workspace

Maintainer convenience repo for co-developing the DREAM mod family in one place.

This repo is **not** a mod. It contains the mod repos as git submodules and provides:
- VS Code workspace settings (mirrors your current setup style)
- one-command sync to `~/Zomboid/Workshop` (or `~/Zomboid/mods`)
- one-terminal watcher that re-syncs all mods on change

Included mods:
- `WorldObserver`
- `PromiseKeeper`
- `SceneBuilder`
- `reactivex` (`pz-reactivex`)
- `LQR` (`pz-lqr`)
- `DREAM` (`pz-dream`)

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
