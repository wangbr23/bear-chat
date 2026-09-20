# Bear Chat Standalone App Low-Level Design

**Status:** Draft derived from an HLD pending approval
**Date:** 2026-09-20
**HLD:** [Bear Chat Standalone App High-Level Design](2026-09-20-bear-chat-standalone-hld.md)
**Source:** `docs/designs/product-spec.md`

## Overview

Bear Chat will be one native iOS application backed by one Supabase project per environment. SwiftUI feature views call typed service boundaries, room coordination combines a bounded SwiftData cache with PostgreSQL catch-up and Realtime invalidations, SpriteKit renders the bundled walkable room, and narrow PostgreSQL functions own every transactional or authorization-sensitive mutation. This document derives implementation details from the HLD rather than reopening its product and architecture choices. The repository currently has no application or backend code, so every path below is a planned path.

## Package/file layout

The MVP uses one application target and two test targets. Source folders enforce boundaries without introducing local Swift packages before there is a demonstrated build or reuse need.

```text
BearChat/
  BearChat.xcodeproj/                         # Committed Xcode project and Swift Package Manager pins.
  Configuration/
    Base.xcconfig                             # Non-secret build settings shared by all environments.
    Development.xcconfig                      # Development Supabase URL and public anon key references.
    Staging.xcconfig                          # Staging endpoint references.
    Production.xcconfig                       # Production endpoint references.
    Secrets.xcconfig.example                  # Names of required local values; never real credentials.
  BearChatApp/
    App/
      BearChatApp.swift                       # App entry point and scene lifecycle only.
      AppEnvironment.swift                    # Constructs concrete services once per process.
      AppRoute.swift                          # Typed app, room, invitation, and settings routes.
      RootView.swift                          # Switches signed-out, onboarding, and signed-in roots.
    Domain/
      Models/
        Account.swift                         # Account and profile domain shapes.
        Appearance.swift                      # Versioned, allowlisted appearance shape.
        Room.swift                            # Room summary, detail, member, and role shapes.
        RoomEvent.swift                       # Ordered event envelope and payload variants.
        Presence.swift                        # Lease, active bear, and roster shapes.
        Movement.swift                        # Normalized positions, revisions, and move states.
        Invitation.swift                      # Invite metadata and join-result shapes.
        NotificationPreference.swift          # Per-device preview and per-room mute shapes.
        Safety.swift                          # Block, report disclosure, and report status shapes.
        SendState.swift                       # Explicit draft, sending, committed, and failed states.
        RoomConnectionState.swift             # Cache, catch-up, live, reconnecting, and revoked states.
      Constants/
        ProductLimits.swift                   # Member, text, page, latest-activity, and cache limits.
        PresenceTiming.swift                  # 10-second heartbeat and 30-second lease constants.
        MovementTiming.swift                  # Debounce, speed, and feedback timing constants.
        AssetIdentifiers.swift                # Semantic built-in IDs and schema versions.
    Data/
      SecureStorage/
        KeychainStore.swift                    # Minimal Keychain read/write/delete wrapper.
        AuthLocalStorage.swift                 # Supabase Auth storage backed by Keychain.
        InstallationIDStore.swift              # Stable, non-user-visible installation UUID.
      API/
        DTO/
          ProfileDTO.swift                    # Database representation of a profile.
          RoomDTO.swift                       # Room and member database representations.
          RoomEventDTO.swift                  # Event and discriminated payload wire shapes.
          PresenceDTO.swift                   # Session, roster, and movement wire shapes.
          InvitationDTO.swift                 # Invitation RPC inputs and results.
          SafetyDTO.swift                     # Report and block RPC inputs and results.
        SupabaseAuthAPI.swift                 # Apple token exchange and session operations.
        SupabaseProfileAPI.swift              # Profile fetch and optimistic-revision save.
        SupabaseRoomAPI.swift                 # Room, member, invitation, mute, block, and report calls.
        SupabaseEventAPI.swift                # Event pages, event reconciliation, and send RPC.
        SupabasePresenceAPI.swift             # Presence lease and movement RPCs and snapshots.
        SupabaseRealtimeAPI.swift             # Typed channel construction and lifecycle.
        SupabaseDeviceAPI.swift               # Push-device registration and removal.
        SupabaseAccountAPI.swift              # Protected account-deletion Edge Function call.
        APIError.swift                        # Sanitized transport, auth, conflict, and validation errors.
        DTOMapper.swift                       # Boundary-only DTO-to-domain mapping.
      Persistence/
        Models/
          CachedProfile.swift                 # SwiftData profile cache model.
          CachedRoom.swift                    # Room summary and sequence-watermark cache model.
          CachedRoomEvent.swift               # Bounded committed event cache model.
          PendingRoomEvent.swift              # Durable retry identity and unsent payload model.
          BearDraft.swift                     # Offline appearance draft model.
        PersistenceController.swift           # Protected SwiftData container creation and recovery.
        RoomCache.swift                       # Room/event reads, writes, pages, and eviction.
        DraftStore.swift                      # Pending event and appearance draft persistence.
    Services/
      Session/
        SessionController.swift               # Auth state machine and root routing.
        AppleSignInCoordinator.swift           # Nonce-backed native Sign in with Apple flow.
        AccountDeletionCoordinator.swift       # Owned-room resolution and deletion request flow.
      RoomSync/
        RoomSyncCoordinator.swift             # One selected room's cache/catch-up/live lifecycle.
        EventSequenceReducer.swift            # Pure sequence, gap, dedupe, and pending reconciliation rules.
        RoomSubscriptionSet.swift             # Owns room-scoped Realtime subscriptions.
      Presence/
        PresenceCoordinator.swift             # One selected-room lease and active roster.
        PresenceExpiryReducer.swift           # Pure server-time lease filtering and grouping.
      Movement/
        MovementCoordinator.swift             # Immediate local move plus serialized latest-wins RPCs.
        WalkableMap.swift                     # Loads layout polygons, obstacles, and named destinations.
        MovementInterpolator.swift            # Fixed-speed path state independent of rendering.
        DepthProjector.swift                  # Converts normalized vertical position to scale and z-order.
      Playback/
        ActionPlaybackQueue.swift             # Serial live-only action playback and user replay.
        EventDescriptionBuilder.swift         # Plain-language and VoiceOver event descriptions.
      Notifications/
        PushRegistrationCoordinator.swift     # APNs permission, token lifecycle, and preferences.
        NotificationRouter.swift              # Opaque route validation and authenticated room navigation.
      Safety/
        ReportCoordinator.swift               # Disclosure, snapshot confirmation, and report submission.
    Rendering/
      Room/
        RoomScene.swift                       # SpriteKit node ownership and render-loop projection only.
        BearNode.swift                        # Layered avatar, label, speech, and animation node.
        DestinationMarkerNode.swift           # Immediate movement feedback.
        SpeechLayoutEngine.swift              # Bounded label/bubble overlap avoidance.
      Appearance/
        AssetCatalog.swift                    # Loads bundled semantic assets and safe fallbacks.
        AppearanceValidator.swift             # Local compatibility validation for editor feedback.
        BearTextureComposer.swift             # Ordered appearance-layer composition.
      Layout/
        RoomLayoutDocument.swift              # Decoded layout-resource shape.
        RoomLayoutLoader.swift                # Versioned bundled layout loading.
    Features/
      Onboarding/                             # Sign-in and initial profile screens/models.
      RoomList/                               # Cached room list, creation, and invitation entry.
      Room/                                   # Main room shell, chat panel, composer, and room model.
      Activity/                               # Latest-20 activity and replay controls.
      Actions/                                # Emote, group-action, interaction, and target pickers.
      BearEditor/                             # Draft editor, preview, validation, save, and cancel.
      Membership/                             # Members, invite, mute, transfer, remove, leave, and delete.
      Safety/                                 # Block and report views.
      Settings/                               # Notification, sign-out, privacy, and account deletion views.
    Resources/
      Assets.xcassets/                        # App and room artwork.
      RoomLayouts/lodge-v1.json               # Walkable polygon, obstacles, depth, spawn, and named points.
      Catalogs/appearance-v1.json             # Allowed appearance IDs and compatibility rules.
      Catalogs/actions-v1.json                # Action IDs, participants, timing, and descriptions.
      Catalogs/reactions-v1.json              # Reaction IDs and descriptions.
      PrivacyInfo.xcprivacy                    # Required-reason API and collected-data declarations.
      BearChat.entitlements                   # Apple sign-in, push, and associated domains.
  BearChatAppTests/
    Domain/                                   # Reducer, mapper, validator, and state-machine tests.
    Data/                                     # Cache, migration, and API adapter tests.
    Services/                                 # Sync, presence, movement, playback, and deletion tests.
    Rendering/                                # Layout, depth, fallback, and snapshot tests.
    Fixtures/                                 # Typed JSON fixtures with no production content.
  BearChatAppUITests/
    AuthenticationUITests.swift               # Native sign-in handoff and signed-in routing.
    RoomUITests.swift                         # Chat, movement, reconnect, and accessibility flows.
    MembershipUITests.swift                   # Invite and room management flows.
    SafetyUITests.swift                       # Disclosure, block, and report flows.
supabase/
  config.toml                                 # Local Supabase configuration.
  seed.sql                                    # Synthetic local identities and rooms only.
  migrations/
    <timestamp>_extensions_and_enums.sql      # pgcrypto plus constrained enum/domain setup.
    <timestamp>_core_schema.sql               # Tables, foreign keys, checks, and deletion jobs.
    <timestamp>_indexes.sql                   # Sequence, membership, lease, and report indexes.
    <timestamp>_authorization_helpers.sql     # Stable membership and role helper functions.
    <timestamp>_rls.sql                       # Enable/force RLS and define read policies.
    <timestamp>_room_rpcs.sql                 # Room, invitation, membership, and mute functions.
    <timestamp>_event_rpcs.sql                # Event validation, idempotency, and sequencing.
    <timestamp>_presence_rpcs.sql             # Lease, movement, and cleanup functions.
    <timestamp>_profile_safety_rpcs.sql       # Profile revision, block, report, and device functions.
    <timestamp>_realtime_webhooks_cron.sql    # Publications, notification webhook, and cleanup jobs.
  functions/
    _shared/
      auth.ts                                 # JWT verification and caller identity extraction.
      database.ts                             # Service-role client construction.
      errors.ts                               # Content-free response and log errors.
      apns.ts                                 # APNs JWT and request adapter.
    send-notification/index.ts                # Internal event webhook to filtered APNs sends.
    delete-account/index.ts                   # Idempotent app-data and auth-identity deletion.
  tests/
    database/                                 # pgTAP schema, RLS, RPC, race, and invariant tests.
    functions/                                # Deno tests for notification and deletion functions.
invite-site/
  join/index.html                             # Content-free open/install invitation page.
  apple-app-site-association                  # Universal Link association.
operations/
  runbooks/                                   # Deploy, restore, rotate, outage, moderation, and deletion steps.
  checks/                                     # Content-free release and production verification scripts.
docs/
  verification/requirements-traceability.md   # FR/NFR to automated, measured, policy, or manual checks.
```

