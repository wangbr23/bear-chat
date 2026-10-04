enum ProductLimits {
    static let maxDisplayNameLength = 30
    static let maxRoomNameLength = 50
    static let maxMessageLength = 1_000
    static let invitationExpiryDays = 7
    static let roomMemberCapacity = 8
    static let recentActivityLimit = 20

    // Starting event-page size; the LLD only bounds pages without pinning a number.
    static let eventPageSize = 50

    // Starting cache budgets from the LLD; replace with measured limits before beta.
    static let cachedEventsPerRoom = 200
    static let cachedRoomLimit = 20
}
