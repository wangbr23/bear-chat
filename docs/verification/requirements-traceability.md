# Requirements Traceability Matrix

Maps every functional (FR) and non-functional (NFR) requirement in
`docs/designs/product-spec.md` to planned verification work. No requirement is
covered by a generic test-suite label — each row names the concrete planned
test, measurement, or review.

- **Owner (all rows):** Bradley Wang. Split per-row ownership here if that changes.
- **Status:** every row is planned, not yet verified. `T185` records the final
  automated and manual verification references; a later CI gate rejects missing
  FR/NFR IDs and unresolved release-gate rows (see LLD "Test mapping").
- **Task references** point at `TODO.md`. Verification artifact names come from
  the LLD test-mapping table.

## FR-1: Account and Onboarding

| ID | Requirement | Planned verification |
|---|---|---|
| FR-1.1 | Sign in with Apple; no separate password or phone number | `AuthenticationUITests` + `SessionControllerTests` (T180); staging device scenarios (T187) |
| FR-1.2 | Choose and update display name visible only to room-mates | Profile RPC and RLS tests (T60, T53, T83); membership UI tests (T181) |
| FR-1.3 | Rooms, profile, and bear restore on another supported iPhone | Second-device staging device test (T187); session restore UI tests (T180) |
| FR-1.4 | Sign out without deleting account or room history | Sign-out cache-destruction tests (T109); `AuthenticationUITests` (T180) |
| FR-1.5 | Delete account in the app | Deletion settings UI (T166); `SafetyUITests` (T182) |
| FR-1.6 | Deletion removes profile/memberships, anonymizes entries as "Deleted Bear", drops unrequired content | `safety_rpc_test.sql` and `delete-account.test.ts` scenarios (T81, T164); `SafetyUITests` (T182) |

## FR-2: Creating, Joining, and Managing Rooms

| ID | Requirement | Planned verification |
|---|---|---|
| FR-2.1 | Create one-to-one or group room with a name | Room-creation RPC tests (T61); concurrency tests (T84); UI tests (T181) |
| FR-2.2 | Owner creates, revokes, and replaces private invitation link | Invitation RPC tests (T62, T63); owner-control UI tests (T116, T181) |
| FR-2.3 | Valid invitation joins the intended room below eight members | Join RPC tests (T64); ninth-join race tests (T84); join UI tests (T114, T181) |
| FR-2.4 | Rejects expired, revoked, invalid, limited, or full invitations with clear explanation | Join error scenarios (T64, T114); T84 assertions; UI tests (T181) |
| FR-2.5 | View current members separately from active bears | Membership list UI tests (T115, T181) |
| FR-2.6 | Member can leave a room | Leave RPC with owner protection (T66); T84; UI tests (T118, T181) |
| FR-2.7 | Owner removes member, transfers ownership, or deletes room | Removal/transfer/deletion RPC tests (T67, T68, T69); T84; UI tests (T119–T121, T181) |
| FR-2.8 | Owner must transfer before leaving a room with other members | Owner-departure protection tests (T66, T84) |
| FR-2.9 | Never more than eight members | Capacity enforcement in join RPC (T64); ninth-join race tests (T84) |

## FR-3: Entering and Viewing a Room

| ID | Requirement | Planned verification |
|---|---|---|
| FR-3.1 | Open room shows visual space and saved chat together | Room shell tests (T127); snapshot matrix (T184) |
| FR-3.2 | One bear per currently active member | Scene rendering (T138, T132); presence DB tests (T86); snapshots (T184) |
| FR-3.3 | Default bear for active member without customization | Asset fallback tests (T136, T137); snapshots (T184) |
| FR-3.4 | Current user's bear identified without color alone | Current-user marker accessibility assertions (T183); device visual acceptance (T192) |
| FR-3.5 | Bear added on activation, removed after leaving or losing connection | Presence lifecycle tests (T131, T138); multi-device DB tests (T86) |
| FR-3.6 | Only own bear when alone; messages and group activity remain | Presence-degraded state tests (T132); offline/cache integration tests (T175, T86) |
| FR-3.7 | Clear reconnecting/unavailable state without hiding chat | Reconnect behavior tests (T126, T132); sync tests (T174); cache tests (T175) |
| FR-3.8 | Tap unoccupied walkable place to move | Walkable-map geometry tests (T133); hit-testing tests (T139) |
| FR-3.9 | Immediate destination mark and bear movement | Movement interpolation tests (T135, T139); timing measurements (T178, T179) |
| FR-3.10 | Remote movements never enter chat or recent activity | Movement integration tests (T141, T135); sync tests (T174) |
| FR-3.11 | Bears scale and layer by vertical position for depth | Depth projection tests (T134, T141); performance measurements (T179); snapshots (T184) |
| FR-3.12 | Tapping another bear selects it for interaction | Bear-first hit-testing tests (T139); UI tests (T181) |
| FR-3.13 | Read and send messages, actions, reactions without moving | Room shell and composer tests (T127–T129); UI tests (T181) |

