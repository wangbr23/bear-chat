# Bear Chat — Product Spec

**Last updated:** 2026-09-19

## Overview

Bear Chat is an iPhone experience for friends who use iMessage in one-to-one conversations and private groups of up to eight people. It turns a conversation into a Club Penguin-style room where each participant appears as a customizable bear beside the saved text chat. People can continue messaging, express themselves through animated emotes, and direct playful actions at another bear without moving the conversation into a separate chat service.

## Core Concepts

### Bear

A bear is the visual identity of one participant. Each bear belongs to one person and uses the same saved appearance across every Bear Chat conversation. Its appearance includes body features, facial features, fur and accent colors, clothing, and layered accessories chosen from the options provided by Bear Chat. A bear can be idle, speaking, emoting, performing an action, reacting, or receiving another bear's action. A person who has not customized a bear appears as a default bear.

### Room

A room is the shared visual space attached to one iMessage conversation. It contains one bear for each current participant, up to eight bears, and is presented together with the conversation's chat panel. A room can be loading, ready for interaction, or unavailable because the conversation has more than eight participants. Entering or leaving a group adds or removes that participant's bear from the room.

### Chat Panel

The chat panel is the saved, chronological conversation shown as part of the Bear Chat experience. It contains the conversation's text messages and recognizable entries for bear actions and reactions. Messages can be sent, delivered, failed, or received, consistent with the status visible in iMessage. Bear Chat does not create a separate conversation history.

### Bear Message

A bear message is a text message composed while using Bear Chat. It has an author, text, place in the conversation, and delivery status. In the room, it appears to come from the author's bear; in the chat panel, it remains readable as part of the saved conversation.

### Action

An action is a provided animated behavior performed by a bear. An emote expresses the sender's mood without a target. An interaction names one other bear as its target, but everyone in the conversation can see it. An action identifies the acting bear, any targeted bear, and what happened. It can be sending, ready to play, playing, played, failed, or available for replay.

### Reaction

A reaction is a provided response to a bear message or action. It identifies the responding bear and the event being answered. A reaction is visible to everyone in the conversation and becomes part of recent activity.

### Recent Activity

Recent activity is the ordered list of the latest 20 bear messages, actions, and reactions in a conversation. Each event identifies who initiated it and, when relevant, who was targeted. Actions and reactions in this list can be new, played, or replayed. When a newer event arrives after the list is full, the oldest event leaves recent activity, while text messages remain in the normal conversation history.

## Functional Requirements

### FR-1: Entering and Viewing a Room

- **FR-1.1:** The user can open Bear Chat from an existing iMessage conversation without moving to a separate chat service.
- **FR-1.2:** The system shows the room and the conversation's chat panel together as one Bear Chat experience.
- **FR-1.3:** The system shows one bear for every current conversation participant when the conversation has eight or fewer participants.
- **FR-1.4:** The system shows a default bear for a participant who has not created a custom appearance.
- **FR-1.5:** The system shows the current participant's bear distinctly enough that the user can identify which bear is theirs.
- **FR-1.6:** The system shows the current group membership by adding or removing a bear when the corresponding participant joins or leaves the conversation.
- **FR-1.7:** The system shows a clear explanation when a conversation has more than eight participants and leaves the normal iMessage conversation available.

### FR-2: Text Conversation

- **FR-2.1:** The user can compose and send a text message from the Bear Chat experience.
- **FR-2.2:** The system shows a newly sent text message as speech from the sender's bear in the room.
- **FR-2.3:** The system shows each text message in chronological order in the chat panel with an identifiable sender.
- **FR-2.4:** The system shows Bear Chat text messages in the same saved conversation history as the user's normal iMessages.
- **FR-2.5:** The system shows new incoming text messages in the chat panel while the room is open.
- **FR-2.6:** The system shows the sending bear speaking when a new bear message arrives while the room is open.
- **FR-2.7:** The system shows when a message could not be sent and lets the sender retry it.
- **FR-2.8:** The user can close Bear Chat and continue using the normal iMessage conversation without losing sent messages.

### FR-3: Bear Actions and Emotes

- **FR-3.1:** The user can browse the emotes and interactive actions included with Bear Chat.
- **FR-3.2:** The user can make their bear perform an emote without choosing another participant.
- **FR-3.3:** The user can choose one other participant's bear as the target of an interactive action.
- **FR-3.4:** The system shows the acting bear and any targeted bear before the user confirms an interactive action.
- **FR-3.5:** The system shows a sent action to every participant in the conversation, including participants who were not targeted.
- **FR-3.6:** The system shows the identities of the acting bear and targeted bear when an action plays or is listed in recent activity.
- **FR-3.7:** The system shows a new action playing once when it arrives while the recipient has the room open.
- **FR-3.8:** The system shows multiple arriving actions in conversation order so that no action hides or replaces another.
- **FR-3.9:** The system shows that an action cannot be sent and asks the user to choose again if the targeted participant is no longer in the conversation.
- **FR-3.10:** The system shows when an action could not be sent and lets the sender retry it.

