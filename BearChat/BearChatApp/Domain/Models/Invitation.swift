import Foundation

struct Invitation: Sendable {
    let id: UUID
    let roomID: UUID
    let creatorID: UUID
    let expiresAt: Date
}

enum InvitationJoinResult: Sendable {
    case joined(roomID: UUID)
    case invalid
    case expired
    case used
    case roomFull
}