## FR-4: Text Conversation

| ID | Requirement | Planned verification |
|---|---|---|
| FR-4.1 | Compose and send a text message | Composer tests (T129); UI tests (T181) |
| FR-4.2 | One authoritative place per accepted message | Submission RPC idempotent ordering (T71); eight-sender DB tests (T85) |
| FR-4.3 | Accepted message appears as active sender's speech | Name and speech layout tests (T140); snapshots (T184) |
| FR-4.4 | Message shows identifiable sender and timestamp | Chat history tests (T128); UI tests (T181); snapshots (T184) |
| FR-4.5 | New messages reach active members without refresh | Query-subscribe-query handshake tests (T124); sync tests (T174) |
| FR-4.6 | Messages sent while away appear on return | Catch-up handshake (T124); cache pages (T89); sync tests (T174, T175) |
| FR-4.7 | Sending/sent/failed states; never claims read | Composer state tests (T129); UI tests (T181) |
| FR-4.8 | Retry never duplicates a message | Idempotent submission (T71); pending-send reconciliation (T125); DB tests (T85) |
| FR-4.9 | Load older messages from saved history | Newest-first pagination tests (T128); cache integration tests (T175) |

## FR-5: Bear Actions and Emotes

| ID | Requirement | Planned verification |
|---|---|---|
| FR-5.1 | Browse included emotes, group actions, interactive actions | Catalog loading tests (T145); UI tests (T181) |
| FR-5.2 | Send emote or group action when nobody else is active | Non-targeted submission tests (T146); UI tests (T181) |
| FR-5.3 | Choose one currently active bear as interaction target | Target selection tests (T147); UI tests (T181) |
| FR-5.4 | Acting and targeted bear shown before confirmation | Confirmation UI tests (T147, T181) |
| FR-5.5 | Targeted interaction accepted only while target presence valid | Submission RPC target-lease validation (T71); event tests (T85); authorization tests (T83) |
| FR-5.6 | Sent action reaches every member including inactive or untargeted | Playback and recent-activity tests (T149, T151); sync tests (T174) |
| FR-5.7 | Acting and targeted bears identified in playback, chat, activity | Integration tests (T150, T151); snapshots (T184) |
| FR-5.8 | Received actions play one at a time in authoritative order | Serial playback tests (T149); reorder sync tests (T174) |
| FR-5.9 | Cannot send when target left or lost presence; asks to choose again | Target-expiry recovery tests (T147); event tests (T85) |
| FR-5.10 | Failed send shown; retry without duplicating | Failed-state tests (T149); idempotent retry (T125, T85) |

## FR-6: Reactions and Recent Activity

| ID | Requirement | Planned verification |
|---|---|---|
| FR-6.1 | React to a message or action with a provided reaction | Reaction submission tests (T148); UI tests (T181) |
| FR-6.2 | Reaction reaches all members; identifies responder and referenced event | Reaction tests (T148); event tests (T85); sync tests (T174) |
| FR-6.3 | Authoritative latest 20 items in chronological order | Recent-activity tests (T151); eight-sender DB tests (T85) |
| FR-6.4 | Replay any action or reaction still in recent activity | Replay queue tests (T149); UI tests (T181) |
| FR-6.5 | Twenty-first event removes the oldest recent-activity item | Recent-activity eviction tests (T151, T85) |
| FR-6.6 | Text and plain-language entries stay readable after eviction | Chat history tests (T128, T151); UI tests (T181) |
| FR-6.7 | Clear non-animated description when animation cannot play | Fallback tests (T152); fuzz tests for unknown assets (T176); a11y assertions (T183) |

