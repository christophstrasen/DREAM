# DREAM-Workspace Logbook

This is a maintainer-facing logbook for the DREAM suite.

It is intentionally not a user manual, not release notes, and not a full changelog of every commit. The goal is to capture the *story* of the project as it evolves across repos.

## What we log (and what we don’t)

We log:
- Progress highlights that change what’s possible or how we work.
- Difficulties/blockers (especially when they recur or reveal constraints).
- Learnings (runtime realities, Build 42 API surprises, tooling gotchas).
- Major decisions (architecture, naming, dependency direction, packaging policy) and why.

We don’t log:
- Every small refactor or typo fix (that belongs in Git history).
- Secrets, private info, or anything you wouldn’t want in a public repo.
- Raw debug spam or “trial and error” console transcripts (summarize instead).

## Day 1 — Welcome and scope

Welcome.

DREAM is a small suite of Project Zomboid Build 42 Lua modules that are meant to compose:
- **WorldObserver:** cooperative world sensing (turn “scan loops” into reusable observation streams).
- **PromiseKeeper:** persistent situation → action orchestration (“do X when Y happens, remember progress across reloads”).
- **SceneBuilder:** declarative scene composition and spawning.
- **reactivex / LQR:** foundational libraries, packaged as mods for Build 42.
- **DREAM (meta-mod):** suite entrypoint + curated examples and educational material.

This workspace exists so maintainers can co-develop the repos together (sync/watch/smoke) without constantly re-cloning and re-wiring local paths.

## Links

- DREAM (meta-mod, user-facing suite entrypoint): https://github.com/christophstrasen/pz-dream
- WorldObserver logbook (module-internal): https://github.com/christophstrasen/WorldObserver/blob/main/docs_internal/logbook.md

## Day 1 — 2025-12-30 (continued)

### Progress highlights
- SceneBuilder Build 42.13 compatibility work: surface-aware placement now uses `sq:has("IsTable")` + `IsoObject:getSurfaceOffsetNoTable()` (and drops deprecated `Val("Surface")` usage).
- Reduced “bespoke heuristics” in the suite toolchain by fixing the `dev/watch-all.sh` runaway retrigger loop (asset rebuilding caused self-triggering).

### Difficulties / blockers


### Learnings
- Prefer vanilla placement primitives when available (they encode Build 42 rules we don’t want to re-implement).

### Major decisions
- For the suite, treat engine flags and engine-derived offsets as authoritative (e.g. `IsTable` / `getSurfaceOffsetNoTable()`), and keep custom datasets only for what the engine doesn’t provide (safe X/Y placement boxes).

## Day 2 — 2025-12-31 — DREAMBase becomes the suite baseline

### Progress highlights
- Introduced **DREAMBase** as the suite base mod + repo and wired it into the workspace dev flow (`sync/watch/smoke`) + CI.
- Centralized shared utilities in DREAMBase (`log`, `util`, `time_ms`, `events`, `pz/*`, `test/bootstrap`) and migrated suite repos to hard-require/import them.
- Removed shim-only modules/exports and updated docs/workshop metadata to match (removed `PromiseKeeper/util`, `PromiseKeeper/time`, `SceneBuilder/util`, `SceneBuilder.util`, `WorldObserver/helpers/time`).
- Fixed smoke tooling to validate both Workshop vs mods deploy trees; kept packaging parity and regenerated DREAMBase assets.

### Difficulties / blockers
- Workshop smoke checks and busted runs surfaced how easy it is to accidentally depend on implicit `package.path`; we standardized helper-based runs and made smoke tooling explicit about dependency roots (`SOURCE`).
- Removing shim modules is intentionally breaking for any downstream code that required `PromiseKeeper/util`, `PromiseKeeper/time`, or `SceneBuilder/util`; we need to treat this as an API break (fine while early, but it must be communicated).

### Learnings
- If a dependency is declared in `mod.info require=...`, “soft require + fallback” layers usually just hide real packaging issues; prefer hard requires and keep any delegation in the base layer (not in every consumer).
- Workshop and mods deploy trees are different roots; validation tooling must be explicit about which it targets and must assemble Lua paths accordingly.

### Major decisions
- DREAMBase is the canonical home for suite-wide utilities; suite mods treat it as a required dependency rather than an optional convenience.
- LQR stays unchanged; DREAMBase integrates by delegation (not by pushing cross-cutting changes into LQR).
- Use a shared busted helper/bootstrap pattern and drop backwards-compatibility shims early to keep headless tests aligned and avoid accidental legacy APIs.

## Day 3 — 2026-01-01 — Examples + linting + workflow harmonization

