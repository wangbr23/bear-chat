import Foundation

struct Appearance: Sendable {
    let schemaVersion: Int
    let bodyID: String
    let faceID: String
    let furColorID: String
    let accentColorID: String
    let clothingIDs: [String]
    let accessoryIDs: [String]
}
