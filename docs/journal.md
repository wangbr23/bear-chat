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

## 2026-10-03 — environment configuration boundaries added

Completed `T29`, scoped to development and staging only because the production Supabase project is not provisioned yet. `BearChat/project.yml` now maps the Debug configuration to `Configuration/Development.xcconfig` and the Release configuration to `Configuration/Staging.xcconfig` (previously Release pointed at the placeholder `Production.xcconfig`); the Xcode project was regenerated with xcodegen and both configurations build for the iOS Simulator. `Production.xcconfig` stays committed as the landing spot for when T19 completes. Staging endpoint values remain placeholders until the real URL and anon key are filled in. A `supabase/.env.example` was deliberately left out until Edge Function work begins around T153.

## 2026-10-03 — iOS CI and requirements traceability added

Completed `T27` and `T30` together. `T27` added `.github/workflows/ios-ci.yml`: a `macos-latest` job that selects the newest installed Xcode, picks the first available iPhone simulator at run time (local simulators are the iOS 26.5 iPhone 17 generation, so names are not portable across machines), and runs the committed BearChat scheme's unit tests. Unit tests were verified locally with `xcodebuild test`; the workflow itself is verified on first push. `T30` created `docs/verification/requirements-traceability.md` with one row for each of the 111 leaf FR/NFR IDs in the product spec, verified complete by an automated ID set-diff, mapping each to planned verification tasks and artifact names from the LLD test-mapping table. Every row names Bradley Wang as verification owner and is planned-not-yet-verified; `T185` records final references. With `T27` and `T28` done, `T31` (AGENTS.md stack and commands) is now unblocked.

## 2026-10-03 — AGENTS.md reflects the real project

Completed `T31`: replaced AGENTS.md's placeholder stack, commands, and architecture sections with the actual shape — Swift 6/iOS 17+ app with SwiftUI, SpriteKit, SwiftData, and the pinned Supabase Swift SDK; real xcodebuild/supabase/deno test commands matching what CI runs; the GitHub Actions workflows; and a three-bullet architecture summary (app, backend, design source of truth). Also replaced the outdated iMessage-extension one-liner with the standalone-app description. Project foundations are now fully documented; the next frontier is the client domain types (T32–T39).

## 2026-10-03 — Account, profile, and appearance domain types

Completed `T32` (first of the T32–T39 domain-type wave): created `BearChatApp/Domain/Models/Appearance.swift` with the versioned `Appearance` ID shape and `Account.swift` with `Account` (user ID + optional `Profile`) and `Profile` (id, display name, appearance, revision, updatedAt), exactly following the LLD client-domain sketches. Bradley chose to skip unit tests for these — they are pure value types with no behavior, so there is nothing to assert beyond field round-trips; the LLD does not sketch `Account`, so it was kept minimal (user ID + optional profile, which encodes the signed-in-without-profile onboarding state from the sign-in flow). Verified with a successful `xcodebuild build` on the iPhone 17 Pro simulator; no tests run because none were added. Remaining frontier: T33–T39.

## 2026-10-03 — Dropped the Account domain type after review

During the Sideye review of `T32`, Bradley asked whether `Account` was needed versus just `Profile`. Conclusion: drop it. The LLD sketches fields for `Profile` and `Appearance` but never `Account`, the HLD's domain-type list has no account type, and nothing consumes the wrapper yet — the signed-in user ID is available from the Supabase session, and the signed-in/onboarding routing state belongs to `SessionController` (T104), which will define its own session shape when implemented. `Account.swift` now holds only `Profile` (file name unchanged per the LLD file plan); decision recorded in docs/decisions.md.

## 2026-10-04 — Room, membership, and invitation domain types

