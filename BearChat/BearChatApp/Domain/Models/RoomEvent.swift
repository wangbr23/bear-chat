import Foundation

enum RoomEventKind: Sendable {
    case text
    case emote
    case groupAction
    case interaction
    case reaction
}

enum RoomEventPayload: Sendable {
    case text(schemaVersion: Int, text: String)
    case emote(schemaVersion: Int, emoteID: String)
    case groupAction(schemaVersion: Int, actionID: String)
    case interaction(schemaVersion: Int, actionID: String)
    case reaction(schemaVersion: Int, reactionID: String)
    case unsupported(schemaVersion: Int)
}

struct RoomEvent: Sendable {
    let id: UUID
    let roomID: UUID
    let sequence: Int64
    let senderID: UUID?
    let clientEventID: UUID
    let kind: RoomEventKind
    let payload: RoomEventPayload
    let targetUserID: UUID?
    let referencedEventID: UUID?
    let createdAt: Date
}
