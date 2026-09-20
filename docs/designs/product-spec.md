# Bear Chat - Product Spec

**Last updated:** 2026-09-20

## Overview

Bear Chat is a private iPhone messenger for close friends in one-to-one rooms and invite-only groups of up to eight people. Each room combines a saved text conversation with a Club Penguin-style shared space. Participants appear as customizable bears only while they actively have that room open, and each person can tap the room floor to move their bear around. People can continue chatting, express themselves through animated emotes and group actions, and direct playful interactions at another active bear.

Bear Chat owns its rooms, message history, membership, presence, notifications, and delivery. It does not read from or write to iMessage. The current visual direction is `docs/designs/bear-chat-room-mock-v2.png`.

## Core Concepts

### Bear Chat Identity

A Bear Chat identity is the private account a person uses to access their rooms and bear across supported iPhones. A person signs in with Apple and chooses a Bear Chat display name. Bear Chat does not require a separately shared email address, phone number, password, address-book upload, or public profile. Identities are not searchable or publicly discoverable.

### Bear

A bear is the visual identity of one participant. Each bear belongs to one Bear Chat identity and uses the same saved appearance across every room. Its appearance includes body features, facial features, fur and accent colors, clothing, and layered accessories chosen from the options provided by Bear Chat. A bear can be idle, moving, speaking, emoting, performing an action, reacting, or receiving another bear's action. A person who has not customized a bear appears as a default bear.

A person's bear is visible in a room only while that person actively has the room open. Inactive members remain in the room's member list and message history but do not occupy the visual space.

### Room

A room is a private Bear Chat conversation with two to eight members. It contains the saved chat, a large walkable visual space for active bears, recent activity, and room membership. A room can be loading, ready, reconnecting, unavailable, or closed. The room creator initially manages invitations and membership. Members can leave; the owner can revoke invitations, remove a member, transfer ownership, or delete the room.

### Active Presence

Active presence means a participant currently has the selected room open and remains connected to it. It describes activity in that room only, not the person's general device or Bear Chat availability. Presence is temporary, is not written into chat history or recent activity, and expires shortly after the person leaves the room or loses the connection.

### Movement

Movement is the temporary position of an active bear in the room. The user taps an unoccupied walkable destination and their bear moves toward it. Other active members see that movement shortly afterward. Bears farther back in the room appear smaller and are drawn behind bears closer to the foreground, preserving the depth cues of a Club Penguin-style room.

Movement is social presence, not a saved conversation event. It is not added to chat or recent activity, and a bear returns to a room's default entry area after all of that person's active sessions have ended. Tapping another bear selects that bear for an interaction rather than treating the bear as a movement destination.

### Chat Panel

The chat panel is the saved, chronological conversation inside a room. It contains text messages and recognizable entries for bear actions and reactions. It loads recent content first and lets the user reach older content. Bear Chat message history is separate from iMessage and remains available to room members until the room is deleted or retention rules require removal.

### Bear Message

A bear message is text sent to a room. It has an author, text, server-assigned place in the conversation, and delivery state. When the author is active, it appears to come from their bear in the room. It always remains readable in the chat panel.

### Action

An action is a provided animated behavior performed by a bear. An emote or non-targeted group action expresses the sender's mood without a target and remains available when nobody else is active. An interaction names one other currently active bear as its target, while every room member can see its chat entry. An action identifies the acting bear, any targeted bear, and what happened. It can be sending, ready to play, playing, played, failed, or available for replay.

### Reaction

A reaction is a provided response to a bear message or action. It identifies the responding bear and the event being answered. A reaction is visible to every room member and becomes part of recent activity.

### Recent Activity

Recent activity is the authoritative ordered list of the latest 20 bear messages, actions, and reactions in a room. Each event identifies who initiated it and, when relevant, who was targeted. Actions and reactions in this list can be new, played, or replayed. When a newer event arrives after the list is full, the oldest event leaves recent activity. Text and plain-language action entries remain in the chat history after leaving recent activity, but old actions are no longer replayable.

### Invitation

