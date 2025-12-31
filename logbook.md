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
- 

### Learnings
- Prefer vanilla placement primitives when available (they encode Build 42 rules we don’t want to re-implement).

### Major decisions
- For the suite, treat engine flags and engine-derived offsets as authoritative (e.g. `IsTable` / `getSurfaceOffsetNoTable()`), and keep custom datasets only for what the engine doesn’t provide (safe X/Y placement boxes).

## Day 2 — 2025-12-31 — DREAMBase becomes the suite baseline

### Progress highlights
- Added **DREAMBase** as a first-class repo + mod (shared suite “base library”), wired into the workspace submodules and the standard `dev/` sync/watch/smoke workflow.
- Implemented shared modules in DREAMBase (Lua 5.1 / Build 42 compatible):
  - `DREAMBase/log` (delegates to `LQR/util/log` when present, otherwise provides a compatible fallback)
  - `DREAMBase/util`, `DREAMBase/time_ms`, `DREAMBase/events`
  - PZ interop helpers under `DREAMBase/pz/*` (e.g. defensive Java list access + safe method calls)
  - `DREAMBase/test/bootstrap` for consistent headless/busted stubbing
- Added a small busted unit test suite + CI for DREAMBase and adopted the same `busted --helper=tests/helper.lua ...` workflow across the suite.
- Adopted DREAMBase across suite repos (PromiseKeeper, WorldObserver, SceneBuilder, DREAM meta-mod):
  - `mod.info` now declares `require=\DREAMBase` where appropriate
  - CI clones DREAMBase and runs DREAMBase tests as a dependency step
  - runtime modules delegate shared concerns (time/events/util/logging) to DREAMBase
- Removed remaining “optional DREAMBase” shims now that it is required:
  - PromiseKeeper logging is a direct `require("DREAMBase/log")`
  - WorldObserver helper wrappers are pure aliases to DREAMBase helpers (no legacy fallback bodies)
  - tests bootstraps require `DREAMBase/test/bootstrap` directly (no `pcall`)
- Fixed workspace + WorldObserver smoke tooling to correctly validate Workshop vs mods deployments (dependency roots now follow `SOURCE=workshop|mods`).
- Standardized packaging/asset expectations:
  - DREAMBase now ships an empty `common/` folder (layout parity with other mods)
  - Updated DREAMBase SVG labels (“DREAM Base” / “DB”) and regenerated PNG assets.

### Difficulties / blockers
- Workshop smoke checks initially failed because some scripts still assumed dependencies lived under `~/Zomboid/mods`; this broke `require("DREAMBase/...")` in headless validation until we made dependency roots follow `SOURCE`.
- Some repos’ default `busted tests` invocation fails without the helper because `package.path` isn’t set; we standardized on helper-based runs in CI and local workflows.

### Learnings
- If a dependency is declared in `mod.info require=...`, “soft require + fallback” layers usually just hide real packaging issues; prefer hard requires and keep any delegation in the base layer (not in every consumer).
- Workshop and mods deploy trees are different roots; validation tooling must be explicit about which it targets and must assemble Lua paths accordingly.

### Major decisions
- DREAMBase is the canonical home for suite-wide utilities; suite mods treat it as a required dependency rather than an optional convenience.
- LQR stays unchanged; DREAMBase integrates by delegation (not by pushing cross-cutting changes into LQR).
- Use a shared busted helper/bootstrap pattern for the whole suite to keep headless tests aligned with Project Zomboid packaging/require realities.
