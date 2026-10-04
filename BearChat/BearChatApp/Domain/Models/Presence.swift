import Foundation

struct PresenceSession: Sendable {
    let roomID: UUID
    let userID: UUID
    let installationID: UUID
    let connectionID: UUID
    let leaseExpiresAt: Date
    let serverObservedAt: Date
}

struct ActiveBear: Sendable {
    let userID: UUID
    let profile: Profile
    let leaseExpiresAt: Date
    let destination: NormalizedPosition
    let movementRevision: Int64
}