`RoomSyncCoordinator.swift`, `RoomScene.swift`, and `SupabaseRoomAPI.swift` are the most likely files to grow into god files. They remain coordinators only: sequence rules live in reducers, rendering calculations live outside the scene, and unrelated RPC groups stay in separate API adapters. Split a coordinator by lifecycle responsibility if it begins validating payloads, formatting UI, or owning multiple independent state machines.

## Data model

### Client domain shapes

These sketches show fields, not implementation methods.

```text
Profile
  id: UUID
  displayName: String
  appearance: Appearance
  revision: Int64
  updatedAt: Date

Appearance
  schemaVersion: Int
  bodyID: String
  faceID: String
  furColorID: String
  accentColorID: String
  clothingIDs: [String]
  accessoryIDs: [String]

RoomSummary
  id: UUID
  name: String
  ownerID: UUID
  membershipRole: owner | member
  isMuted: Bool
  newestSequence: Int64
  updatedAt: Date

RoomMember
  roomID: UUID
  userID: UUID
  role: owner | member
  joinedAt: Date
  profile: Profile

RoomEvent
  id: UUID
  roomID: UUID
  sequence: Int64
  senderID: UUID?                 # nil renders as "Deleted Bear"
  clientEventID: UUID
  kind: text | emote | groupAction | interaction | reaction
  payload: RoomEventPayload
  targetUserID: UUID?
  referencedEventID: UUID?
  createdAt: Date

RoomEventPayload
  text: schemaVersion + text
  emote: schemaVersion + emoteID
  groupAction: schemaVersion + actionID
  interaction: schemaVersion + actionID
  reaction: schemaVersion + reactionID

PendingRoomEvent
  clientEventID: UUID
  roomID: UUID
  kind/payload/target/reference: same request values used on every retry
  state: draft | sending | awaitingReconciliation | failed
  lastError: retryable | targetUnavailable | accessRevoked | invalid
  createdAt: Date

PresenceSession
  roomID: UUID
  userID: UUID
  installationID: UUID
  connectionID: UUID
  leaseExpiresAt: Date
  serverObservedAt: Date

ActiveBear
  userID: UUID
  profile: Profile
  leaseExpiresAt: Date            # maximum valid lease for this user
  destination: NormalizedPosition
  movementRevision: Int64

NormalizedPosition
  x: Double                      # inclusive 0...1
  y: Double                      # inclusive 0...1

MovementState
  confirmedDestination: NormalizedPosition
  displayedPosition: NormalizedPosition
  optimisticDestination: NormalizedPosition?
  latestRevision: Int64
  requestState: idle | inFlight | pendingLatest | rejected

RoomConnectionState
  cached | catchingUp | subscribing | live | reconnecting | accessRevoked | unavailable
```

