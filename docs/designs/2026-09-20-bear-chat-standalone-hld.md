# Bear Chat Standalone App High-Level Design

**Status:** Draft pending independent review
**Date:** 2026-09-20
**Source:** `docs/designs/product-spec.md`
**LLD:** [Bear Chat Standalone App Low-Level Design](2026-09-20-bear-chat-standalone-hld-lld.md)

## Problem

Bear Chat needs to deliver the combined room-and-chat experience shown in `docs/designs/bear-chat-room-mock-v2.png`, including a large walkable room, saved text history, authoritative recent activity, active-only bears, targeted interactions, invitations, notifications, and multi-device recovery. An iMessage extension cannot read or reproduce the iMessage transcript, so Bear Chat will instead be a standalone private messenger that owns its account, room, presence, movement, and message state. The system must remain small enough for an MVP while enforcing private room membership, deterministic event order, low-latency ephemeral movement, safe user-generated content handling, and clear managed-encryption privacy boundaries.

## Grounding

- `docs/designs/product-spec.md` now defines Bear Chat as a standalone iPhone messenger for private rooms of two to eight members. It requires Sign in with Apple, server-backed room history, active-only bears, exact ordering and latest-20 recent activity, private invitations, notifications, reporting, blocking, account deletion, and managed encryption rather than end-to-end encryption.
- `docs/designs/bear-chat-room-mock-v2.png` is the current visual direction. It expands the walkable room to roughly two-thirds of the screen, distributes bears across foreground and background depth, attaches names and speech to avatars, shows a tap destination, and keeps saved chat plus emote/action/reaction controls in a compact bottom panel. `docs/designs/bear-chat-room-mock-v2.svg` is its editable source; the original mock remains as visual provenance.
- Club Penguin used room-scale scenes as gathering places, movement across room surfaces, avatar speech and actions, and a persistent bottom toolbar for chat, emoticons, and actions. The relevant references are the Club Penguin Wiki's [List of Rooms](https://clubpenguin.fandom.com/wiki/List_of_Rooms), [Toolbar](https://clubpenguin.fandom.com/wiki/Toolbar), [Actions](https://clubpenguin.fandom.com/wiki/Actions), and [Penguin](https://clubpenguin.fandom.com/wiki/Penguin) galleries. Bear Chat adopts the room hierarchy, tap-to-destination movement, avatar labels/speech, and compact controls without copying Club Penguin's world navigation, art, or large public-room model.
- `AGENTS.md` records no selected stack, build commands, or implemented architecture. The repository currently contains project context and design artifacts only; there is no application code, persisted production data, or compatibility surface to migrate.
- `CLEANCODE.md` requires simple direct solutions, boundary validation, explicit domain states, focused files, and separate types/constants. The design therefore uses one native client, one managed backend platform, one append-only room event model, and no custom socket fleet or microservice split.
- `docs/decisions.md` currently records only the append-only decision-log convention. No prior architecture decision constrains the standalone design.
- The original no-account, no-content-service, and iMessage-extension assumptions are superseded by explicit product choices: Sign in with Apple, a full Bear Chat messenger, and service-readable content protected by encryption in transit and at rest.

## Goals / Non-goals

### Goals

- Ship a native iPhone app whose main room matches the structure and visual intent of `docs/designs/bear-chat-room-mock-v2.png`.
- Use Sign in with Apple for private, recoverable identity without a separate password, required phone number, address-book upload, or public profile.
- Keep rooms invite-only, enforce a maximum of eight members, and authorize every content operation against current membership on the service.
- Give every accepted message, action, and reaction one authoritative room sequence so all devices converge on the same order.
- Show only currently active room members as bears and accept targeted interactions only when the target has a valid presence lease.
- Let the user tap a walkable floor destination to move their bear, synchronize the latest destination to other active members, and use vertical position for room depth and draw order.
- Synchronize profile, appearance, room membership, messages, and recent activity across supported iPhones.
- Make active updates realtime while treating the database, not a socket delivery, as the source of record.
- Support offline viewing of cached content, explicit retry, push notifications, reporting, blocking, room removal, and account deletion.
- Store private content only for product operation and safety, with TLS, managed encryption at rest, strict access controls, content-free operational logs, and no advertising use.
- Use bundled, allowlisted bear assets and deterministic local animation so user content cannot execute or load remote rendering instructions.