### Progress highlights
- Built a combined WorldObserver + PromiseKeeper example in `pz-dream`: “police zombie on road spawns a road cone (once per tile)”.
- Added `square.floorMaterial` to square records and `hasFloorMaterial("Road%")` convenience filtering for “road” detection in user-facing examples.
- Standardized wildcard “prefix%” matching across helpers (e.g. outfits, floorMaterial) and documented intended semantics.
- Improved PromiseKeeper chance determinism via suite-owned Murmur3 32-bit hashing in DREAMBase.
- Drafted WorldObserver “record wrappers” RFC for record-helper ergonomics in non-stream contexts (PromiseKeeper actions).
- Ran `luacheck` across the suite, fixed a DREAMBase CI `luacheck` failure, and standardized developer workflow docs into one `development.md` per repo (+ workspace-level `development.md`).

### Difficulties / blockers
- Build 42 “Floor Material” is not the floor texture name; we needed explicit square record support rather than inferring from sprite/texture.
- Engine-side hash utilities (e.g. PZHash) were not reliably accessible from Lua in our test setup.

### Learnings / decisions
- “Walks over” is easiest to model as a join keyed by tile location with a time window; repeats are expected and should be handled by PromiseKeeper policy + occurrence keying.
- Keep one canonical developer workflow doc per repo (`development.md`) and link to it instead of duplicating commands.

## Day 4 — 2026-01-01 — Suite-wide luacheck + pre-commit parity

### Progress highlights
- Fixed all `luacheck` warnings in **WorldObserver** and **PromiseKeeper** (and verified unit tests pass).
- Implemented WorldObserver record wrappers (whitelisted per-family record decoration) and pinned the wrapped surface in docs + tests.
- Brought the remaining suite repos to a “CI can lint” baseline:
  - Added missing `.luacheckrc` files (e.g. `pz-dream`, `pz-lqr`, `pz-reactivex`).
  - Cleaned/adjusted upstream library payloads where needed (LQR + lua-reactivex) and rebuilt packaging payloads.
- Enabled `luacheck` in CI across the full suite (including adding new CI workflows for `pz-lqr` and `pz-reactivex`).
- Standardized local developer enforcement by adding/updating `.pre-commit-config.yaml` in every repo to mirror CI checks.
- Improved the workspace local dev loop (`dev/watch-all.sh`): single-run startup, compact per-repo status lines (tests/lint/assets/sync/smoke), and clearer rerun markers.

### Difficulties / blockers
- Some repos are packaging wrappers around upstream submodules; lint fixes must happen in the upstream payload and then be re-synced via `dev/build.sh` (otherwise they get overwritten).

### Learnings
- `luacheck` is not “just style”: it caught a real Lua scoping bug in LQR where a local constant was referenced before it was declared (would have fallen back to a nil global at runtime).
- Keeping pre-commit hooks in parity with CI is the easiest way to avoid “works locally, fails in GitHub” churn.

### Major decisions
- Treat `luacheck` warnings as CI-breaking across suite repos (no “warnings-only” exceptions).
- Use pre-commit as the primary local workflow guardrail; keep hook commands identical to CI per repo.

## Day 5 — 2026-01-02 — Marriage story demo (WO + PK + SceneBuilder)

### Progress highlights
- Shipped and in-engine validated the DREAM example `examples/marriage_story.lua`:
  - When a church room is seen, spawn a “marriage” zombie scene (bride, groom, priest, guests).
  - When the player enters the church and the marriage cast is present, play a one-shot wedding “song” (placeholder text for now).
- WorldObserver gained cross-repo enabling capabilities for this style of story:
  - Shared “player room changed” sensor fan-out to both `rooms` and `players` fact families.
  - `onPlayerChangeRoom` scope available for `players` interests.
  - Multi-family interest declarations (`type = { "rooms", "players", ... }`) to subscribe cleanly without forcing combined payload shapes.
- SceneBuilder placement quality improvements:
  - Added `centroid` and `centroidFreeOrMidair` resolver strategies to bias placement towards the “room center” (centroid of actual room squares), ordered center-out in concentric rings.
- Updated workspace docs to reflect the new end-to-end example and how the three modules compose (see `README.md`).

### Difficulties / blockers
- Java `long` IDs (e.g. `RoomDef:getID()`) can exceed Lua number precision; RoomDef hydration now prefers coordinate-based lookup (parse `roomLocation` and use metaGrid) rather than relying on numeric IDs.

### Learnings / decisions
- “Player in room” + “cast present in room” is best modeled as an explicit derived-stream join keyed by `roomLocation`, with PromiseKeeper using `occurranceKey` for idempotence.
- Next placement exploration: “spawn near sprite” where authors can specify a sprite prefix (e.g. `table%`) as an anchor-like target within the room.
