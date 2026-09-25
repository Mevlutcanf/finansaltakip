import XCTest
@testable import MindSpend

final class CooldownDurationTests: XCTestCase {
    func testExpirationDateAddsCorrectMinutes() {
        let start = Date(timeIntervalSince1970: 0)
        let expiration = CooldownDuration.oneHour.expirationDate(from: start)
        XCTAssertEqual(expiration.timeIntervalSince(start), 3600)
    }

    func testAllDurationsProduceLaterExpiration() {
        let start = Date.now
        for duration in CooldownDuration.allCases {
            XCTAssertGreaterThan(duration.expirationDate(from: start), start)
        }
    }
}
