import Foundation

struct Profile: Sendable {
    let id: UUID
    let displayName: String
    let appearance: Appearance
    let revision: Int64
    let updatedAt: Date
}