### Non-goals

- iMessage extension functionality, iMessage transcript access, or mirroring another messaging service.
- End-to-end encryption in the MVP. Authorized service operations can access content, and the product must state that plainly.
- Public rooms, public profiles, searchable users, stranger discovery, social feeds, or address-book matching.
- More than eight room members or clients other than iPhone.
- Photos, file attachments, rich link previews, voice/video, calls, read receipts, edits, threads, or full-text search.
- User-uploaded visual assets, remote animation definitions, purchases, progression, or minigames.
- Independent microservices, a custom authentication system, or a custom long-running WebSocket service.
- Interactive furniture, avatar collision gameplay, physics, free-roaming world navigation, or more than one themed room layout in the MVP.
- Permanent replay of animations outside the authoritative latest 20 room events.

## Design

### Recommendation

Build one native iOS 17+ application in Swift 6. Use SwiftUI for app and feature UI, SpriteKit for the bear room and deterministic animations, SwiftData for the bounded local cache, and the Supabase Swift SDK for backend access. Use one Supabase project per environment, providing:

- Supabase Auth federated to Sign in with Apple.
- PostgreSQL as the source of record for profiles, rooms, memberships, invitations, ordered events, presence leases, devices, blocks, and reports.
- Realtime Postgres subscriptions as low-latency invalidation and event delivery.
- Database functions for transactional membership and event operations.
- Row Level Security for defense in depth on all user-accessible data.
- Edge Functions only for operations requiring protected service credentials, primarily APNs delivery and final account deletion.

This is the right-sized choice because the product is relational and authorization-heavy: room membership, an eight-member invariant, event references, ownership, blocks, invitations, exact sequence assignment, and deletion all benefit from PostgreSQL transactions and constraints. Supabase supplies Apple-backed authentication, database, realtime delivery, and serverless functions in one managed platform. It avoids operating separate authentication, chat, presence, notification, and socket systems while leaving the app's rendering and product behavior native.

Realtime is never the source of record. Every client reconnects by sequence from PostgreSQL, so dropped, duplicated, delayed, or out-of-order subscription notifications cannot corrupt conversation order.

### System shape

The system has three deployable surfaces:

- **iOS app:** authentication, local cache, room/chat UI, presence heartbeat, tap-to-move control and interpolation, rendering, composition, optimistic send states, accessibility, and notification handling.
- **Supabase backend:** authenticated data API, transactional database functions, RLS, realtime change delivery, scheduled cleanup, and environment-managed secrets.
- **Notification function:** receives a content-minimized event trigger, applies membership/mute/block/presence rules, and sends APNs notifications using credentials unavailable to the app.

There is no separate web app in the MVP. A minimal universal-link landing page handles invitation open/install routing without displaying room names, members, or content.

### Deployment and distribution

**Backend:** Each environment (development, staging, production) uses its own Supabase project. Development runs against Supabase CLI locally. Staging and production run on Supabase Cloud; the free tier is sufficient for early testing, with an upgrade to Pro ($25/month) before production launch for point-in-time recovery and higher connection/storage limits.

**iOS app — TestFlight (recommended for beta):** An Apple Developer Program membership ($99/year) is required regardless of distribution method. TestFlight is the primary distribution channel before App Store launch:

- **Internal testers:** Up to 25 members of the Apple Developer team. No Beta App Review required. Builds are available immediately after processing. Use this for the earliest testing rounds.
- **External testers:** Up to 10,000 testers via a shareable public link or email invitation. Requires a one-time Beta App Review (lighter than full App Store review but still checks for crashes, obvious bugs, and basic policy compliance). Use this once the app is stable enough for friends and wider testing.
- **Build lifecycle:** Each TestFlight build expires after 90 days. Testers receive automatic update notifications. Crash reports, screenshots, and tester feedback are collected through TestFlight.