### FR-4: Reactions and Recent Activity

- **FR-4.1:** The user can react to a bear message or action using a provided bear reaction.
- **FR-4.2:** The system shows a reaction to every participant and identifies both the responding bear and the event being answered.
- **FR-4.3:** The system shows the latest 20 bear messages, actions, and reactions in chronological order when the user returns to a room.
- **FR-4.4:** The user can replay any action or reaction that remains in recent activity.
- **FR-4.5:** The system shows only the latest 20 events in recent activity, removing the oldest event when a twenty-first event arrives.
- **FR-4.6:** The user can still find text messages in the normal chat history after they leave recent activity.
- **FR-4.7:** The system shows a clear non-animated description of an action or reaction when its animation cannot play.

### FR-5: Bear Customization

- **FR-5.1:** The user can open a character editor for their bear.
- **FR-5.2:** The user can choose their bear's body features, facial features, fur colors, and accent colors from the provided options.
- **FR-5.3:** The user can choose clothing and combine compatible accessories in layers from the provided options.
- **FR-5.4:** The system shows a current preview of the bear while the user changes its appearance.
- **FR-5.5:** The user can save the edited appearance or leave the editor without replacing the previously saved appearance.
- **FR-5.6:** The system shows the user's saved bear appearance in every Bear Chat conversation they open.
- **FR-5.7:** The system shows the user's new bear appearance in open rooms after the user saves it.
- **FR-5.8:** The user can use every appearance option included in the MVP without payment, currency, or an unlock requirement.

### FR-6: Participants Without Bear Chat

- **FR-6.1:** The system shows a recognizable preview when a recipient without Bear Chat receives a bear message, action, or reaction.
- **FR-6.2:** The system shows the sender and message text in the preview of a bear message so that installing Bear Chat is not required to read it.
- **FR-6.3:** The system shows the acting bear, targeted bear when applicable, and a plain description in the preview of an action or reaction.
- **FR-6.4:** The system shows a clear invitation for a recipient without Bear Chat to install or open it.
- **FR-6.5:** The user can enter the correct conversation room after accepting an invitation and opening Bear Chat.

## Non-Functional Requirements

### NFR-1: Performance

- **NFR-1.1:** The user can begin interacting with Bear Chat within 2 seconds of opening it under normal device and connectivity conditions.
- **NFR-1.2:** The system shows visible feedback within 0.2 seconds after the user taps a Bear Chat control.
- **NFR-1.3:** The user can interact with the controls without noticeable delay while all eight supported bears are in a room.

### NFR-2: Privacy

- **NFR-2.1:** The user can use all MVP features without creating a Bear Chat account or providing a separate email address, phone number, or public profile.
- **NFR-2.2:** The user can send messages without Bear Chat collecting their contents.
- **NFR-2.3:** The system shows a user's bear messages, actions, reactions, and appearance only to participants in the selected iMessage conversation.
- **NFR-2.4:** The user can use Bear Chat without the user, their bear, or their rooms appearing in public search or discovery.

### NFR-3: Connectivity and Resilience

- **NFR-3.1:** The system shows send availability for bear messages, actions, and reactions that is consistent with the connectivity status visible in iMessage.
- **NFR-3.2:** The user can view already available conversation content and edit their bear when sending is temporarily unavailable.
- **NFR-3.3:** The user can continue using the normal iMessage conversation if Bear Chat cannot load or play an event.

### NFR-4: Accessibility

- **NFR-4.1:** The user can navigate the room, chat panel, actions, reactions, and character editor with VoiceOver.
- **NFR-4.2:** The system shows or speaks a description for each bear action and visual state that communicates the same meaning as the animation.
- **NFR-4.3:** The system shows reduced or no nonessential animation when the user enables Reduce Motion without hiding messages, actions, or outcomes.
- **NFR-4.4:** The system shows a non-color indicator for every participant, status, selection, and action outcome that uses color.

### NFR-5: Platform and Scale

- **NFR-5.1:** The user can use the MVP on supported iPhones within iMessage.
- **NFR-5.2:** The user can use Bear Chat in one-to-one conversations and private group conversations with up to eight participants.
- **NFR-5.3:** The user can read the chat and follow action playback throughout a conversation containing all eight supported participants.

## Out of Scope for MVP

- A separate Bear Chat messaging app or conversation service
- Bear Chat accounts or public user profiles
- Purchases, subscriptions, advertising, virtual currency, or paid unlocks
- Public rooms, public discovery, stranger matching, or a social feed
- User-uploaded bear artwork, clothing, accessories, emotes, or actions
- Voice calls, video calls, or voice messages created through Bear Chat
- Minigames or game progression systems
- Support for groups with more than eight participants
- Support for iPad, Mac, Android, or other non-iPhone platforms
- A permanent Bear Chat replay archive beyond the latest 20 events