## FR-7: Bear Customization

| ID | Requirement | Planned verification |
|---|---|---|
| FR-7.1 | Open a character editor | Editor UI tests (T143, T181) |
| FR-7.2 | Choose body, facial, fur, and accent options from catalog | Asset-catalog tests (T136); editor UI tests (T143); snapshots (T184) |
| FR-7.3 | Choose clothing and combine compatible accessory layers | Editor layering tests (T143); snapshots (T184) |
| FR-7.4 | Live preview while editing | Editor preview tests (T143); snapshots (T184) |
| FR-7.5 | Save or leave without replacing prior appearance | Save/cancel tests (T143, T181) |
| FR-7.6 | Saved appearance appears in every room and on every supported iPhone | Save propagation tests (T144); second-device device tests (T187) |
| FR-7.7 | Members currently sharing the room see the update | Profile refresh tests (T144); sync tests (T174) |
| FR-7.8 | Every MVP appearance option free of payment or unlock | Allowlisted catalog tests (T136, T51); device visual acceptance (T192) |

## FR-8: Invitations and Notifications

| ID | Requirement | Planned verification |
|---|---|---|
| FR-8.1 | Share invitation through the iOS share sheet | Share-sheet UI tests (T112, T181) |
| FR-8.2 | Non-member sees recognizable install/open page exposing no private content | Content-free landing page (T113); manual landing-page review at device acceptance (T192) |
| FR-8.3 | Recipient returns to intended invitation after install and sign-in while valid | Deep-link handoff UI tests (T114); staging device scenarios (T187) |
| FR-8.4 | Notification for new room activity while app closed | APNs delivery tests (T155); staging APNs scenarios (T189) |
| FR-8.5 | Generic previews by default; detail only when enabled | Detailed-preview tests (T156); staging scenarios (T189) |
| FR-8.6 | Mute notifications per room | Mute tests (T158, T117); staging scenarios (T189) |

## FR-9: Safety and Control

| ID | Requirement | Planned verification |
|---|---|---|
| FR-9.1 | Report message, action, reaction, or participant in context | Report capture RPC (T80); report UI tests (T161, T182) |
| FR-9.2 | Block another participant's interactions and notifications | Block RPC tests (T79); block UI tests (T160, T182) |
| FR-9.3 | Owner can remove reported or blocked member | Owner removal tests (T68, T160); UI tests (T182) |
| FR-9.4 | Rate-limit invitations and event sends beyond normal use | Rate counter tests (T48, T71, T62); adversarial tests (T83); load measurements (T177, T178); production values deferred to T23/T172 |
| FR-9.5 | Preserve only needed report context; tell reporter what is shared | Exact-disclosure tests (T80); report UI tests (T161, T182) |

## NFR-1: Performance

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-1.1 | Cached room usable within 2 seconds of opening | Oldest-device cache measurements (T179); device threshold verification (T188) |
| NFR-1.2 | Visible feedback within 0.2 seconds of a tap | Interaction measurements (T179); device verification (T188) |
| NFR-1.3 | No noticeable delay with all eight members active | Eight-bear rendering measurements (T179); load measurements (T177) |
| NFR-1.4 | New active member within 2 s; clean disconnect removed within 5 s | Presence DB tests (T86); device threshold verification (T188) |
| NFR-1.5 | Interrupted presence session removed within 30 seconds | Cleanup job tests (T76); device verification (T188) |
| NFR-1.6 | Newest page loads first without full history | Cache page tests (T89, T128); integration tests (T175) |
| NFR-1.7 | Local movement feedback 0.2 s; remote movement visible within 1 s | Movement timing measurements (T178, T179); device verification (T188) |