TestFlight requires an archived Xcode build uploaded to App Store Connect. The CI pipeline (T27) should include an archive lane that produces a signed build suitable for TestFlight upload. App Store Connect requires a minimal app listing (name, bundle ID, primary language, SKU) before the first build can be uploaded, but does not require screenshots, full description, or completed privacy responses until App Store submission.

**iOS app — Ad Hoc (fallback):** If Beta App Review blocks early testing (e.g., missing privacy policy or content moderation), ad hoc distribution allows installing on up to 100 registered device UDIDs per membership year without any Apple review. This requires collecting each tester's UDID, adding it to the provisioning profile, and rebuilding. Use only as a stopgap; transition to TestFlight as soon as the beta review prerequisites are met.

**iOS app — App Store (production launch):** Full App Store submission requires completed privacy policy, App Store Connect metadata (screenshots, description, age rating, App Review information), content moderation and reporting capabilities, account deletion, and the managed-encryption privacy disclosures. This is rollout step 10 and beyond; it is not a prerequisite for friends to test the app.

### iOS application boundaries

Keep client code separated by responsibility rather than feature-wide god objects:

- **Domain:** profile, appearance, room, member, invitation, ordered event, event payload, presence, normalized room position, movement intent, send state, report, and notification preference types.
- **API:** typed Supabase Auth, query, RPC, Realtime, and Edge Function adapters. Raw backend dictionaries do not enter feature code.
- **Session:** Sign in with Apple lifecycle, authenticated user state, token refresh, sign-out, and account-deletion coordination.
- **Sync:** per-room catch-up by sequence, realtime subscription lifecycle, optimistic event reconciliation, retry, and local cache writes.
- **Presence and movement:** selected-room lease creation, heartbeat, clean leave, local expiry, grouping of multiple device sessions into one active user, destination validation, movement revision, interpolation, and depth ordering.
- **Stores:** SwiftData-backed profile, room summaries, bounded message pages, pending sends, and last confirmed sequence.
- **Rendering:** bundled asset catalog, appearance composition, transcript preview generation, SpriteKit room, walkable map, movement paths, playback queue, depth scaling, and Reduce Motion behavior.
- **Features:** onboarding, room list, main room, composer, activity, action/reaction pickers, bear editor, invitation/membership, notification settings, reporting/blocking, and account settings.

Domain types and constants remain separate from implementation files as required by `CLEANCODE.md`. Shared logic moves to a common module only after it has real reuse.

### Identity and profile

The iOS app performs the native Sign in with Apple flow using a nonce and exchanges the resulting identity token with Supabase Auth. Supabase's authenticated user ID is the stable internal identity. Bear Chat does not need to persist the Apple identity token, Apple email, or Apple-provided name after authentication. The user chooses a private Bear Chat display name and bear appearance stored in `profiles`.

The profile is visible only through a shared current room membership. It has a monotonically increasing revision so concurrent edits from two devices detect a stale save rather than silently overwriting a newer appearance. A successful save publishes a profile change through Realtime; active rooms update their rendered bear, and offline devices receive the latest profile on catch-up.

Signing out clears local sensitive caches after pending writes are resolved or explicitly discarded. Signing in again restores server-backed rooms and profile. Account deletion is a protected server operation: it removes devices, presence, invitations created solely by the account, and memberships; anonymizes retained event attribution as "Deleted Bear"; deletes the Bear Chat profile; and finally deletes the auth identity. Report evidence under active review follows the disclosed safety-retention policy rather than the general deletion path.

### Data model

The database uses generated UUID primary keys and UTC server timestamps. The high-level records are:

- **profiles:** authenticated user ID, display name, validated appearance document, revision, creation/update timestamps, and deletion marker.
- **rooms:** room ID, name, owner ID, layout ID, next event sequence, and creation timestamp.
- **room_members:** room/user pair, role, join timestamp, mute state, and last acknowledged sequence. A unique pair prevents duplicate membership.
- **room_invites:** room, creator, cryptographic token digest, expiry, optional use limit, use count, and revocation timestamp. Raw invite secrets are never stored.
- **room_events:** room, server sequence, sender or deleted-sender marker, client event ID, event kind, validated payload, optional target, optional referenced event, and server timestamp.
- **presence_sessions:** room, user, device connection ID, lease expiry, and update timestamp. Multiple devices may hold leases, but the roster groups them into one bear.
- **room_presence_state:** room/user pair, normalized destination, movement revision, and update timestamp. It stores only the latest ephemeral destination for an active bear and is removed after that user has no active lease.
- **push_devices:** user, installation ID, APNs token, preview preference, environment, and last-seen timestamp. Only protected server operations can enumerate tokens.
- **user_blocks:** blocker/blocked pair and timestamp.
- **reports:** reporter, room, reported user/event, disclosed content snapshot, category, status, reviewer audit metadata, and retention deadline.

