import XCTest
@testable import MindSpend

final class MoneyTests: XCTestCase {
    func testAdditionSameCurrency() {
        let a = Money(minorUnits: 1000, currencyCode: "TRY")
        let b = Money(minorUnits: 250, currencyCode: "TRY")
        XCTAssertEqual((a + b).minorUnits, 1250)
    }

    func testComparison() {
        let low = Money(minorUnits: 100)
        let high = Money(minorUnits: 200)
        XCTAssertTrue(low < high)
    }

    func testZero() {
        XCTAssertEqual(Money.zero.minorUnits, 0)
    }
}
