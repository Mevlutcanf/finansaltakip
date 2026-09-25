import XCTest
@testable import MindSpend

final class WeeklyChallengeServiceTests: XCTestCase {
    func testCountsDistinctActiveDaysAcrossAllSources() {
        let start = Date(timeIntervalSince1970: 1_700_000_000) // sabit referans gün
        let day0 = start
        let day1 = start.addingTimeInterval(24 * 3600)
        let day2 = start.addingTimeInterval(2 * 24 * 3600)

        let transactions = [Transaction(amountMinorUnits: 100, date: day0, category: .food, emotion: .neutral)]
        let avoided = [AvoidedPurchase(itemName: "A", amountMinorUnits: 100, createdAt: day1, cooldownExpiresAt: day1, emotion: .fomo)]
        let noSpendDays = [NoSpendDay(date: day2)]

        let status = WeeklyChallengeService.status(
            startDate: start,
            transactions: transactions,
            avoidedPurchases: avoided,
            noSpendDays: noSpendDays,
            now: start.addingTimeInterval(3 * 24 * 3600)
        )

        XCTAssertEqual(status?.activeDays, 3)
        XCTAssertFalse(status?.isCompleted ?? true)
    }

    func testSameDayMultipleActionsCountOnceEach() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let transactions = [
            Transaction(amountMinorUnits: 100, date: start, category: .food, emotion: .neutral),
            Transaction(amountMinorUnits: 200, date: start.addingTimeInterval(3600), category: .food, emotion: .neutral)
        ]

        let status = WeeklyChallengeService.status(
            startDate: start,
            transactions: transactions,
            avoidedPurchases: [],
            noSpendDays: [],
            now: start.addingTimeInterval(3600 * 2)
        )

        XCTAssertEqual(status?.activeDays, 1)
    }

    func testIsCompletedWhenAllSevenDaysAreActive() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let transactions = (0..<7).map { offset in
            Transaction(
                amountMinorUnits: 100,
                date: start.addingTimeInterval(TimeInterval(offset) * 24 * 3600),
                category: .food,
                emotion: .neutral
            )
        }

        let status = WeeklyChallengeService.status(
            startDate: start,
            transactions: transactions,
            avoidedPurchases: [],
            noSpendDays: [],
            now: start.addingTimeInterval(6 * 24 * 3600 + 3600)
        )

        XCTAssertEqual(status?.activeDays, 7)
        XCTAssertTrue(status?.isCompleted ?? false)
    }

    func testReturnsNilAfterSevenDayWindowCloses() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)

        let status = WeeklyChallengeService.status(
            startDate: start,
            transactions: [],
            avoidedPurchases: [],
            noSpendDays: [],
            now: start.addingTimeInterval(8 * 24 * 3600)
        )

        XCTAssertNil(status)
    }

    func testActionsOutsideWindowAreIgnored() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let beforeWindow = start.addingTimeInterval(-3600)
        let transactions = [Transaction(amountMinorUnits: 100, date: beforeWindow, category: .food, emotion: .neutral)]

        let status = WeeklyChallengeService.status(
            startDate: start,
            transactions: transactions,
            avoidedPurchases: [],
            noSpendDays: [],
            now: start.addingTimeInterval(3600)
        )

        XCTAssertEqual(status?.activeDays, 0)
    }
}
