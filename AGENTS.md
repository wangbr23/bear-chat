# bear-chat

Standalone iPhone messenger where shared rooms are interactive bear spaces — ordered chat, presence, actions, reactions, and bear customization, backed by Supabase.

## Stack
- Language/runtime: Swift 6 on iOS 17+ for the app; PostgreSQL 17 and Deno 2 for the Supabase backend
- Framework: SwiftUI, SpriteKit, SwiftData; Supabase Swift SDK 2.26.0 (pinned)
- Package manager: Swift Package Manager (Xcode-managed); Supabase CLI pinned at 2.119.0 via `npx`

## Commands
- Install: `xcodegen generate` inside `BearChat/` regenerates the Xcode project after `project.yml` changes; SPM resolves on first build. Backend needs a Docker-compatible runtime, Node 20+, and Deno 2.
- Dev/run: open `BearChat/BearChat.xcodeproj` and run the BearChat scheme. Local backend stack: `npx --yes supabase@2.119.0 start` from the repo root.
- Test: iOS — `xcodebuild -project BearChat/BearChat.xcodeproj -scheme BearChat -destination 'platform=iOS Simulator,name=<simulator>' test`. Database — `npx --yes supabase@2.119.0 test db` (stack running). Edge Functions — `deno task --config supabase/deno.json check` (format, lint, tests).
- Lint/typecheck: Swift 6 strict concurrency via Xcode; Edge Functions covered by the deno check task. No separate linter configured.
- Build: same xcodebuild command with `build` instead of `test`. CI runs both automatically: `.github/workflows/ios-ci.yml`, `.github/workflows/backend-ci.yml`.

## Conventions
Cross-project coding principles (KISS, no god files, surface conflicts, etc.) live in `~/.claude/CLAUDE.md` — don't restate them here. Project coding conventions live in `CLEANCODE.md`; keep detailed code-quality rules there so this file stays focused on project context.

This section is only for what's specific to *this* repo:
- Code style:
- Testing approach:
- Commit message format:
- Task completion reports: whenever a task is completed, report back how it was verified to be correct, and what the human can do themselves to further verify it is working as expected. Say plainly what was and was not verified.

Subagents that run as Herdr tabs follow the `herdr-subagents` skill (opencode global skills): one tab per agent, self-contained prompts pointing at these context files, results written to files.

## Context discipline
- Long-output commands (test runs, builds, logs): pipe through `tail`/`head`, or redirect to a file and `grep` it. Never dump full output into the context window.
- Reading files: read only the section needed (`offset`/`limit`) after locating it with `grep`/`glob`, unless the whole file is genuinely required.

## Architecture
One native iPhone app backed by one Supabase project per environment (development and staging are live; production stays unwired until `T19` provisions it).

- **iOS app (`BearChat/`)** — SwiftUI app shell and feature screens, SpriteKit room scene, SwiftData bounded local cache. Typed service boundaries call Supabase; per-environment endpoints come from the xcconfig files in `BearChat/Configuration/` (Debug → development, Release → staging).
- **Backend (`supabase/`)** — PostgreSQL 17 schema with RLS owning every authorization decision, narrow transactional functions for sensitive mutations, Realtime for change delivery, and Edge Functions (Deno 2) for APNs notifications. pgTAP tests live in `supabase/tests/database/`, Deno tests in `supabase/tests/functions/`.
- **Design source of truth** — `docs/designs/2026-09-20-bear-chat-standalone-hld-lld.md` pins planned files, data invariants, RPCs, and test ownership; requirements trace in `docs/verification/requirements-traceability.md`.

## Context files
Keep these current — they're what gives any session, or either CLI tool, continuity without re-deriving history from scratch.

- **AGENTS.md** (this file) — stack, commands, repo-specific conventions, architecture. Update only when one of those actually changes; it should stay stable day to day.
- **CLAUDE.md** — pointer to this file only. Don't duplicate content into it.
- **CLEANCODE.md** — coding conventions agents should follow while editing code. Update when recurring code-quality preferences or project-specific patterns become clear.
- **docs/journal.md** — append-only session log. Never edit past entries; if something turns out wrong, say so in a new one.
- **docs/decisions.md** — append-only log of significant technical decisions (dependency choices, schema changes, rejected approaches), one entry per decision. Never edit past entries — a reversed decision gets a new entry that supersedes the old one.
- **docs/designs/** — design documents (specs, mockups, research write-ups). One file per document; save the working version here rather than leaving it only in chat or artifact history.
- **TODO.md** — current and near-term work. The only file in this list meant to be edited freely rather than appended-only. Tasks carry an id, a manual/agent tag, and optional `depends-on` links so parallel-safe work can be computed rather than tracked by hand — see the `plan-tasks` skill.

**Before starting nontrivial work:** read this file, read CLEANCODE.md, skim the last few journal entries, check TODO.md.
**After finishing a session:** append a journal entry (what changed, why, what's next), update TODO.md, and append a decision entry if a decision worth remembering was made.

<!-- opencode-swe-factory:lesson-capture-protocol@1 start -->
## Lesson Capture Protocol

A lesson is anything from this session about how to work that a future session should repeat or avoid: work that went well and should be repeated, or a mistake, correction, or expressed preference that should change how you work. Judge the substance, not the user's exact words.
Decisions about what to build — scope, requirements, product or architecture choices — are not lessons. Record those in the project's decision/design docs (e.g. docs/decisions.md, docs/designs/); writing them there is the terminal action, not a lesson proposal.
Bias toward proposing. Proposals are drafts awaiting human approval and expire if ignored, so a wasted proposal costs seconds while a missed lesson repeats the mistake. Recording a lesson in repo docs, a journal, or a summary does not substitute for proposing it.
When a lesson-worthy moment happens, propose it via the swe_factory_propose_lesson tool in the same turn, proactively — never wait to be asked. Never include secrets or credential-like content in a proposal.
Immediately after a proposal returns, present it for approval via the question tool (or your environment's equivalent interactive ask) with Approve / Edit / Defer / Reject options. Never just list the candidate in text.
<!-- opencode-swe-factory:lesson-capture-protocol@1 end -->
