import Foundation

enum APNSEnvironment: Sendable {
    case sandbox
    case production
}

enum NotificationPreviewMode: Sendable {
    case generic
    case detailed
}

struct PushDeviceRegistration: Sendable {
    let installationID: UUID
    let environment: APNSEnvironment
    let deviceToken: Data
    let previewMode: NotificationPreviewMode
}

struct RoomNotificationPreference: Sendable {
    let roomID: UUID
    let isMuted: Bool
}
