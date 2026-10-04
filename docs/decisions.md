# Decisions

Append-only log of architecture decisions. One entry per decision, newest at the bottom. Don't edit past entries — a reversed decision gets a new entry that supersedes the old one, rather than an edit.

## 2026-09-19 — Record architecture decisions

**Status:** Accepted

**Context:** We need a lightweight way to record why significant technical decisions were made, so future work — by any contributor, human or AI, in any tool — doesn't rediscover or accidentally reverse them without knowing the original reasoning.

**Decision:** We will keep architecture decisions in `docs/decisions.md`, one entry per decision, appended chronologically. Entries are append-only — a changed decision gets a new entry that supersedes the old one, rather than an edit.

**Consequences:** Decisions and their reasoning survive context resets, tool switches, and contributor turnover.

## 2026-10-03 — Pin the local backend foundation

**Status:** Accepted

**Context:** Backend migrations and Edge Functions need a reproducible local structure before application schema work begins, but the project has not selected a JavaScript package manager and later tasks own all production schema and function behavior.

**Decision:** Use Supabase CLI 2.119.0 through a pinned `npx` invocation, PostgreSQL 17 for the local stack, and Deno 2 for Edge Function checks. Keep T26 schema-free and function-free except for harness smoke tests; later tasks add immutable migrations and function implementations. Disable unused local Storage, SMTP, and Analytics services.

**Consequences:** Contributors can initialize and test the backend without committing npm package metadata or secrets. Local startup requires a Docker-compatible runtime, database tests run through pgTAP, and each production function can add its own isolated `deno.json` when implemented.
