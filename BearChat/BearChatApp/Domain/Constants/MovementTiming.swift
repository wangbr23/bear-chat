import Foundation

enum MovementTiming {
    static let destinationDebounce: TimeInterval = 0.15
    static let interactionFeedbackInterval: TimeInterval = 0.2

    // Starting speed in normalized units per second; no value is pinned in the design yet.
    static let movementSpeedPerSecond = 0.5
}