An invitation is a private, revocable link that lets a recipient request membership in one room. It can be shared through the iOS share sheet, including through Messages, but does not expose room history before the recipient joins. Opening an invitation launches Bear Chat or its install page, then returns the person to the intended room after sign-in.

## Functional Requirements

### FR-1: Account and Onboarding

- **FR-1.1:** The user can sign in to Bear Chat with Apple without creating a separate password or providing a phone number.
- **FR-1.2:** The user can choose and update a Bear Chat display name visible only to people who share a room with them.
- **FR-1.3:** The system restores the user's rooms, profile, and bear after the user signs in on another supported iPhone.
- **FR-1.4:** The user can sign out without deleting their account or room history.
- **FR-1.5:** The user can delete their Bear Chat account in the app.
- **FR-1.6:** Account deletion removes the user's profile and memberships, anonymizes retained conversation entries as "Deleted Bear," and removes content that Bear Chat is not required to retain for other members or a safety report.

### FR-2: Creating, Joining, and Managing Rooms

- **FR-2.1:** The user can create a one-to-one or group room and give it a name.
- **FR-2.2:** The room owner can create, revoke, and replace a private invitation link.
- **FR-2.3:** A signed-in recipient can use a valid invitation to join the intended room when it has fewer than eight members.
- **FR-2.4:** The system rejects expired, revoked, invalid, already-used when limited, or full-room invitations with a clear explanation.
- **FR-2.5:** The user can view the current room members separately from the active bears.
- **FR-2.6:** A member can leave a room.
- **FR-2.7:** The owner can remove a member, transfer ownership, or delete the room for all members.
- **FR-2.8:** The owner must transfer ownership before leaving a room that still has other members.
- **FR-2.9:** The system never allows a room to contain more than eight members.

### FR-3: Entering and Viewing a Room

- **FR-3.1:** The user can open a room and see its visual space and saved chat panel together.
- **FR-3.2:** The system shows one bear for every member who currently has that room open.
- **FR-3.3:** The system shows a default bear for an active member who has not customized an appearance.
- **FR-3.4:** The system identifies the current user's bear without relying on color alone.
- **FR-3.5:** The system adds a member's bear when that member becomes active and removes it shortly after they leave or lose the active connection.
- **FR-3.6:** The system shows only the current user's bear when no other member is active, while leaving messages and non-targeted group actions available.
- **FR-3.7:** The system shows a clear reconnecting or unavailable state without hiding locally available chat content.
- **FR-3.8:** The user can tap an unoccupied walkable place in the room to move their bear there.
- **FR-3.9:** The system immediately marks the selected destination and shows the bear moving toward it.
- **FR-3.10:** The system shows other active members' bear movements without adding those movements to chat or recent activity.
- **FR-3.11:** The system scales and layers bears by their vertical room position so movement preserves a readable sense of depth.
- **FR-3.12:** Tapping another bear selects that bear for an interaction instead of moving the current bear through it.
- **FR-3.13:** The user can read and send messages, actions, and reactions without moving their bear.

### FR-4: Text Conversation

- **FR-4.1:** The user can compose and send a text message to a room.
- **FR-4.2:** The system assigns each accepted message one authoritative place in the room's chronological history.
- **FR-4.3:** The system shows a newly accepted message as speech from the sender's bear when that sender is active.
- **FR-4.4:** The system shows each message in the chat panel with an identifiable sender and timestamp.
- **FR-4.5:** The system delivers new messages to active room members without requiring a refresh.
- **FR-4.6:** The system makes messages sent while a member was away available when they return.
- **FR-4.7:** The system shows sending, sent-to-service, and failed states without claiming that another person has read a message.
- **FR-4.8:** The system prevents a retry from creating a duplicate message.
- **FR-4.9:** The user can load older messages in the room's saved history.

### FR-5: Bear Actions and Emotes

