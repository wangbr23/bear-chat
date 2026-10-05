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

## 2026-10-03 — No Account domain type; Profile is the identity shape

**Status:** Accepted

**Context:** T32 was titled "account, profile, and versioned appearance domain types" and the LLD file plan pins `Account.swift` with "Account and profile domain shapes", but the LLD's client-domain sketches define fields only for `Profile` and `Appearance` — there is no Account sketch. During the T32 review, the reviewer questioned whether `Account` was needed versus just `Profile`.

**Decision:** Ship no `Account` type. `Domain/Models/Account.swift` keeps its LLD-pinned name but holds only `Profile`. The signed-in user ID is available from the Supabase auth session, and the signed-in/out/onboarding routing state is a SessionController concern (T104), which will define the session shape it actually needs. Future tasks should not re-introduce an Account wrapper without a consumer.

**Consequences:** The T32 task title's "account" wording is satisfied by `Profile` living in `Account.swift`. Any later task that wants a session/identity bundle (e.g. T104 routing) defines it locally at that point rather than speculatively.

## 2026-10-04 — Defer RoomDetail until a consumer defines it

**Status:** Accepted

**Context:** The LLD file plan describes `Room.swift` as holding room summary, detail, member, and role shapes, but its client-domain section defines fields only for `RoomSummary` and `RoomMember`. T33 has no current feature or API consumer that establishes a distinct detail shape.

**Decision:** Do not invent a `RoomDetail` type during T33. Keep the exact summary/member/role shapes now, and let the first concrete room-detail query or feature define the additional type if it needs one.

**Consequences:** T33 stays aligned with fields actually specified by the LLD and avoids a speculative wrapper. A later task such as T95 may introduce `RoomDetail` once its query contract establishes the required fields.

## 2026-10-04 — Confirmed sends leave the pending-send state model

**Status:** Accepted

**Context:** The LLD file-plan comment describes draft, sending, committed, and failed send states, while its detailed pending-event sketch and synchronization flow use draft, sending, awaiting reconciliation, and failed. The flow says server confirmation replaces the optimistic projection with the canonical event carrying a server sequence.

**Decision:** `SendState` models only pending lifecycle states: draft, sending, awaiting reconciliation, and failed. A confirmed send is removed from pending storage and represented as `RoomEvent`; there is no committed pending state.

**Consequences:** UI and synchronization reducers have one canonical representation after confirmation and cannot show the same event as both pending and committed. Reconciliation by `clientEventID` performs the transition without resending or duplicating the event.

## 2026-10-04 — Push-device environment means APNs environment

**Status:** Accepted

**Context:** The HLD and LLD give each push-device registration an `environment` field but do not say whether it identifies a Bear Chat deployment or the APNs endpoint where the device token is valid. Bear Chat already isolates development, staging, and production in separate Supabase projects, while APNs tokens must be sent through either the sandbox or production service.

**Decision:** Model the push-device environment as the closed APNs values `sandbox` and `production`. Do not duplicate the Bear Chat deployment environment in the client push-device registration type.

**Consequences:** Push registration and delivery can route each token to the correct APNs service. The selected Supabase project continues to identify the Bear Chat deployment environment independently.

## 2026-10-04 — Safety report value sets stay deferred to T9/T13

**Status:** Accepted

**Context:** T37 pins the `Safety.swift` domain shapes, but the LLD's resolved open questions defer report categories, disclosed context, reviewer fields, and retention policy (T9), as well as the safety-review interface (T13). The LLD fixes only the structural contract: `create_report` takes room, category, nullable reported user/event, and a confirmed disclosure version and returns a report ID and status; client reads expose status but never reviewer metadata.

**Decision:** Model the block request, report submission envelope, and client-visible report receipt now, with category and status as plain strings. Do not invent category or status value sets; introduce closed enums when T9/T13 approve them. The presented disclosure content itself (what the reporter is told will be shared) is defined by T161 together with T9's approved context, not by this domain file.

**Consequences:** The report API adapter (T102) and report UI (T161) can build against stable shapes without inventing policy. A later change narrows category/status into closed enums without altering the submission envelope.

## 2026-10-04 — Appearance validation splits between schema shape and RPC allowlist

**Status:** Accepted

**Context:** The LLD requires a "validated appearance jsonb" on `profiles` and says the profile functions "validate allowlists and compatibility", but does not say how much validation belongs in the table itself. The catalog release (T22) that defines the real asset IDs and compatibility rules is not final, and T51 seeds `asset_catalog_entries` from it later.

**Decision:** The profiles table enforces only the structural shape of the appearance document — positive integer `schemaVersion`, non-empty string body/face/fur-color/accent IDs, JSON arrays for clothing and accessory IDs — wrapped in `coalesce(..., false)` so missing or null keys fail instead of passing as NULL. Allowlist membership and compatibility checking happen inside the protected profile functions (T60) against seeded `asset_catalog_entries`. `asset_catalog_entries.kind` stays unconstrained text so new catalog kinds arrive as seed rows (T51) rather than enum migrations, and the compatibility jsonb carries no size check because the table is never client-writable.

**Consequences:** Malformed payloads can never be stored while catalog knowledge stays in one place (the seeded catalog) instead of being duplicated into schema DDL. A future appearance-schema version updates this structural check through a normal migration.

## 2026-10-04 — Permanently delete rooms without delayed purge state

**Status:** Accepted

**Context:** T8 approved immediate permanent room deletion with a confirmation warning, but the HLD, LLD, and T70 still described soft deletion through `deleted_at`/`purge_after` followed by scheduled cleanup. T42 needed one model before defining the rooms table.

**Decision:** Room deletion is a protected hard-delete operation. The `rooms` table has no deletion marker or purge timestamp; deleting a room cascades to ordinary room-owned records. T69 implements the owner-only transaction, and the scheduled room-purge task T70 is retired. Separately retained safety-report evidence remains governed by the disclosure and retention policy that T9/T13 will approve and must not prevent room deletion.

**Consequences:** Deleted rooms and their ordinary content disappear immediately rather than relying on RLS to hide pending data. Later schemas must use room-delete cascades where content belongs solely to a room, while any approved safety evidence must be modeled independently enough to survive only for its disclosed retention period.
