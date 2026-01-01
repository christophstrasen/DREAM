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

## Day 3 — 2026-01-01 — pz-dream examples and documentation work

### Progress highlights
- Built a combined WorldObserver + PromiseKeeper example in `pz-dream`: a “police zombie on road spawns a road cone (once per tile)” situation + action flow.
- Added `square.floorMaterial` to square records and `isRoad()` convenience filtering to support “road” detection in user-facing examples.
- Standardized wildcard “prefix%” matching across observations/helpers (e.g. outfits, floorMaterial) and documented the intended semantics.
- Improved PromiseKeeper chance determinism by switching chance hashing to a suite-owned Murmur3 32-bit implementation in DREAMBase (better avalanche for adjacent keys vs previous mixing).
- Drafted a WorldObserver RFC for “record wrappers” to make record-helper ergonomics consistent in non-stream contexts (notably PromiseKeeper actions): `external/WorldObserver/docs_internal/drafts/record_wrappers.md`.

### Difficulties / blockers
- Build 42 “Floor Material” is not the floor texture name; the data surfaced by the in-game inspector required explicit square record support rather than inferring from sprite/texture.
- Engine-side hash utilities (e.g. PZHash) were not reliably accessible from Lua in our test setup, so we could not depend on them for deterministic chance.

### Learnings
- “Walks over” is easiest to model as a join keyed by tile location with a time window; repeats on the same tile are expected and should be handled by PromiseKeeper policy + occurrence keying.
- For demos, keep code direct and fail-fast (typical Zomboid mod style); add diagnostics via logging levels rather than defensive wrappers.

### Major decisions
- DREAMBase owns deterministic hashing primitives needed by multiple suite repos; avoid external hashing libs unless the engine exposes them cleanly to Lua.
- `pz-dream` examples prioritize readability over “enterprise” defensive patterns; keep optional debug paths out of the main example code path.

## Day 3 — 2026-01-01 (continued) — Linting + dev workflow harmonization

### Progress highlights
- Ran `luacheck` across suite repos that ship a `.luacheckrc` and captured current warning counts (DREAMBase/SceneBuilder clean; PromiseKeeper small; WorldObserver large).
- Fixed the DREAMBase CI `luacheck` failure (unused `k1` assignment in `DREAMBase/util.lua`).
- Standardized “how to test/watch/sync” into a single `development.md` per repo (and added a workspace-level `development.md` for the multi-repo flow), reducing duplicated instructions across READMEs/internal docs.

### Difficulties / blockers
- `luacheck` currently fails CI on warnings (exit code 1), so expanding CI coverage to PromiseKeeper/WorldObserver will require either (a) reducing warnings, or (b) agreeing on an “errors-only” policy first.

### Major decisions
- “One canonical developer workflow doc per repo”: `development.md` is the single developer-facing place for test/watch/sync commands; other docs should link to it instead of duplicating commands.