- **FR-5.1:** The user can browse the emotes, non-targeted group actions, and interactive actions included with Bear Chat.
- **FR-5.2:** The user can send an emote or non-targeted group action when nobody else is active.
- **FR-5.3:** The user can choose one other currently active bear as the target of an interactive action.
- **FR-5.4:** The system shows the acting bear and targeted bear before the user confirms an interaction.
- **FR-5.5:** The service accepts a targeted interaction only while the target still has valid active presence in that room.
- **FR-5.6:** The system shows a sent action to every room member, including members who were inactive or not targeted.
- **FR-5.7:** The system identifies the acting bear and targeted bear when an action plays or appears in chat and recent activity.
- **FR-5.8:** The system plays newly received actions one at a time in authoritative conversation order while the room is open.
- **FR-5.9:** The system shows that an interaction cannot be sent and asks the user to choose again if the target is no longer active or no longer belongs to the room.
- **FR-5.10:** The system shows a failed send and lets the sender retry without creating a duplicate action.

### FR-6: Reactions and Recent Activity

- **FR-6.1:** The user can react to a bear message or action using a provided bear reaction.
- **FR-6.2:** The system shows a reaction to every room member and identifies the responding bear and referenced event.
- **FR-6.3:** The system shows the authoritative latest 20 bear messages, actions, and reactions in chronological order.
- **FR-6.4:** The user can replay any action or reaction that remains in recent activity.
- **FR-6.5:** The system removes the oldest item from recent activity when a twenty-first newer event arrives.
- **FR-6.6:** Text and plain-language action entries remain readable in chat history after leaving recent activity.
- **FR-6.7:** The system shows a clear non-animated description when an animation cannot play.

### FR-7: Bear Customization

- **FR-7.1:** The user can open a character editor for their bear.
- **FR-7.2:** The user can choose body features, facial features, fur colors, and accent colors from provided options.
- **FR-7.3:** The user can choose clothing and combine compatible accessories in layers from provided options.
- **FR-7.4:** The system shows a current preview while the user changes the appearance.
- **FR-7.5:** The user can save the edited appearance or leave without replacing the prior appearance.
- **FR-7.6:** The system shows the saved bear appearance in every room and on every supported iPhone where the user signs in.
- **FR-7.7:** The system updates the appearance for members currently sharing a room after the user saves it.
- **FR-7.8:** The user can use every appearance option included in the MVP without payment, currency, or unlock requirements.

### FR-8: Invitations and Notifications

- **FR-8.1:** The user can share a room invitation through the iOS share sheet.
- **FR-8.2:** A recipient without Bear Chat sees a recognizable install/open page that does not expose private room content.
- **FR-8.3:** The system returns the recipient to the intended invitation after installation and sign-in when the invitation remains valid.
- **FR-8.4:** A member can receive a notification for new room activity while Bear Chat is not open.
- **FR-8.5:** Notification previews are generic by default and expose sender or message text only when the user enables detailed previews.
- **FR-8.6:** The user can mute notifications per room.

### FR-9: Safety and Control

- **FR-9.1:** A member can report a message, action, reaction, or participant from the relevant room context.
- **FR-9.2:** A member can block another participant from directing interactions or notifications at them.
- **FR-9.3:** A room owner can remove a reported or blocked member from the room.
- **FR-9.4:** The system rate-limits invitations and event sends that exceed normal use.
- **FR-9.5:** The system preserves only the report context needed for review and tells the reporter what will be shared.

## Non-Functional Requirements

### NFR-1: Performance

- **NFR-1.1:** The user can begin interacting with a cached room within 2 seconds of opening it under normal device and connectivity conditions.
- **NFR-1.2:** The system shows visible feedback within 0.2 seconds after the user taps a control.
- **NFR-1.3:** The user can interact without noticeable delay while all eight room members are active.
- **NFR-1.4:** The system normally shows a newly active member within 2 seconds and removes a cleanly disconnected member within 5 seconds.
- **NFR-1.5:** The system removes an interrupted presence session within 30 seconds.
- **NFR-1.6:** The chat panel loads the newest page first and does not require the complete room history before becoming usable.
- **NFR-1.7:** A local bear begins responding within 0.2 seconds of a valid movement tap, and remote active clients normally begin showing that movement within 1 second.

### NFR-2: Privacy and Data

