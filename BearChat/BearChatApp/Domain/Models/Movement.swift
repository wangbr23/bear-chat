enum MovementRequestState: Sendable {
    case idle
    case inFlight
    case pendingLatest
    case rejected
}

struct NormalizedPosition: Sendable {
    let x: Double
    let y: Double

    init?(x: Double, y: Double) {
        guard x.isFinite, y.isFinite,
              (0...1).contains(x), (0...1).contains(y) else {
            return nil
        }

        self.x = x
        self.y = y
    }
}

struct MovementState: Sendable {
    let confirmedDestination: NormalizedPosition
    let displayedPosition: NormalizedPosition
    let optimisticDestination: NormalizedPosition?
    let latestRevision: Int64
    let requestState: MovementRequestState
}