DTOs mirror database names and nullable fields exactly. Feature code receives domain values only after `DTOMapper` checks identifiers, bounds, event discriminators, timestamps, and known schema versions. Unknown valid event versions become an unsupported-event domain case; malformed DTOs never enter feature state.

### PostgreSQL records

Every table carries `created_at` and/or `updated_at` server timestamps where useful. UUIDs are generated by PostgreSQL except client event IDs, connection IDs, installation IDs, and invite secrets, which originate on the device.

| Record | Required fields and constraints |
|---|---|
| `profiles` | `user_id` PK/FK to `auth.users`, bounded `display_name`, validated `appearance jsonb`, `revision bigint >= 1`, `deleted_at`. |
| `rooms` | `id` PK, bounded `name`, `owner_id` FK to `profiles`, `layout_id = 'lodge-v1'`, `next_event_sequence bigint >= 1`, `deleted_at`, `purge_after`. |
| `room_members` | Composite PK `(room_id, user_id)`, `role`, `joined_at`, `is_muted`, `last_acknowledged_sequence`; unique partial index permits exactly one owner row per live room. |
| `room_invites` | `id`, `room_id`, `creator_id`, `token_digest bytea`, `expires_at`, nullable positive `max_uses`, `use_count >= 0`, `revoked_at`; digest is never selected by clients. |
| `room_events` | `id`, `room_id`, positive `sequence`, nullable `sender_id`, `client_event_id`, `kind`, validated `payload jsonb`, nullable `target_user_id`, nullable `referenced_event_id`, `created_at`; unique `(room_id, sequence)` and `(room_id, sender_id, client_event_id)` while sender exists. |
| `presence_sessions` | Composite PK `(room_id, user_id, connection_id)`, `installation_id`, `lease_expires_at`, `updated_at`; opening a new room removes other leases for the same user and installation. |
| `room_presence_state` | PK `(room_id, user_id)`, `destination_x/y` each in `0...1`, positive `movement_revision`, `updated_at`; rows are visible only while an unexpired lease exists. |
| `push_devices` | Unique `(user_id, installation_id, environment)`, encrypted-at-rest APNs `token`, preview mode, `last_seen_at`; tokens are never client-readable. |
| `user_blocks` | PK `(blocker_id, blocked_id)`, check identities differ, `created_at`. |
| `reports` | `id`, reporter/room, nullable reported user/event, bounded disclosed snapshot, category, status, reviewer metadata, `retention_deadline`; direct client reads expose status but not reviewer metadata. |
| `asset_catalog_entries` | Composite key `(catalog_version, kind, semantic_id)`, bounded compatibility metadata, active flag; migration-seeded and never client-writable. |
| `rate_limit_counters` | Composite key for subject, operation, and fixed window; count updated only inside protected functions. |
| `account_deletion_jobs` | `user_id`, state, requested/attempted/completed timestamps, content-free error code; supports retry across database and Auth boundaries. |
| `audit_log` | Actor, operation, resource type/ID, reason code, timestamp, content-free metadata; append-only and unavailable to app clients. |

Database enums are used only for stable closed states such as member role, event kind, report status, and deletion-job status. User-facing asset IDs stay constrained text validated against versioned allowlists, avoiding a schema migration for each bundled asset.

### Named invariants

- **INV-1 Current membership:** A caller may read room data or invoke a room mutation only while one non-deleted `room_members` row exists for that caller and room.
- **INV-2 Room capacity:** A join transaction locks the room and relevant invite before counting memberships; a committed room has at most eight members.
- **INV-3 Room owner:** Every non-deleted room has exactly one owner, and `rooms.owner_id` matches the owner membership row. A partial unique index prevents multiple owner rows; protected transactions prevent zero.
- **INV-4 Event order:** Only `send_room_event` increments `rooms.next_event_sequence`; committed room sequences are unique and contiguous.
- **INV-5 Event idempotency:** Reusing `(room, sender, client_event_id)` with identical input returns the existing event; reusing it with different input is rejected.
- **INV-6 Event references:** Targets and referenced events belong to the same room, and the referenced event predates the new event.
- **INV-7 Target presence:** An interaction target is a current member with an unexpired room lease at transaction commit, and no block exists in either direction between actor and target.
- **INV-8 Presence scope:** One installation exposes presence in at most one room per user; multiple installations group into one active bear.
- **INV-9 Movement freshness:** Movement revisions increase per room/user, and clients apply only a revision greater than the last applied revision.
- **INV-10 Ephemeral movement:** Presence and movement never enter `room_events`, cache history, reports, notification payloads, or general logs.
- **INV-11 Bundled rendering:** Appearance and event payloads contain semantic IDs only; no accepted payload can name a remote asset or executable instruction.
- **INV-12 Deleted access:** A deleted room or removed membership is rejected by RLS and functions immediately even if physical purge runs later.
- **INV-13 Cache isolation:** Every SwiftData cache record is scoped to the authenticated account ID, and sign-out destroys that account's store before another account can open it.

## Interfaces / API surface

### Client module boundaries

