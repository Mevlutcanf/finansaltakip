import XCTest
@testable import MindSpend

final class LocalRoastServiceTests: XCTestCase {
    func testGeneratesTextForEmptySummary() async {
        let service = LocalRoastService()
        let summary = RoastInputSummary(
            topCategory: nil,
            topTrigger: nil,
            triggerOccurrenceCount: 0,
            avoidedCount: 0,
            avoidedTotal: .zero,
            totalSpend: .zero
        )
        let result = await service.generateRoast(summary: summary, tone: .balanced)
        XCTAssertFalse(result.isEmpty)
    }

    func testIncludesCategoryWhenPresent() async {
        let service = LocalRoastService()
        let summary = RoastInputSummary(
            topCategory: .electronics,
            topTrigger: .discount,
            triggerOccurrenceCount: 3,
            avoidedCount: 2,
            avoidedTotal: Money(minorUnits: 5000),
            totalSpend: Money(minorUnits: 10000)
        )
        let result = await service.generateRoast(summary: summary, tone: .mild)
        XCTAssertTrue(result.contains("Elektronik"))
    }
}
