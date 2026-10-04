enum RoomConnectionState: Sendable {
    case cached
    case catchingUp
    case subscribing
    case live
    case reconnecting
    case accessRevoked
    case unavailable
}