Room events are append-only in normal product flows. The event payload is a discriminated schema for text, emote, group action, targeted interaction, or reaction. Text length, known action/reaction IDs, target shape, and reference shape are validated on the service. Payloads contain no remote asset URL or executable rendering instruction.

Indexes support room event pagination by descending sequence, membership lookup by user, active presence by room and expiry, one current movement state per room/user, invite digest lookup, idempotency by room/sender/client event ID, and pending safety reports. Content search is intentionally absent.

### Authorization and room lifecycle

RLS limits room, member, profile, event, and presence reads to signed-in current members. Client roles cannot directly insert or mutate protected room state. Narrow database functions perform operations transactionally and re-check the authenticated user inside the transaction.

Room creation inserts the room, owner membership, and first invitation in one transaction. Joining hashes the submitted invitation secret, locks the matching invitation and room membership set, verifies validity and use limits, enforces fewer than eight members, inserts membership, and increments use count. This prevents concurrent ninth-member joins.

Removing or leaving a member immediately removes their membership, presence sessions, and room position; subsequent reads and subscriptions fail membership authorization. Ownership transfer and owner departure occur in one transaction so a live room never lacks an owner. After explicit confirmation, room deletion revokes invitations, disconnects presence, and permanently deletes the room and its content in one protected operation.

Invitation links carry a high-entropy bearer secret. The universal-link page reveals no private room metadata before authentication and successful join. Owners can revoke or replace links, and the service rate-limits invite creation and join attempts.

### Authoritative event stream

All messages, actions, and reactions use one `send_room_event` transaction. It:

1. Verifies authenticated current membership and rate limits.
2. Validates the typed payload and referenced event against the same room.
3. For a targeted interaction, verifies the target is a current unblocked member with at least one unexpired presence lease.
4. Returns the existing event when the same sender retries a known client event ID.
5. Locks the room sequence, assigns the next integer, inserts the event, and commits.

The returned server sequence is the only canonical order. The client may display a pending event immediately, but it replaces that projection with the committed event or marks the send failed. A retry reuses the client event ID, making it idempotent.

The latest 20 events by sequence are the authoritative recent-activity list. Actions and reactions among those events are replayable from bundled semantic IDs. Older text and plain-language action entries remain pageable in chat, but the UI does not offer animation replay outside the latest 20.

An action received while the room is open enters one serial playback queue in sequence order. Catch-up events do not autoplay on launch; the user can replay retained events. Reduce Motion produces the same final state and text/VoiceOver description without nonessential movement.

### Presence and movement

Presence exists only for the room currently open on a device. On entry, the app creates a random connection ID and upserts a 30-second `presence_sessions` lease. It refreshes the lease every 10 seconds while foreground-active and deletes its own lease best effort on room exit or app deactivation.

Clients subscribe to presence changes and run a local expiry timer based on server expiry timestamps. A clean leave normally removes the bear within 5 seconds; an interrupted session disappears no later than the 30-second lease. Expired rows are ignored immediately and removed later by scheduled cleanup, so cleanup timing does not determine user-visible correctness.

The active roster groups all unexpired sessions by authenticated user, preventing one signed-in person on multiple devices from appearing as multiple bears. The local user's bear renders immediately. Remote bears render only while at least one validated lease exists. If presence is unavailable, chat remains usable, only the local bear is shown, non-targeted actions remain sendable, and targeted interactions are disabled.

Target selection uses the active roster. The event transaction performs the authoritative lease check at commit time. A target may disconnect immediately after acceptance; the event remains valid and readable because the target was active when accepted, but the app does not claim the remote animation played.

