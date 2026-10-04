import Foundation

enum RoomMembershipRole: Sendable {
    case owner
    case member
}

struct RoomSummary: Sendable {
    let id: UUID
    let name: String
    let ownerID: UUID
    let membershipRole: RoomMembershipRole
    let isMuted: Bool
    let newestSequence: Int64
    let updatedAt: Date
}

struct RoomMember: Sendable {
    let roomID: UUID
    let userID: UUID
    let role: RoomMembershipRole
    let joinedAt: Date
    let profile: Profile
}
