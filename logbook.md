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