| Boundary | Inputs | Outputs | Ownership rule |
|---|---|---|---|
| `SessionController` | Apple authorization result, stored Supabase session, lifecycle events | Signed-out/onboarding/signed-in/deleting state | Only owner of global authentication state. |
| `RoomSyncCoordinator` | Room ID, cache, event API, Realtime notifications | Ordered committed events, pending projections, connection state | One instance for the selected room; no rendering logic. |
| `PresenceCoordinator` | Selected room, installation/connection IDs, app activity | Active roster and lease health | Opens only after event catch-up; closes before room switch. |
| `MovementCoordinator` | Valid floor taps, accepted state rows, movement errors | Per-bear movement states | Serializes local requests and retains only the latest unsent destination. |
| `ActionPlaybackQueue` | Live committed events, explicit replay requests | One playback instruction at a time | Catch-up never enqueues autoplay. |
| `RoomCache` | Domain records and page cursors | Protected cached projections | Never authorizes an operation or invents a server sequence. |
| `RoomScene` | Render projection and user hit tests | Floor taps and bear selections | Does not call APIs or mutate domain state. |

Feature models run on `MainActor` and expose explicit domain states to SwiftUI. API, database, decoding, and geometry work run in child tasks or actors. `AppEnvironment` performs direct constructor injection; no service locator or third-party dependency-injection framework is introduced.

### Auth and query surface

| Operation | Mechanism | Result |
|---|---|---|
| Sign in | Native Apple authorization with SHA-256 nonce, then Supabase ID-token exchange with the raw nonce | Supabase session; no Apple token persisted. |
| Restore session | Supabase SDK session from Keychain-backed storage | Authenticated user ID or signed-out state. |
| List rooms | RLS-protected view/query by current user membership | Room summaries and newest sequence. |
| Load room snapshot | RLS-protected room/member/profile queries | Room detail, members, and current profiles. |
| Load newest events | Query by room ordered sequence descending, bounded page | Newest page returned to client in ascending display order. |
| Catch up events | Query `sequence > after`, ascending, bounded page | Canonical gap-recovery pages. |
| Load older events | Query `sequence < before`, descending, bounded page | Older history page. |
| Reconcile pending event | Query by current sender and client event ID | Existing committed event or not found. |
| Load active presence | RLS-protected view joining unexpired sessions, profiles, and valid state | One grouped active bear per user. |

### PostgreSQL function surface

All client-callable functions use `auth.uid()`, fixed `search_path`, explicit input bounds, and least-privilege grants. Authorization-sensitive tables reject direct client writes. `security definer` is used only where RLS cannot express the transaction, with ownership and grants asserted in migration tests.

| Function | Inputs | Atomic behavior and result |
|---|---|---|
| `create_room` | Name, initial invite options, raw high-entropy invite secret | Validates name, hashes secret, creates room/owner membership/invite; returns room and invite metadata. |
| `create_room_invite` | Room, options, raw secret | Owner check, revokes replaced invite when requested, stores digest; returns metadata without digest. |
| `revoke_room_invite` | Room, invite ID | Owner check and idempotent revoke. |
| `join_room` | Raw invite secret | Hashes and locks invite/room, verifies validity/capacity, inserts membership, increments use count; returns room ID or a non-revealing reason. |
| `set_room_muted` | Room, Boolean | Current-member update of only the caller's row. |
| `leave_room` | Room | Removes caller, presence, and state; rejects owner departure while other members remain. |
| `transfer_room_ownership` | Room, target member | Locks room/members and swaps both role rows plus `owner_id`. |
| `remove_room_member` | Room, target member | Owner-only removal, disallow self/owner target, removes target leases/state. |
| `mark_room_deleted` | Room | Owner-only immediate access denial, invite revoke, lease deletion, and purge scheduling. |
| `update_profile` | Display name, appearance, expected revision | Validates allowlists and compatibility, compare-and-swaps revision, returns current profile or conflict. |
| `send_room_event` | Room, client event ID, kind, payload, target, reference | Enforces INV-1 and INV-4 through INV-7, rate limit, idempotency, and payload schema; returns committed event. |
| `open_room_presence` | Room, installation ID, connection ID | Removes this installation's other room leases, resets stale position when no prior lease exists, creates 30-second lease, returns server time and own state. |
| `heartbeat_room_presence` | Room, connection ID | Extends only the caller's matching lease and returns server time/new expiry. |
| `close_room_presence` | Room, connection ID | Deletes only the caller's matching lease and removes state if no unexpired lease remains. |
| `move_room_bear` | Room, connection ID, normalized destination | Checks current lease, bounds, and rate; increments revision and returns accepted state. |
| `upsert_push_device` | Installation, environment, APNs token, preview mode | Writes only the caller's device row; returns no token. |
| `remove_push_device` | Installation, environment | Deletes only the caller's matching row. |
| `set_user_block` | Other user, blocked Boolean | Requires a shared current room for creation; prevents self-block; returns current state. |
| `create_report` | Room, category, reported user/event, confirmed disclosure version | Verifies visible context and stores the disclosed bounded snapshot; returns report ID/status. |
| `begin_account_deletion` | None | Verifies no unresolved owned rooms, marks access deletion-pending, removes leases/devices, and creates/reuses a deletion job. |

Stable error codes map to typed client cases: `not_authenticated`, `not_member`, `not_owner`, `room_full`, `invite_invalid`, `invite_expired`, `invite_used`, `target_unavailable`, `blocked`, `revision_conflict`, `rate_limited`, `invalid_payload`, `owned_rooms_require_resolution`, and `service_unavailable`. User-visible text is local to the app and never trusted from a database error string.

### Realtime channels

Each selected room owns one `RoomSubscriptionSet` with filtered subscriptions for:

- `room_events` inserts for that room. The notification is a cue; event queries remain canonical.
- `room_members` changes for that room. Any change triggers a fresh member snapshot.
- `presence_sessions` and `room_presence_state` changes for that room. The client refreshes or applies typed rows, then locally filters expired leases.
- `profiles` changes for currently known member IDs. Unknown profile changes are ignored until membership refresh.

The app does not rely on receiving delete events after its own membership is removed. The next query, send, heartbeat, or subscription error produces `accessRevoked`, closes all room channels, removes protected cache for that room after presenting the removal state, and routes to the room list.

### Edge Function and external surfaces