The MVP ships one versioned room layout with a normalized walkable map and named accessibility destinations. Tapping an unoccupied walkable point immediately places a temporary destination marker and starts optimistic local movement. Tapping another bear selects that participant for an interaction instead. The user never needs to move in order to chat or use other controls.

One `move_room_bear` database function accepts a normalized destination and the caller's connection ID. It verifies current membership, an unexpired matching presence session, coordinate bounds, and a per-user movement rate limit, then increments the room/user movement revision and updates `room_presence_state`. It stores a destination command, not frame-by-frame coordinates. Realtime publishes that latest state to current room members.

Each client animates from the bear's current displayed position to the newest destination at a fixed room speed. A newer movement revision supersedes an older path, and all clients converge on the same final destination even if their interpolation differs briefly. The bundled walkable map clamps a destination away from furniture and off-floor areas; server coordinate bounds prevent malformed values, while this visual-only state is never treated as an authorization input.

Vertical position controls a bounded scale range and SpriteKit draw order, creating the foreground/background depth seen in Club Penguin rooms without 3D physics. Bears do not block one another, so crowded rooms cannot deadlock movement; overlap is resolved visually by vertical draw order. An action may temporarily take control of the actor and target animations, then returns each bear to its latest destination.

When the last presence session for a room/user expires, the position row is ignored immediately and cleaned up with the lease. Re-entering after all sessions ended uses a deterministic entry area with a small collision-avoiding offset. If the same identity controls a room from two iPhones, the newest accepted movement revision wins and both devices converge to it.

### Synchronization and offline behavior

SwiftData stores room summaries, profile/appearance, bounded pages of room events, pending client event IDs, and each room's last confirmed sequence with complete file protection. It is a cache, not an authorization source.

Opening a room renders cached chat state first, fetches events after the last confirmed sequence, reconciles pending sends, refreshes profiles and membership, then starts Realtime subscriptions. Subscription events are deduplicated by event ID and applied only in contiguous sequence. A gap triggers a database catch-up rather than guessing. Movement revisions are a separate ephemeral latest-state stream and never enter the durable room sequence. Returning from background repeats event catch-up before presence and movement are published.

Older history loads by sequence cursor. Cache eviction keeps recent rooms and pages within a measured device budget and never deletes unsent drafts. While offline, the user can read cached content and edit a local bear draft. Sending remains an explicit pending action and is retried only with the user's intent or a clearly indicated reconnect policy; it is never shown as accepted before the service commits it.

### Notifications and invitations

A committed event emits a content-minimized database webhook to the notification Edge Function. The function determines current members, excludes the sender, muted rooms, blocked directed notifications, and users actively present in that room, then sends APNs through token-based credentials stored only as backend secrets.

Notifications are generic by default and contain an opaque room/event routing identifier, not message text. If a user explicitly enables detailed previews, the function may include the sender display name and bounded text after applying the same membership and block checks. Opening a notification authenticates, navigates to the room, and catches up from the database rather than trusting notification content.

The invitation landing page supports Universal Links and App Store fallback. It retains the invitation only long enough to resume the join flow after installation/sign-in and does not embed room metadata in social preview tags.

### Rendering and customization

All room art, appearance layers, emotes, interactions, reactions, and audio ship in the app and are addressed by allowlisted semantic IDs. A bear is assembled from ordered SpriteKit layers. Compatibility rules for clothing and accessories ship as versioned local data and are also validated against an accepted appearance schema before the profile is stored.

The main room uses the visual hierarchy in `docs/designs/bear-chat-room-mock-v2.png`: the room occupies roughly the upper two-thirds of a portrait phone, while a draggable compact chat panel holds recent messages, composer, and direct emote/action/reaction controls. Expanding the panel reveals history; collapsing it restores room space. The chat remains available when rendering or animation fails.

The single MVP room layout includes a bundled walkable polygon, named accessibility destinations, foreground scale bounds, and obstacle masks. A destination ripple gives immediate tap feedback. Bears display their room name beneath them, speech bubbles track their moving sprite, and vertical position determines both scale and z-order. One to eight active bears can overlap without blocking movement, while labels and speech bubbles use bounded collision avoidance to remain readable.

