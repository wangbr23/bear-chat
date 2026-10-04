# Journal

Append-only. One entry per work session. Newest at the bottom. Don't edit past entries — if something's wrong now, say so in a new entry.

## 2026-09-19 — project created

Initialized project scaffold (AGENTS.md, CLEANCODE.md, decisions log, TODO). Nothing built yet.

## 2026-09-19 — product requirements defined

Created `docs/designs/product-spec.md` for the Bear Chat MVP. It defines the in-iMessage room experience, text chat, bear actions and reactions, detailed avatar customization, recent activity, fallback previews, privacy, accessibility, and explicit MVP exclusions. The next step is human review and approval before technical planning.

## 2026-09-20 — main room product mock created

Created `docs/designs/bear-chat-room-mock.png`, a high-fidelity portrait iPhone concept for the main Bear Chat room. It keeps the shared room and saved iMessage chat visible together, includes four customizable bears based on the supplied visual reference, identifies the current user's bear, and surfaces messaging, replay, emote, action, and reaction controls. The mock is ready for visual review; the product spec remains awaiting approval.

## 2026-09-20 — standalone messenger architecture and LLD drafted

Reframed Bear Chat from an iMessage extension into a standalone private iPhone messenger with Sign in with Apple, managed encryption, Supabase-backed room history, active-only bears, and tap-to-destination movement. Revised the product spec, created the larger Club Penguin-inspired room mock and standalone HLD, and derived `docs/designs/2026-09-20-bear-chat-standalone-hld-lld.md`. The LLD pins planned app/backend files, data invariants, RPCs, synchronization, movement, failure handling, and test ownership while leaving policy and platform gaps as explicit open questions. Independent HLD review was attempted but the reviewer task was cancelled, so the spec, mock, HLD, and LLD remain pending manual approval.

## 2026-09-20 — standalone implementation plan audited

Expanded `TODO.md` into a coverage-audited 200-task plan for the full standalone app. The plan preserves the existing approval tasks, surfaces every unresolved LLD product decision as manual work, separates schema families and administrative mutations at review boundaries, and assigns explicit tasks for failure handling, security, performance, accessibility, operations, and release verification. The dependency graph intentionally leaves implementation blocked until the product spec, mock, HLD, and LLD are approved; the validator reports `T1` and `T2` manual-ready and no agent-ready tasks.

## 2026-09-20 — Apple app provisioning completed

Completed `T18`: registered the explicit Bear Chat App ID, enabled Sign in with Apple, Push Notifications, and Associated Domains, configured Bear Chat as the primary Sign in with Apple App ID, provisioned an APNs authentication key, and verified automatic signing by running Bear Chat on a physical iPhone. Supabase Apple authentication setup in `T19` is no longer blocked by Apple provisioning.

## 2026-10-03 — local Supabase foundation scaffolded

Completed `T26`: added a pinned local Supabase CLI configuration, immutable migration and planned Edge Function directory boundaries, an intentionally empty seed entry point, a pgTAP database harness test, a strict Deno 2 function-test harness, and local workflow documentation. The Deno format/lint/test task passes and Supabase CLI 2.119.0 parses the configuration. The pgTAP smoke test could not run because no Docker-compatible runtime is installed on this machine; `T28` will run backend tests in CI.

## 2026-10-03 — backend CI added

Completed `T28`: added `.github/workflows/backend-ci.yml` with two jobs triggered on `supabase/**` changes. The Edge Function job installs Deno 2 and runs the `deno task --config supabase/deno.json check` gate (format, lint, tests). The database job uses the pinned Supabase CLI 2.119.0 to start the local stack, rebuild the database from migrations and seed with `db reset`, and run `supabase test db`. The Deno job was verified locally with Deno 2.9.7; the database job could not run locally because this machine has no Docker-compatible runtime, so it is verified only once it runs on the GitHub runner. Nothing committed yet.