| Surface | Caller | Contract |
|---|---|---|
| `send-notification` | Signed Supabase database webhook containing event ID, room ID, and sequence only | Re-queries canonical data with service credentials, filters current recipient state, sends APNs, and logs content-free outcomes. |
| `delete-account` | Authenticated app | Calls/reuses `begin_account_deletion`, performs admin Auth deletion, finalizes app-data cleanup, and leaves an idempotent retry job on partial failure. |
| APNs | Notification function | Opaque room/event route by default; bounded sender/text only for explicit detailed preview. |
| `https://invite.bearchat.app/join#<secret>` | Browser or Universal Link | Keeps the secret out of HTTP requests/access logs, never renders room metadata, and opens the installed app or shows App Store and reopen instructions. |

No service-role key, Apple private key, APNs key, invite secret, or raw push token appears in committed configuration, client logs, analytics, or general backend logs.

## Flow sequences

### 1. First sign-in and profile creation

1. `RootView` asks `SessionController` to begin sign-in.
2. `AppleSignInCoordinator` creates a cryptographic nonce, sends its hash in the native Apple request, and returns the credential plus raw nonce.
3. `SupabaseAuthAPI` exchanges the identity token and nonce; the token is released after exchange.
4. `SessionController` fetches `profiles` through `SupabaseProfileAPI`.
5. If absent, onboarding collects a display name and default appearance, then `update_profile` creates revision 1. If present, the app routes to `RoomList`.
6. `PushRegistrationCoordinator` asks notification permission only at the product-defined prompt point, then registers any APNs token with a stable Keychain installation ID.

### 2. Create, share, and join a room

1. The owner enters a room name and invitation options in `RoomList`.
2. `SupabaseRoomAPI` creates a 32-byte random invite secret and sends it once to `create_room`; only its SHA-256 digest is stored.
3. The app builds `https://invite.bearchat.app/join#<secret>` locally and opens the iOS share sheet. The fragment is available to the app/browser but is not sent to the web host. The app does not persist the raw secret beyond the share/recovery state.
4. A recipient opens the Universal Link. If installed, `NotificationRouter` stores the raw link in memory until authentication completes.
5. After sign-in, `join_room` locks the invite and room, checks validity and the eight-member cap, then inserts the membership.
6. On success, the app discards the secret, refreshes room summaries, and opens the room. On failure, it maps the stable reason without revealing room metadata.

### 3. Open a room and become live

1. `RoomSyncCoordinator` reads `CachedRoom` and the newest cached event page so `Room` can render within the cached-room target.
2. It fetches current room/member/profile data. `not_member` transitions directly to `accessRevoked`.
3. It reconciles every `PendingRoomEvent` by client event ID without resending it.
4. It fetches canonical events after the cached newest sequence. With no cache, it fetches the newest page and records its lower and upper bounds without pretending earlier history is loaded.
5. `RoomSubscriptionSet` subscribes. After the SDK reports subscribed, `RoomSyncCoordinator` performs a second catch-up from the newest confirmed sequence to close the query/subscribe race.
6. Buffered notifications are reduced by `EventSequenceReducer`; gaps trigger another canonical catch-up before autoplay continues.
7. `PresenceCoordinator` creates a new connection ID and calls `open_room_presence` only after event state is current.
8. It loads active presence, groups sessions by user, and publishes `ActiveBear` values. `RoomScene` receives a render projection, never database rows.
9. The connection state becomes `live`. Presence heartbeats start only while the scene is foreground-active.

### 4. Send a message, action, interaction, or reaction

1. The feature validates obvious local requirements and constructs one immutable event request with a new client event ID.
2. `DraftStore` persists `PendingRoomEvent` before network send; the UI projects it as `sending` without a server sequence.
3. `SupabaseEventAPI` calls `send_room_event` with the same full request on every retry.
4. The function validates membership, payload, references, rate, and active target when applicable; it returns an existing identical retry or commits the next room sequence.
5. `EventSequenceReducer` replaces the pending projection by client event ID, saves the committed event, advances the watermark, and removes the pending row.
6. A failed transport moves the item to `awaitingReconciliation`; reconnect first queries by client event ID. If absent, the UI marks it `failed` and waits for explicit retry.
7. A target-presence rejection removes target confirmation and returns the user to target selection; it never retries automatically.

### 5. Receive events and recover a gap

1. A Realtime insert arrives at `SupabaseRealtimeAPI` and is decoded at the boundary.
2. If its sequence is at or below the current watermark, the reducer deduplicates by event ID and client event ID.
3. If it is exactly the next sequence, the reducer persists and publishes it.
4. If it is ahead, `RoomSyncCoordinator` buffers it, marks `reconnecting`, pauses action autoplay, and queries all events after the watermark in ascending pages.
5. Canonical pages and buffered events are merged by ID and sequence. Only a contiguous run advances the watermark.
6. Once caught up, only events known to have arrived live after subscription are eligible for serial autoplay; historical catch-up remains readable and replayable where allowed.

### 6. Move a bear

1. `RoomScene` hit-tests bears before floor geometry. A bear hit selects a target; an unoccupied walkable floor hit emits a normalized destination.
2. `WalkableMap` clamps the point to the bundled walkable polygon, excluding obstacle masks, and `DestinationMarkerNode` responds within 0.2 seconds.
3. `MovementCoordinator` immediately sets the local optimistic destination and retargets `MovementInterpolator`.
4. One movement RPC may be in flight. During it, repeated taps replace one pending-latest destination after a 150-millisecond trailing debounce; intermediate destinations are not sent.
5. `move_room_bear` checks the matching lease and rate limit, then increments and returns the room/user revision.
6. The accepted destination becomes confirmed. A newer pending destination is sent next; a stale response never replaces a newer displayed intent.
7. Remote clients apply only higher revisions and animate from their current displayed point at the fixed layout speed. `DepthProjector` updates scale and z-order from vertical position each frame.
8. On rejection or disconnect, unsent movement is discarded and the local bear stops or returns to its last confirmed destination. Movement is never replayed after reconnect.

### 7. Presence exit, interruption, and multiple devices

