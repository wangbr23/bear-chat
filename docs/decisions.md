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

## 2026-10-03 — Use GitHub Actions for project CI

**Status:** Accepted

**Context:** `T27` and `T28` both add continuous integration, no CI platform had been chosen, and the backend harnesses established in `T26` need both a Deno runtime and a Docker-backed local Supabase stack.

**Decision:** Run CI on GitHub Actions with one workflow file per area: `backend-ci.yml` for Supabase migrations, pgTAP tests, and Edge Function checks, and a separate workflow for iOS build and tests in `T27`. Backend jobs trigger on `supabase/**` path changes, pin Supabase CLI 2.119.0 to match `supabase/README.md`, and run with least-privilege `contents: read` permissions and per-ref concurrency cancellation.

**Consequences:** `T27` should add an iOS workflow in the same style rather than introducing a different CI platform. Docker-backed jobs are verifiable only on GitHub runners because local machines may lack a container runtime.

## 2026-10-03 — Ship configuration boundaries for development and staging only

**Status:** Accepted

**Context:** The HLD and LLD plan one Supabase project per environment (development, staging, production), but production provisioning was intentionally deferred in `T19`, and `T29` initially wired Release builds to a placeholder `Production.xcconfig` for a project that does not exist.

**Decision:** Ship only the environments that exist: Debug builds use development endpoints and Release builds use staging endpoints. `Production.xcconfig` remains committed with placeholders but unreferenced; when the production Supabase project is provisioned, a follow-up change moves Release to it (and can add a dedicated staging configuration if the beta needs one). Endpoint values are placeholder until real staging values are filled in.

**Consequences:** Release builds are staging-bound during the internal TestFlight period, which matches the beta plan. Cross-environment production isolation remains untested until production exists; `T187` covers it after provisioning.