- **NFR-2.1:** The user can sign in without sharing a phone number, address book, separate password, or publicly discoverable profile.
- **NFR-2.2:** Bear Chat stores private room content only to provide messaging, synchronization, safety, and user-requested history.
- **NFR-2.3:** Bear Chat encrypts data in transit and at rest and restricts production access to authorized operational needs.
- **NFR-2.4:** MVP messages are not end-to-end encrypted; the product explains this accurately and does not claim otherwise.
- **NFR-2.5:** Only current room members can retrieve that room's messages, actions, reactions, profiles, and presence.
- **NFR-2.6:** Presence reveals activity only inside the selected room and is not retained as history.
- **NFR-2.7:** Bear positions and movement are shared only with current members while the room is active and are not retained as room history.
- **NFR-2.8:** Bear Chat does not sell room content, use it for advertising, expose public search, or include an advertising SDK.
- **NFR-2.9:** The user can delete their account in the app and can delete a room they own.
- **NFR-2.10:** Operational logs exclude message text, invitation secrets, Apple identity tokens, notification contents, and movement coordinates.

### NFR-3: Connectivity and Resilience

- **NFR-3.1:** The system resumes from the last confirmed room event after a reconnect without duplicating or reordering accepted events.
- **NFR-3.2:** The user can view locally cached room content and edit their bear while temporarily offline.
- **NFR-3.3:** The system queues a local draft for explicit retry but does not claim it was sent while disconnected.
- **NFR-3.4:** The user sees only their own bear and cannot target an interaction when current remote presence cannot be confirmed.
- **NFR-3.5:** A failure in animation or presence does not block access to saved chat content.

### NFR-4: Accessibility

- **NFR-4.1:** The user can navigate room selection, chat, bears, actions, reactions, membership, reporting, and customization with VoiceOver.
- **NFR-4.2:** The system shows or speaks a description for each bear action and visual state that communicates the same meaning as the animation.
- **NFR-4.3:** The system shows reduced or no nonessential animation when Reduce Motion is enabled without hiding messages, actions, or outcomes.
- **NFR-4.4:** The system uses a non-color indicator for every participant, status, selection, and action outcome that otherwise uses color.
- **NFR-4.5:** The chat panel supports Dynamic Type without hiding message content or controls.
- **NFR-4.6:** VoiceOver users can choose named room destinations and hear nearby bear positions without relying on free-form tapping.
- **NFR-4.7:** Reduce Motion shortens or replaces walking animation while preserving the same final bear position.

### NFR-5: Security and Abuse Resistance

- **NFR-5.1:** Every room-content request verifies signed-in identity and current room membership on the service, not only in the app.
- **NFR-5.2:** Invitation links use unguessable, revocable secrets and never grant access after the room is full or the invitation expires.
- **NFR-5.3:** Event retries are idempotent and cannot create duplicate messages or actions.
- **NFR-5.4:** User text and identifiers are treated as untrusted input and never interpreted as executable content or remote asset locations.
- **NFR-5.5:** Administrative access, safety review, and account deletion actions are auditable without placing private message text in general logs.

### NFR-6: Platform and Scale

- **NFR-6.1:** The MVP supports iPhones on the selected minimum iOS version.
- **NFR-6.2:** A room supports two to eight members and up to eight simultaneously active bears.
- **NFR-6.3:** The service preserves authoritative event order during concurrent sends from all eight members.
- **NFR-6.4:** The product remains usable on a new installation after Sign in with Apple restores the user's server-backed profile and room memberships.

## Out of Scope for MVP

- iMessage extension functionality or access to iMessage conversations
- End-to-end message encryption
- Public rooms, public profiles, public discovery, stranger matching, or a social feed
- Address-book upload or automatic contact matching
- Android, iPad, Mac, web, or other non-iPhone clients
- Groups with more than eight members
- Photos, files, links with rich previews, voice messages, voice calls, or video calls
- Message editing, threaded replies, full-text search, or read receipts
- User-uploaded bear artwork, clothing, accessories, emotes, or actions
- Purchases, subscriptions, advertising, virtual currency, or paid unlocks
- Minigames or game progression systems
- Interactive furniture, collision gameplay, or walking between multiple themed locations
- Permanent animation replay beyond the latest 20 recent events