1. While the room is foreground-active, `PresenceCoordinator` calls `heartbeat_room_presence` every 10 seconds and recalibrates lease expiry from returned server time.
2. Opening another room on the same installation closes the current coordinator first; the server also removes stale same-installation leases defensively.
3. Clean exit calls `close_room_presence` best effort, cancels timers, and closes room channels.
4. Network loss leaves the lease to expire no later than its 30-second server timestamp. Every client locally hides expired sessions without waiting for cleanup.
5. Multiple installations for one identity remain valid but group into one bear. The newest accepted movement revision from either device wins.
6. App backgrounding best-effort closes the lease and cancels its timer. Foreground return reruns event catch-up and the subscription handshake before opening a new connection ID and publishing presence.
7. When the last valid lease ends, movement state is ignored immediately and removed by close or scheduled cleanup. A future entry starts at the deterministic `lodge-v1` spawn slot.

### 8. Notification delivery and open

1. A committed event causes a signed, content-minimized webhook after transaction commit.
2. `send-notification` fetches the event, current members, mute settings, blocks, active-room leases, profiles, and registered devices using service credentials.
3. It excludes the sender, removed members, muted rooms, users currently active in the room, and a recipient when a block exists in either direction between recipient and sender.
4. Generic mode sends only an opaque room/event route. Detailed mode may add a bounded display name and text according to the unresolved preview policy.
5. Invalid APNs tokens are removed; other failures record only provider status class and content-free error code.
6. On tap, `NotificationRouter` authenticates, verifies current membership, opens the room, and catches up from PostgreSQL rather than trusting payload content.

### 9. Edit and synchronize a bear

1. `BearEditor` copies the current appearance into `BearDraft` and previews only bundled IDs.
2. `AppearanceValidator` gives immediate compatibility feedback; cancel deletes the draft without changing the profile.
3. Save calls `update_profile` with the current profile revision.
4. Success replaces the local profile/cache and emits a profile database change. Active clients refetch and recompose the affected bear.
5. A revision conflict returns the newest server profile; the editor asks the user to reload rather than overwriting another device silently.

### 10. Block and report

1. Blocking calls `set_user_block`; target pickers immediately remove that user for directed interactions while shared room history remains unchanged.
2. Reporting begins in the relevant room context. `ReportCoordinator` presents the exact disclosure version and bounded content that will be copied.
3. On confirmation, `create_report` rechecks that the caller can see the referenced room/event/user and stores the disclosed snapshot with a retention deadline.
4. Safety reviewers access only report records through the separate least-privilege process and every status change appends an audit record.

### 11. Membership and room deletion

1. Transfer, leave, remove, and delete actions call their dedicated transaction after an explicit confirmation screen.
2. Ownership transfer locks the room and both membership rows so no observer sees an ownerless live room.
3. Member removal immediately deletes that member's leases/state. RLS denies all subsequent content access even if the removed app has cached data.
4. The removed app transitions on its next backend signal, closes channels, tells the user access ended, and deletes that room's protected cache.
5. Room deletion sets `deleted_at` and `purge_after`, revokes invites, closes leases, and immediately hides the room through RLS. A scheduled server job permanently deletes content after the policy window.

### 12. Account deletion

1. `AccountDeletionCoordinator` loads owned rooms. The user must transfer each live room with other members or choose room deletion before continuing.
2. `delete-account` authenticates the current JWT and calls idempotent `begin_account_deletion`.
3. The transaction denies further app access, removes push devices/presence/invites/memberships, nulls event attribution to render `Deleted Bear`, and preserves only disclosed report evidence until its deadline.
4. The function deletes the Supabase Auth identity with admin credentials and marks the deletion job complete.
5. If Auth deletion fails after database cleanup, the job remains retryable and sign-in stays blocked by deletion-pending state. Scheduled operations retry without restoring profile access.
6. The app clears Keychain session material, protected caches, drafts, and notification state whether the final response succeeds or reports already completed.

## Mechanisms

- **Project and dependencies:** Commit the Xcode project and pin Supabase Swift through Swift Package Manager. Do not introduce a workspace generator, local package split, or dependency-injection library until the project demonstrates that need.
- **UI state:** Use Swift Observation with small `@MainActor` feature models. It integrates directly with iOS 17 SwiftUI and avoids a second reactive framework.
- **Concurrency:** Give session, room sync, presence, movement, and playback one owner each; use structured tasks canceled by room/app lifecycle. This prevents detached work from surviving sign-out or room changes.
- **Boundary mapping:** Decode Supabase DTOs separately and map them into domain enums and structs. External nulls, unknown discriminators, and bounds are validated once rather than leaking dictionaries into features.
- **Authentication storage:** Configure Supabase Auth with `AuthLocalStorage`, backed by Keychain, and persist only the stable installation ID in a separate Keychain item. Apple identity tokens, nonces, email, and name are not retained after exchange.
- **Authorization:** Use RLS for every read plus narrow PostgreSQL functions for writes. Functions re-check `auth.uid()` inside their transaction because hiding a UI control is never authorization.
- **Transactional serialization:** Lock the room row for joins, ownership changes, deletion, and event sequence assignment. With a maximum of eight senders, one lock is simpler and safer than distributed sequence allocation.
- **Event payload validation:** Validate each kind with a dedicated SQL validation function and mirror the schema in Swift DTO decoding. The database rejects unknown keys, remote URLs, oversized nesting, and inconsistent target/reference columns.
- **Backend asset allowlist:** Seed `asset_catalog_entries` from the same reviewed catalog release bundled in the app. Profile and event functions accept only active IDs from an accepted version, so a modified client cannot invent render instructions.
- **Realtime contract:** Treat database changes as invalidations. The query-subscribe-query handshake closes startup races, and sequence catch-up closes drops, duplicates, and reordering.
- **Local cache:** Create a separate account-scoped SwiftData store and store at most 200 committed events per recently opened room for up to 20 rooms initially; preserve pending events and appearance drafts outside eviction. These constants are starting budgets and must be replaced by measured limits before beta.
- **File protection:** Create the SwiftData store under an application-support directory marked `NSFileProtectionComplete`, exclude it from backup where policy requires, and handle unavailable protected data as a locked-state load failure rather than recreating it.
- **Pending sends:** Persist before send, reconcile before retry, and require explicit retry when no commit exists. This avoids both lost intent and accidental offline sends.
- **Sign-out:** Stop room work first, reconcile pending sends, and ask the user to retry or discard any unresolved writes before destroying that account's cache and session. Another account never reuses the same store.
- **Presence time:** Server timestamps are authoritative. The client estimates server-now from each response and monotonic elapsed time so a manually changed device clock cannot keep a bear visible.
- **Presence lifecycle:** A 10-second heartbeat renews a 30-second lease; local expiry determines visibility, while cleanup only reclaims rows. One installation is constrained to one selected room.
- **Movement transport:** Start locally, then serialize destination-only RPCs with one in-flight request and one replaceable pending destination. This bounds traffic and makes last-intent-wins behavior deterministic.
- **Movement geometry:** `lodge-v1.json` contains normalized polygons and depth parameters. Both local and remote positions are clamped through the same `WalkableMap`; the server checks numeric bounds because movement is visual, not an authorization input.
- **Depth and overlap:** Linearly interpolate scale between layout-defined back/front values and derive z-order from normalized vertical position plus stable user-ID tie-breaking. Bears do not collide or block paths.
- **Action playback:** Keep a single serial queue of live committed action/reaction events. Movement pauses only for nodes involved in the action and resumes toward each latest destination; catch-up never autoplays.
- **Accessibility movement:** Expose layout-defined named destinations as actions on the room accessibility element and announce nearby bears in relative named regions. Reduce Motion snaps or crossfades to the same accepted destination.
- **Asset safety:** Bundle every image, sound, catalog, and layout. Unknown semantic IDs produce a default bear or plain-language unsupported event and never trigger network asset loading.
- **Text rendering:** Decode bounded Unicode as plain text and disable rich-link interpretation in MVP. Display names and messages never enter HTML, attributed-markup, file-path, or asset-name APIs.
- **Invite secret handling:** Generate 256 random bits on device, place the base64url secret in the Universal Link fragment so the web host never receives it, pass it only in the join RPC body over TLS, and store SHA-256 only. Disable request-body logging for invitation functions.
- **Deferred invitation limitation:** Universal Links plus an App Store fallback cannot reliably carry a secret through a fresh App Store install. The MVP page retains no private metadata and asks the recipient to reopen the original link after installation; automatic post-install continuation remains an explicit open question and accepted weakening of FR-8.3.
- **Push delivery:** Trigger after commit with identifiers only, then re-query authorization and preferences in the function. APNs is a hint; room catch-up is always authoritative.
- **Operational logging:** Emit operation, request correlation ID, environment, duration, stable error code, and coarse counts only. Never emit message/payload text, appearance documents, invite secrets, Apple tokens, APNs payloads/tokens, or movement coordinates.
- **Account deletion:** Use an idempotent deletion job because PostgreSQL and Supabase Auth cannot commit atomically. Deletion-pending denies normal access and retries forward; it never reconstructs deleted content.
- **Schema delivery:** Use immutable Supabase CLI migrations promoted development to staging to production. Every function grant, RLS policy, publication, webhook, and scheduled cleanup is represented and tested in migrations.

