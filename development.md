# DREAM — Development

This repo is a maintainer convenience workspace. Commands below assume you are in the `DREAM/` root.

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
(cd external/pz-lqr/external/LQR && busted tests/unit)
(cd external/pz-reactivex/external/lua-reactivex && lua tests/runner.lua)
```

Each repo also documents its own dev workflow in `external/<RepoName>/development.md`.

## Lint (luacheck)

```bash
(cd external/DREAMBase && luacheck Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase.lua)
(cd external/WorldObserver && luacheck Contents/mods/WorldObserver/42/media/lua/shared/WorldObserver Contents/mods/WorldObserver/42/media/lua/shared/WorldObserver.lua)
(cd external/PromiseKeeper && luacheck Contents/mods/PromiseKeeper/42/media/lua/shared/PromiseKeeper Contents/mods/PromiseKeeper/42/media/lua/shared/PromiseKeeper.lua)
(cd external/SceneBuilder && luacheck Contents/mods/SceneBuilder/42/media/lua/shared/SceneBuilder Contents/mods/SceneBuilder/42/media/lua/shared/SceneBuilder.lua)
(cd external/pz-dream && luacheck Contents/mods/DREAM/42/media/lua/shared/examples)
(cd external/pz-lqr && luacheck Contents/mods/LQR/42/media/lua/shared/LQR Contents/mods/LQR/42/media/lua/shared/LQR.lua)
(cd external/pz-reactivex && luacheck Contents/mods/reactivex/42/media/lua/shared/reactivex Contents/mods/reactivex/42/media/lua/shared/reactivex.lua Contents/mods/reactivex/42/media/lua/shared/operators.lua)
```

## Pre-commit hooks

Each repo ships a `.pre-commit-config.yaml` that mirrors its CI checks.

Install hooks in all suite repos:

```bash
for repo in external/*; do
  if [ -f "$repo/.pre-commit-config.yaml" ]; then
    (cd "$repo" && pre-commit install)
  fi
done
```
