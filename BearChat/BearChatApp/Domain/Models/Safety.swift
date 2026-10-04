import Foundation

struct UserBlockRequest: Sendable {
    let targetUserID: UUID
    let isBlocked: Bool
}

struct ReportSubmission: Sendable {
    let roomID: UUID
    let category: String
    let reportedUserID: UUID?
    let reportedEventID: UUID?
    let confirmedDisclosureVersion: Int
}

struct ReportReceipt: Sendable {
    let reportID: UUID
    let status: String
}
