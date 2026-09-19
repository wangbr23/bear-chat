# bear-chat

Extension for iMessage to make chats interactive with bear animations.

## Stack
- Language/runtime: Not chosen yet
- Framework: Not chosen yet
- Package manager: Not chosen yet

## Commands
- Install: Not configured yet
- Dev/run: Not configured yet
- Test: Not configured yet
- Lint/typecheck: Not configured yet
- Build: Not configured yet

## Conventions
Cross-project coding principles (KISS, no god files, surface conflicts, etc.) live in `~/.claude/CLAUDE.md` — don't restate them here. Project coding conventions live in `CLEANCODE.md`; keep detailed code-quality rules there so this file stays focused on project context.

This section is only for what's specific to *this* repo:
- Code style:
- Testing approach:
- Commit message format:

Subagents that run as Herdr tabs follow the `herdr-subagents` skill (opencode global skills): one tab per agent, self-contained prompts pointing at these context files, results written to files.

## Context discipline
- Long-output commands (test runs, builds, logs): pipe through `tail`/`head`, or redirect to a file and `grep` it. Never dump full output into the context window.
- Reading files: read only the section needed (`offset`/`limit`) after locating it with `grep`/`glob`, unless the whole file is genuinely required.

## Architecture
(Placeholder — fill in once the system has real shape. High-level modules/services and how they talk to each other. Update this when the shape changes, not on every commit.)

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