Completed `T33`: added `Room.swift` with the closed owner/member role plus the LLD's exact `RoomSummary` and `RoomMember` fields, and `Invitation.swift` with safe invite metadata (never the raw secret or digest) plus typed success, invalid, expired, used, and room-full join outcomes matching the protected RPC contract. `RoomDetail` remains deferred because the LLD names it in the file plan but defines no fields and no current consumer needs it; this is recorded in docs/decisions.md. No field-round-trip tests were added for the behavior-free value types. The full BearChat `xcodebuild test` command passed on the iPhone 17 Pro simulator. Remaining domain-model frontier: T34–T39.

## 2026-10-04 — Ordered event and pending-send domain types

Completed `T34`: added `RoomEvent.swift` with the canonical ordered event envelope, closed event kinds, all five versioned payload variants, and an unsupported-version fallback; added `SendState.swift` with durable retry identity, immutable request values, draft/sending/awaiting-reconciliation/failed states, and typed failure reasons. `failed` carries its reason directly so drafts and in-flight sends cannot carry stale errors. Confirmed sends leave the pending model and become `RoomEvent` values with server-assigned sequence numbers; this reconciliation is recorded in docs/decisions.md. No field-round-trip tests were added for the behavior-free value types. The full BearChat `xcodebuild test` command passed on the iPhone 17 Pro simulator. Remaining domain-model frontier: T35–T39.

## 2026-10-04 — Presence and movement domain types

Completed `T35`: added `Presence.swift` with the LLD-defined `PresenceSession` lease and grouped `ActiveBear` projection, and `Movement.swift` with `NormalizedPosition`, explicit request states, and `MovementState`. The types follow the existing immutable `Sendable` domain-model style and contain no networking, persistence, validation, or rendering behavior. No field-round-trip tests were added for the behavior-free value types. The full BearChat `xcodebuild test` command passed on the iPhone 17 Pro simulator. Remaining domain-model frontier: T36–T39.

## 2026-10-04 — Normalized movement coordinates validated after review

Sideye review found that `NormalizedPosition` could previously contain out-of-range or non-finite coordinates despite its validity-implying name. Added a failable initializer that accepts only finite x/y values in the inclusive 0...1 range, plus focused tests for boundaries, interior coordinates, out-of-range values, infinities, and NaN. Regenerated the Xcode project so the newly added source and test files are included; this also revealed that adding files under the XcodeGen source paths does not compile them until regeneration. The full BearChat `xcodebuild test` suite passed with all 11 coordinate cases. Backend checks remain unavailable locally: Deno is not installed, and the Supabase database is not running because this machine has no Docker-compatible runtime.

## 2026-10-04 — Push-device and notification-preference domain types

Completed `T36`: added `NotificationPreference.swift` with closed APNs sandbox/production environments, generic/detailed preview modes, the client-owned push-registration values, and per-room mute preference. Bradley confirmed that the registration environment identifies the APNs endpoint rather than the separate Bear Chat deployment environment; the decision is recorded in `docs/decisions.md`. The file contains no server-owned user ID or last-seen timestamp because clients submit registrations but cannot read protected push-device rows. No field-round-trip tests were added for the behavior-free value types. Regenerated the Xcode project and confirmed the new file is in the app target; the full BearChat `xcodebuild test` suite passed on the iPhone 17 Pro simulator. Remaining domain-model frontier: T37–T39.

## 2026-10-04 — Block, report, and safety-status domain types

Completed `T37`: added `Safety.swift` with `UserBlockRequest` mirroring `set_user_block`, `ReportSubmission` mirroring `create_report` (room, category, nullable reported user/event, confirmed disclosure version), and `ReportReceipt` carrying only the report ID and a content-free status — client reads never expose reviewer metadata. Report categories, disclosed context, retention, reviewer fields, and the closed status values are deferred product decisions (T9, T13), so category and status stay plain strings for now and the deferral is recorded in `docs/decisions.md`; T161 and T9 introduce the approved closed enums. No field-round-trip tests were added for the behavior-free value types. Regenerated the Xcode project and confirmed the new file is in the app target; the full BearChat `xcodebuild test` suite passed on the iPhone 17 Pro simulator. Remaining domain-model frontier: T38–T39.