VoiceOver exposes the walkable map as named destinations such as "back left," "center rug," and "front right" instead of requiring spatial tapping. Reduce Motion uses a short crossfade or direct position change while producing the same shared destination. Movement controls never take focus away from chat or make movement a prerequisite for messaging.

The editor works on a draft. Save validates compatibility and profile revision, commits the new appearance, updates the local bear, and lets Realtime update other active clients. Cancel discards the draft. Unknown future asset IDs render a safe default and never trigger a remote download.

### Privacy, safety, and operational boundaries

- TLS protects client/service and backend/APNs connections. Supabase-managed storage and backups must have encryption at rest enabled and verified before production. This is managed encryption, not end-to-end encryption.
- Production service roles and database credentials never ship in the app. RLS, membership checks, and database constraints protect data even when a modified client bypasses UI rules.
- General logs and metrics include operation name, status, latency, environment, and non-content error codes. They exclude message text, appearance payloads, invite secrets, Apple tokens, APNs payload contents, raw notification tokens, and movement coordinates.
- Access to production content for safety or incident response uses separate least-privilege roles, audited access, and a documented reason. Report review exposes only the content the reporter was told would be submitted.
- Blocking prevents directed interactions and notifications between the pair. It does not silently rewrite shared room history; the blocker can leave, report, or ask the owner to remove the member.
- Rate limits apply per authenticated user and room to event sends, movement destinations, presence heartbeats, invite creation, join attempts, reports, and push-device registration.
- User text is displayed as text only. Links are not made interactive in MVP, and payload fields are bounded before database insertion or rendering.
- Database migrations are version-controlled and promoted through development, staging, and production. Production has point-in-time recovery, restore drills, secret rotation, budget alerts, and provider-status monitoring.
- Service availability failures degrade to cached chat and editing. No backend failure can execute arbitrary client content or erase confirmed local state without a subsequent authoritative sync.

### Failure behavior

- Sign in unavailable: preserve signed-out local onboarding state and retry; never create an unlinked shadow account.
- Invalid or full invitation: explain the reason without revealing room metadata.
- Membership removed: stop subscriptions and presence, clear protected room cache after showing that access ended, and return to the room list.
- Sequence gap or Realtime disconnect: pause autoplay, fetch canonical events by sequence, then resume.
- Immediate or server send failure: retain the pending event and offer idempotent retry; do not assign a fake sequence.
- Presence failure: show only the local bear, keep chat and non-targeted actions usable, and disable targeted interactions.
- Movement update rejected or disconnected: stop at the last confirmed destination, remove the pending marker, and keep chat usable; movement is not queued for later replay.
- Invalid or stale remote movement: ignore older revisions and clamp malformed destinations to the nearest valid walkable point before rendering.
- Target expired during send: reject the interaction before insertion and return to target selection.
- Unknown or malformed event/appearance: show a safe unsupported description or default bear; do not animate it.
- Animation failure or Reduce Motion: show the final state and equivalent text/VoiceOver description.
- Push failure: record content-free delivery diagnostics; room catch-up remains authoritative when the user opens the app.
- Local cache corruption: discard the replaceable cache after preserving pending drafts separately, then restore from the service.

## Risks

