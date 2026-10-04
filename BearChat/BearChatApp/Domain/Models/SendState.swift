import Foundation

enum SendFailure: Sendable {
    case retryable
    case targetUnavailable
    case accessRevoked
    case invalid
}

enum SendState: Sendable {
    case draft
    case sending
    case awaitingReconciliation
    case failed(SendFailure)
}

struct PendingRoomEvent: Sendable {
    let clientEventID: UUID
    let roomID: UUID
    let kind: RoomEventKind
    let payload: RoomEventPayload
    let targetUserID: UUID?
    let referencedEventID: UUID?
    let state: SendState
    let createdAt: Date
}
