import Testing
@testable import BearChat

@Test(arguments: [
    (x: 0.0, y: 0.0),
    (x: 1.0, y: 1.0),
    (x: 0.25, y: 0.75),
])
func normalizedPositionAcceptsFiniteCoordinatesInRange(x: Double, y: Double) {
    let position = NormalizedPosition(x: x, y: y)

    #expect(position?.x == x)
    #expect(position?.y == y)
}

@Test(arguments: [
    (x: -0.1, y: 0.5),
    (x: 1.1, y: 0.5),
    (x: 0.5, y: -0.1),
    (x: 0.5, y: 1.1),
    (x: .infinity, y: 0.5),
    (x: 0.5, y: -.infinity),
    (x: .nan, y: 0.5),
    (x: 0.5, y: .nan),
])
func normalizedPositionRejectsInvalidCoordinates(x: Double, y: Double) {
    #expect(NormalizedPosition(x: x, y: y) == nil)
}
