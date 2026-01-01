# DREAM-Workspace — Development

This repo is a maintainer convenience workspace. Commands below assume you are in the `DREAM-Workspace/` root.

## Sync (deploy to Project Zomboid)

Default target is the Workshop wrapper folder (`~/Zomboid/Workshop`):

```bash
./dev/sync-all.sh
```

Optional: deploy to the mods folder (`~/Zomboid/mods`):

```bash
TARGET=mods ./dev/sync-all.sh
```

Common environment variables:
- `PZ_WORKSHOP_DIR` (default: `$HOME/Zomboid/Workshop`)
- `PZ_MODS_DIR` (default: `$HOME/Zomboid/mods`)

## Watch (auto re-sync on change)

```bash
./dev/watch-all.sh
```

Options:

```bash
TARGET=mods ./dev/watch-all.sh
WATCH_MODE=repo ./dev/watch-all.sh
```

Requires `inotifywait` (`inotify-tools`).

## Smoke checks (suite loader)

```bash
./dev/smoke.sh
```

If you deploy to `mods` and want the smoke script to read from there:

```bash
SOURCE=mods ./dev/smoke.sh
```

## Unit tests

Run per-repo unit tests from the repo root:

```bash
(cd external/DREAMBase && busted --helper=tests/helper.lua tests/unit)
(cd external/WorldObserver && busted --helper=tests/helper.lua tests/unit)
(cd external/PromiseKeeper && busted --helper=tests/helper.lua tests/unit)
(cd external/SceneBuilder && busted --helper=tests/helper.lua tests/unit)
(cd external/pz-dream && busted --helper=tests/helper.lua tests/unit)
```

Each repo also documents its own dev workflow in `external/<RepoName>/development.md`.