- **Managed-content privacy:** Bear Chat and its infrastructure can technically access message content. Policy, least privilege, audit controls, content-free logs, and accurate user communication are mandatory; this design must not be marketed as end-to-end encrypted.
- **User-generated-content obligations:** Private messaging still requires reporting, blocking, moderation operations, published policies, and responsive safety handling for App Store review and user trust. This is product operations, not only code.
- **RLS or database-function mistakes:** A single authorization error could expose private rooms. Adversarial multi-user policy tests and direct API tests are release gates.
- **Presence write load:** Ten-second database heartbeats create steady write and Realtime volume. The physical-device/backend spike must validate cost and latency; the interval can increase if the 30-second product expiry remains satisfied.
- **Movement update load:** Repeated taps add ephemeral database writes and Realtime traffic. Send only destination changes, apply a short client debounce and server rate limit, and measure worst-case eight-person tapping before launch.
- **Movement convergence:** Realtime delay can make clients show slightly different paths before they converge on the latest destination. Movement is intentionally social animation rather than authoritative gameplay; only final destination and revision are shared.
- **Movement accessibility and touch conflict:** Free-form floor taps can conflict with bear selection, chat-panel gestures, and VoiceOver. Walkable-space hit testing, named accessible destinations, clear destination feedback, and a nonessential movement model are release requirements.
- **Realtime is not guaranteed delivery:** Subscriptions can disconnect or reorder notifications. The sequence catch-up design is required and must not be simplified into socket-only state.
- **Concurrent event throughput:** Locking one room sequence serializes writes. With only eight members this is intentionally simple, but contention and retry behavior still require load tests.
- **Sign in with Apple configuration:** Capability, nonce, redirect, token refresh, revoked credentials, and private relay behavior can fail across environments. Authentication needs an early end-to-end spike.
- **Deletion semantics:** Anonymizing a departed user's entries while preserving other members' conversation integrity may not match every user's expectation. Product copy and policy must state what deletion does before launch.
- **Invitation forwarding:** Anyone holding a valid invite secret can attempt to join. Expiry, revocation, use limits, authenticated join, room capacity, and rate limits reduce but do not eliminate intentional forwarding.
- **Notification privacy:** Detailed previews pass bounded content through APNs and lock-screen settings. They remain opt-in; generic notifications are the default.
- **Vendor dependency:** Supabase availability, pricing, Realtime behavior, backup features, and Swift SDK changes affect the product. Standard PostgreSQL schema and isolated API adapters reduce but do not remove lock-in.
- **Eight-bear rendering:** Layer combinations, text, and simultaneous animation can exceed memory or frame-time budgets on the oldest supported iPhone. Asset and playback budgets must be measured before content production scales.
- **Local cache sensitivity:** SwiftData holds private content on device. Complete file protection, sign-out/account-removal cleanup, notification privacy, and device testing are required.
- **Minimum OS scope:** iOS 17 simplifies SwiftUI and SwiftData architecture but excludes older iPhones. This support boundary must be confirmed as part of product approval.

## Rollout

1. **Approve the standalone scope.** Confirm the revised product spec, iOS 17 minimum, Sign in with Apple, managed rather than end-to-end encryption, deletion semantics, and `docs/designs/bear-chat-room-mock-v2.png` as the visual target.
2. **Run an architecture spike.** Prove Sign in with Apple through Supabase Auth, native session restoration, RLS isolation between two test users, transactional event sequence/idempotency, Realtime gap recovery, 10-second presence leases, destination-only movement revisions, APNs routing, SwiftData restore, and a moving one-to-eight-bear SpriteKit scene on physical devices.
3. **Establish backend foundations.** Create development/staging projects, versioned migrations, schema, constraints, database functions, RLS tests, seed fixtures, secret management, backups, sanitized observability, and deployment automation.
4. **Build the app shell and identity.** Add navigation, Sign in with Apple, session lifecycle, profile/display name, default bear, editor persistence, sign-out, and account-deletion skeleton.
5. **Build rooms and invitations.** Add room list, create/join, universal links, capacity enforcement, membership, ownership transfer, removal, mute, leave, and delete.
6. **Build ordered chat and sync.** Add composer, event transaction, optimistic states, idempotent retry, sequence catch-up, Realtime subscriptions, SwiftData cache, pagination, and reconnect behavior.
7. **Build presence, movement, and the visual room.** Add lease heartbeat/expiry, active roster, bundled walkable map, tap-to-destination movement, movement revision sync, depth scale/z-order, one-to-eight bear layout, attached names and speech, current-user marker, degraded presence behavior, named VoiceOver destinations, and Reduce Motion.
8. **Build actions, reactions, and activity.** Add bundled catalogs, active-target validation, serial playback, exact latest-20 recent activity, replay, plain-language fallbacks, and malformed-event handling.
9. **Build notifications and safety.** Add generic/opt-in detailed APNs, room mute, block, report, owner removal, rate limits, audited safety access, and final account/room deletion workflows.
10. **Harden and beta.** Complete privacy review, App Store policy review, restore drill, concurrency/load tests, accessibility audit, oldest-device profiling, TestFlight monitoring, and production rollback practice before launch.