## Failure/degradation paths

| Failure | Required behavior |
|---|---|
| Apple sign-in unavailable, canceled, or invalid | Remain signed out, retain only non-sensitive onboarding input, and allow retry; never create a local shadow identity. |
| Supabase session revoked or refresh fails | Cancel authenticated tasks, close room presence/channels, clear session material, and return to sign-in without deleting server data. |
| Profile revision conflict | Return the current profile, keep the local draft, and ask the user to reload before another save. |
| Invitation invalid, expired, revoked, used, or full | Show the stable reason without room name, members, or history; discard the raw secret after the result. |
| Post-install invite cannot resume | Show instructions to reopen the original private link; do not place the secret in pasteboard, analytics, or public page metadata. |
| Membership removed or room deleted | RLS blocks access immediately; close room work, show access-ended state, delete that room cache, and return to room list. |
| Realtime disconnect | Mark reconnecting, keep cached chat readable, pause autoplay, resubscribe, and run canonical catch-up before live state. |
| Event sequence gap | Buffer later notifications, fetch after the watermark until contiguous, and never fabricate or skip a sequence. |
| Event transport outcome unknown | Query by client event ID first; commit the projection if found, otherwise show failed and wait for explicit retry. |
| Target expires before commit | Reject with `target_unavailable`, clear target confirmation, and preserve the draft for a new target if applicable. |
| Presence open or heartbeat fails | Show only the local bear, disable targeted interactions, keep chat/non-targeted actions usable, and retry while the room remains foreground-active. |
| Movement RPC fails or rate limits | Remove destination feedback, discard unsent moves, and settle at the last confirmed destination; never queue movement offline. |
| Stale/duplicate movement revision | Ignore it without changing the path. A malformed in-bounds point is clamped locally; non-finite or out-of-bounds data is rejected at decoding. |
| Action or room animation fails | Move involved bears to the defined final state, show the plain-language entry, and announce the same outcome with VoiceOver. |
| Unknown appearance/event asset | Render the default bear or unsupported-event description; never fetch a remote fallback. |
| SwiftData unavailable while device data is protected | Show a locked-data state and retry after unlock; do not replace the store. |
| SwiftData corruption | Preserve separately stored pending drafts where readable, quarantine and recreate the cache, then restore canonical server data. |
| Backend unavailable | Keep protected cached chat and appearance editing available, show unavailable state, and prevent false sent/presence claims. |
| APNs send fails | Record content-free status, remove invalid tokens, and rely on database catch-up when the app opens. |
| Notification references inaccessible room | Discard the route after authentication and show the room list; never reveal stale payload details. |
| Report submission fails | Keep the user's disclosure confirmation in memory for retry during the current session; do not create an untracked local report claim. |
| Account deletion partially fails | Keep deletion-pending access blocked, preserve the idempotent job, retry forward, and return only a content-free status. |
| Room purge or presence cleanup job is delayed | RLS and expiry timestamps continue to hide data immediately; cleanup delay changes storage use, not user-visible authorization. |

## Test mapping

`docs/verification/requirements-traceability.md` will list every FR and NFR with at least one test or named review below. No requirement is considered covered by a generic test-suite label.

