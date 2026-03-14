# DREAM — Agent Guide

This repo is a **maintainer convenience workspace** for co-developing the DREAM suite via git submodules.

The goal of this file is to capture the **shared** best-practice patterns across the DREAM repos, without overwriting repo-specific rules.

## Priority and scope

- **Priority:** system > developer > `AGENTS.md` > `.aicontext/*` > task instructions > file-local comments.
- **Scope:** this file applies to `DREAM/` itself.
- **Submodules:** when editing code inside `external/*`, treat that repo’s own guidance as authoritative:
  - Load that repo’s `.aicontext/context.md` (if present).
  - Obey that repo’s `AGENTS.md` (if present).

## Interaction style (common across DREAM repos)

- Keep responses direct; avoid flattery.
- If something is unclear or ambiguous, ask rather than guessing.
- Preserve behavior when refactoring unless explicitly asked; call out intentional behavior changes.
- Bias for simplicity and minimal changes; avoid speculative “future-proofing”.

## Project Zomboid + Lua constraints (shared baseline)

- Target runtime is **Project Zomboid Build 42** (Lua 5.1 / Kahlua).
- Keep code compatible with **vanilla Lua 5.1** where feasible (tests/smoke runs outside the engine).
- Keep `require()` paths valid for Build 42:
  - Don’t rely on `init.lua` being special (PZ does not auto-load `init.lua`).
  - Prefer slash-separated require paths; avoid relying on `package.path` hacks.
  - Avoid meta-table “magic” (`setmetatable`) unless explicitly requested.
- Use repo-provided logging utilities (don’t add ad-hoc `print` spam).
- Prefer EmmyLua doctags for public-facing functions/APIs.

## Standard local dev pipeline (shared)

All DREAM mods in this workspace ship a standardized `dev/` toolchain:

- `dev/build-assets.sh` exports `512.svg`, `256.svg`, `64.svg` to `poster.png`, `preview.png`, `icon_64.png`.
  - Asset exports are incremental (skip if outputs are newer than SVGs); use `FORCE_ASSETS=1` to force a rebuild.
- `dev/sync-workshop.sh` deploys to `~/Zomboid/Workshop` (canonical workflow).
- `dev/watch.sh` watches and re-syncs on change (defaults: Workshop target + `WATCH_MODE=payload`).

Workspace-wide helpers:

- `./dev/sync-all.sh` deploys all mods to `~/Zomboid/Workshop`.
- `./dev/watch-all.sh` watches all mods and re-syncs all on change.
- `./dev/smoke.sh` runs the suite loader smoke check against Workshop deployments.

## Tests (shared expectations)

- After Lua code changes, run the repo’s lint + unit tests (or `pre-commit run --all-files`):
  - `luacheck ...` (see each repo’s `development.md` for the exact command)
  - `busted --helper=tests/helper.lua tests/unit` (most repos)
- After changes that affect packaging / `require()` paths / mod layout, run:
  - `DREAM/dev/sync-all.sh`
  - `DREAM/dev/smoke.sh`

## Git hygiene (shared)

- Prefer small, focused commits.
- Avoid destructive history operations (no `git reset --hard` / force-push) unless explicitly requested.
- For packaging repos, prefer contributing changes to upstream libraries where applicable, then bump the submodule pointer.

## Steam Workshop descriptions

When creating or updating any `workshop.txt` description, follow `steam_workshop_guidance.md` and stick to its “assumed safe” BBCode subset.