## Verification

- **Requirements traceability:** Map every functional and non-functional requirement in `docs/designs/product-spec.md` to an automated test, measured check, policy review, or named manual scenario before beta sign-off.
- **Authentication:** Test first sign-in, returning sign-in, second iPhone restore, revoked Apple credentials, cancelled flow, token refresh, sign-out, account deletion, and cross-environment isolation without persisting unnecessary Apple data.
- **Authorization:** With at least three independent test identities, attempt every room/profile/event/presence/invite/report operation as a member, removed member, nonmember, blocked member, and unauthenticated client through both normal and direct APIs. No UI-only rule counts as authorization.
- **Room invariants:** Concurrently join a nearly full room and prove only eight memberships commit. Test revoked/expired/limited invites, owner transfer, owner leave, member removal, room deletion, and immediate loss of data access.
- **Event correctness:** Under concurrent sends from eight clients, prove unique contiguous server sequences, idempotent retry by client event ID, valid same-room references, rejected malformed payloads, target-presence checks, and exact latest-20 results.
- **Realtime recovery:** Drop, duplicate, delay, and reorder subscription notifications; background and terminate clients; then prove sequence catch-up converges every device without duplicate chat entries or autoplaying old actions.
- **Presence:** Test clean exit, force-quit, network loss, reconnect, multiple devices for one user, room switching, expired leases, backend outage, blocked targets, and target disconnect during send against the 2/5/30-second product thresholds.
- **Movement:** Test valid/invalid floor taps, taps on another bear, rapid retargeting, stale and duplicated revisions, network delay, reconnect, two devices controlling one identity, all eight users moving, entry spawn, last-session expiry, obstacle clamping, z-order/scale, action interruption, destination rate limits, and convergence within the 0.2/1-second product thresholds.
- **Offline/cache:** Verify cached reading, protected local files, pending draft preservation, explicit retry, pagination, sign-out cleanup, removed-member cleanup, cache corruption recovery, and service restore after reinstall/sign-in.
- **Notifications:** Test generic defaults, detailed-preview opt-in, room mute, block, active-room suppression, stale device tokens, removed members, invitation routing, App Store fallback, and catch-up when APNs is delayed or absent.
- **Safety and deletion:** Verify report disclosure and exact captured context, safety-role isolation and audit records, owner removal, rate limits, profile anonymization, device/presence cleanup, room deletion, report-retention exception, and final auth deletion.
- **Payload security:** Fuzz text and structured event boundaries with oversized, deeply nested, invalid Unicode, unknown kind, remote URL, cross-room reference, invalid asset, duplicate ID, and future-schema inputs. The service rejects them safely and the renderer never executes them.
- **Privacy:** Confirm TLS, provider encryption-at-rest settings, backup encryption, least-privilege production roles, secret separation, content-free logs/metrics, no movement-coordinate logging, no ad SDK, no address-book access, and accurate non-E2EE product copy. Inspect notification payloads and production log samples before release.
- **Performance:** On the oldest supported iPhone and production-like backend, measure cached room usability within 2 seconds, control feedback and local movement start within 0.2 seconds, remote movement start within 1 second, newest-page load, eight-moving-bear frame time/memory, event commit latency, realtime propagation, movement write volume, and presence thresholds.
- **Accessibility:** Run VoiceOver named movement destinations and position announcements, Dynamic Type, high contrast, Reduce Motion movement replacement, keyboard focus where applicable, and non-color status checks across onboarding, room list, chat, active bears, controls, membership, reporting, and editor.
- **Operations:** Restore a staging backup, roll a migration forward and back, rotate secrets, simulate Supabase and APNs outages, validate budget/rate alerts, and demonstrate that cached chat remains readable during service degradation.
- **Visual acceptance:** Compare the main room on supported screen sizes against `docs/designs/bear-chat-room-mock-v2.png`, allowing platform-safe layout adaptation while preserving the enlarged walkable room, depth-scaled moving bears, names and speech attached to avatars, compact expandable chat, current-user identity, readable history, and direct action controls.