## NFR-2: Privacy and Data

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-2.1 | No phone number, address book, separate password, or public profile | SiwA flow tests (T106, T180); privacy review (T190) |
| NFR-2.2 | Store private content only for messaging, sync, safety, requested history | Policy publication (T21); privacy/security review (T190) |
| NFR-2.3 | Encrypt in transit and at rest; restrict production access | Privacy/security review checklist (T190) |
| NFR-2.4 | Non-E2EE stated accurately; no contrary claims | Approved copy and privacy manifest (T21, T168); review (T190) |
| NFR-2.5 | Only current members retrieve room content | Authorization tests for every protected read (T53–T59, T83) |
| NFR-2.6 | Presence only in selected room; not retained as history | Presence RLS and cleanup (T56, T76); T83; DB tests (T86) |
| NFR-2.7 | Positions shared only with current members while active; not history | Movement RLS (T56, T75); T83; DB tests (T86) |
| NFR-2.8 | No content sale, ads, public search, or advertising SDK | Binary inspection and privacy manifest (T168, T190) |
| NFR-2.9 | Delete account in app; delete owned room | Deletion tests (T69, T164); UI tests (T182) |
| NFR-2.10 | Logs exclude message text, invite secrets, Apple tokens, notification contents, movement coordinates | Content-free logging boundary (T92); log inspection in review (T190) |

## NFR-3: Connectivity and Resilience

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-3.1 | Resume from last confirmed event without duplicates or reordering | Reducer and handshake tests (T122, T124, T126); sync tests (T174) |
| NFR-3.2 | View cached content and edit bear while offline | Offline integration tests (T91, T175) |
| NFR-3.3 | Offline draft queued for explicit retry; no false sent claim | Pending-send tests (T90, T125); sync tests (T174, T175) |
| NFR-3.4 | Only own bear and no targeting when remote presence unconfirmed | Presence-degraded tests (T132); sync tests (T174); device scenarios (T186) |
| NFR-3.5 | Animation or presence failure never blocks saved chat | Fallback tests (T152); fuzz tests (T176); cache tests (T175) |

## NFR-4: Accessibility

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-4.1 | VoiceOver across selection, chat, bears, actions, membership, reports, editor | Assertions (T142, T183); manual audit (T191) |
| NFR-4.2 | Description for each action and visual state equal to visual meaning | Speech layout and descriptions (T140, T142); assertions (T183); audit (T191) |
| NFR-4.3 | Reduced or no nonessential animation under Reduce Motion | Movement and playback behavior (T142); assertions (T183); audit (T191) |
| NFR-4.4 | Non-color indicator for every participant, status, selection, outcome | Marker and layout tests (T138, T140, T142); audit (T191) |
| NFR-4.5 | Dynamic Type without hiding content or controls | Layout behavior (T128, T140); assertions (T183); audit (T191) |
| NFR-4.6 | Named VoiceOver destinations and nearby-bear announcements | Movement accessibility tests (T142); assertions (T183); audit (T191) |
| NFR-4.7 | Reduce Motion shortens walking, preserves final position | Movement behavior tests (T142); assertions (T183); audit (T191) |

## NFR-5: Security and Abuse Resistance

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-5.1 | Service verifies identity and membership on every room-content request | RLS policies and helpers (T52–T59); adversarial tests (T83) |
| NFR-5.2 | Unguessable, revocable invite secrets; no access when full or expired | Invitation RPC tests (T62, T64); races (T84); T83 |
| NFR-5.3 | Idempotent retries cannot duplicate messages or actions | Submission and pending-send tests (T71, T125); DB tests (T85) |
| NFR-5.4 | User text and identifiers never executable or remote-asset content | Strict decode (T93); asset allowlist (T136); fuzz tests (T176) |
| NFR-5.5 | Admin, safety-review, and deletion actions auditable without private text in logs | Audit schema (T47, T58, T162); runbook drills (T193); review (T190) |

## NFR-6: Platform and Scale

| ID | Requirement | Planned verification |
|---|---|---|
| NFR-6.1 | Supports iPhones on the selected minimum iOS version | iOS 17 deployment target build (T25); device acceptance on oldest supported iPhone (T192, T179) |
| NFR-6.2 | Rooms of two to eight members and eight active bears | Scene tests (T138); DB tests (T85, T86) |
| NFR-6.3 | Authoritative order preserved during eight concurrent senders | Submission RPC (T71); eight-sender DB tests (T85) |
| NFR-6.4 | Usable after reinstall with restored server-backed profile and rooms | Restore integration tests (T175); device scenarios (T187) |