| HLD verification area | Concrete test ownership and scenarios |
|---|---|
| Requirements traceability | `docs/verification/requirements-traceability.md`; CI check rejects missing FR/NFR IDs and unresolved release-gate rows. |
| Authentication | `AuthenticationUITests`, `SessionControllerTests`, and staging device tests for first/returning/second-device sign-in, nonce, cancellation, revoke, refresh, sign-out, deletion, and environment isolation. |
| Authorization | `supabase/tests/database/rls_*.sql`; three identities exercise every table/query/RPC as owner, member, removed member, nonmember, blocked user, safety reviewer, and anonymous caller. |
| Room invariants | `room_rpc_test.sql` and concurrency scripts race ninth joins, ownership transfer/leave, revoke/use limits, removal, and deletion while asserting INV-2/INV-3/INV-12. |
| Event correctness | `event_rpc_test.sql`, `EventSequenceReducerTests`, and an eight-client staging load test cover sequence uniqueness, idempotent equal retry, mismatched retry rejection, same-room references, target lease checks, and latest 20. |
| Realtime recovery | `RoomSyncCoordinatorTests` with a controllable API/channel fake drops, duplicates, delays, and reorders events around the query-subscribe-query handshake; UI tests background, terminate, and reopen without old autoplay. |
| Presence | `presence_rpc_test.sql`, `PresenceExpiryReducerTests`, and physical-device tests cover clean exit, force-quit, network loss, room switch, two devices, server-time skew, block/target changes, and 2/5/30-second thresholds. |
| Movement | `movement_rpc_test.sql`, `MovementCoordinatorTests`, `WalkableMapTests`, `DepthProjectorTests`, and eight-device profiling cover hit priority, rapid retarget, stale revisions, two-device control, spawn reset, clamping, z-order, action interruption, rate limits, and 0.2/1-second thresholds. |
| Offline/cache | `RoomCacheTests`, `PersistenceControllerTests`, and device tests cover newest-first load, page cursors, eviction, protected files, pending reconciliation, explicit retry, sign-out/removal cleanup, corruption, reinstall, and restore. |
| Notifications | `supabase/tests/functions/send-notification.test.ts` plus staging APNs tests cover generic/detailed payloads, mute, block, active-room suppression, removed members, invalid tokens, delayed/absent delivery, invite routes, and App Store fallback. |
| Safety and deletion | `safety_rpc_test.sql`, `delete-account.test.ts`, `SafetyUITests`, and runbook drills cover exact disclosure, least-privilege report access, audit rows, owner resolution, anonymization, report exception, room purge, device/presence cleanup, retry, and final Auth deletion. |
| Payload security | Property/fuzz tests for Swift DTO mapping and `event_payload_validation_test.sql` submit oversized/deep JSON, invalid Unicode, unknown versions/kinds, remote URLs, cross-room IDs, unknown assets, duplicate IDs, and inconsistent columns. |
| Privacy | Release checklist inspects TLS, provider/backups encryption, RLS/grants, environment secrets, binaries, logs, notification payloads, privacy manifest, absence of ad/address-book SDKs, movement-coordinate exclusion, and non-E2EE copy. |
| Performance | XCTest metrics, Instruments, and staging load scripts measure 2-second cached usability, 0.2-second feedback/local movement, 1-second remote movement, newest page latency, eight moving layered bears, event commit/propagation, cache size, and heartbeat/movement writes on the oldest supported iPhone. |
| Accessibility | `RoomUITests` accessibility assertions plus manual VoiceOver, Dynamic Type, contrast, Reduce Motion, keyboard, and non-color checks cover named movement destinations, nearby-bear announcements, chat, action outcomes, membership, reports, and editor. |
| Operations | `operations/runbooks` drills restore staging backup, forward/back migrations, secret rotation, Supabase/APNs outage, deletion-job retry, cleanup delay, budget/rate alerts, and rollback while cached chat remains readable. |
| Visual acceptance | Snapshot matrix and physical-device review compare compact/expanded chat, one/eight moving bears, speech/name attachment, depth, safe areas, Dynamic Type, and orientation policy against `bear-chat-room-mock-v2.png`. |

## Open questions

1. **Approval gate:** The source product spec, visual mock, and HLD are still pending `T1` through `T3`, and the HLD's independent review did not complete. Accepted for now: keep this LLD in draft and do not treat its stack or mechanisms as an approved implementation baseline.
2. **Minimum OS:** The design uses iOS 17, SwiftData, and Swift Observation, but product approval has not confirmed the support boundary. Accepted for now: target iOS 17 and revisit before creating the Xcode project.
3. **One-member room transition:** The spec defines rooms as having two to eight members, while room creation necessarily has only the owner until someone joins and a room can later lose all other members. Accepted for now: permit an owner-only private room as a forming/remaining state while enforcing the maximum of eight; confirm product language before schema approval.
4. **Owned rooms during account deletion:** Automatic transfer would silently choose a new owner, while unconditional room deletion would remove other members' history. Accepted for now: require the user to transfer or explicitly delete every owned room before final account deletion and return `owned_rooms_require_resolution` otherwise.
5. **Deletion and report retention:** The HLD requires a room purge window and report-retention exception but gives no durations or exact report context. Accepted for now: make both server-controlled policy constants and block production launch until legal/safety owners approve the durations, disclosure text, and captured fields.
6. **Fresh-install invitation recovery:** Universal Links cannot by themselves preserve a bearer secret through App Store installation. Accepted for now: verify on the minimum iOS version that the installed-app handoff preserves the fragment, require reopening the original link after a fresh install, and choose a privacy-safe deferred-link provider or revise FR-8.3 if automatic continuation is mandatory.
7. **Rate-limit values:** Event, movement, heartbeat, invite, join, report, and device-registration thresholds are not product decisions yet. Accepted for now: implement operation-specific server constants and test enforcement, but choose production values from architecture-spike/load data before beta.
8. **Detailed notification content:** The exact event kinds and text length allowed in opt-in detailed previews are unspecified. Accepted for now: support generic notifications first; enable detailed previews only after privacy copy and payload limits are approved.
9. **Block notification semantics:** The spec describes inbound blocking while the HLD says directed interactions and notifications are prevented between the pair. Accepted for now: prevent targeted interactions in either direction and suppress push caused by either person for the other, but do not hide shared room events; confirm this broader symmetric behavior with product review.
10. **Safety-review interface:** The HLD requires least-privilege audited review but excludes a separate web app. Accepted for now: use a separate provider/operator role and audited runbook for beta; confirm the provider can enforce the required row and audit boundaries before launch, or scope a minimal internal tool.
11. **Cache budget:** The initial 200-events-per-room and 20-room budget is not device-measured. Accepted for now: keep it in `ProductLimits` and replace it with oldest-device measurements before beta.
12. **Room and asset production:** `lodge-v1` geometry, spawn points, scale bounds, compatibility rules, and action catalogs are placeholders until final art is authored. Accepted for now: version every resource and make unknown/newer versions degrade to safe defaults.
