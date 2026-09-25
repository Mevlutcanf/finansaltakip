import XCTest
@testable import MindSpend

final class RecurringItemsSummaryServiceTests: XCTestCase {
    func testYearlyExpenseIsNormalizedToMonthlyEquivalent() {
        let items = [
            RecurringItem(name: "iCloud", amountMinorUnits: 1200_00, kind: .expense, cycle: .yearly)
        ]

        let summary = RecurringItemsSummaryService.summary(from: items)

        XCTAssertEqual(summary.monthlyExpenses.minorUnits, 100_00)
    }

    func testInactiveItemsAreExcludedFromSummary() {
        let items = [
            RecurringItem(name: "Netflix", amountMinorUnits: 200_00, kind: .expense, cycle: .monthly, isActive: false)
        ]

        let summary = RecurringItemsSummaryService.summary(from: items)

        XCTAssertEqual(summary.monthlyExpenses.minorUnits, 0)
    }

    func testNetIsIncomeMinusExpenses() {
        let items = [
            RecurringItem(name: "Maaş", amountMinorUnits: 30000_00, kind: .income, cycle: .monthly),
            RecurringItem(name: "Kira", amountMinorUnits: 10000_00, kind: .expense, cycle: .monthly),
            RecurringItem(name: "Spotify", amountMinorUnits: 60_00, kind: .expense, cycle: .monthly)
        ]

        let summary = RecurringItemsSummaryService.summary(from: items)

        XCTAssertEqual(summary.monthlyIncome.minorUnits, 30000_00)
        XCTAssertEqual(summary.monthlyExpenses.minorUnits, 10060_00)
        XCTAssertEqual(summary.monthlyNet.minorUnits, 19940_00)
    }

    func testEmptyItemsProduceZeroSummary() {
        let summary = RecurringItemsSummaryService.summary(from: [])

        XCTAssertEqual(summary.monthlyExpenses.minorUnits, 0)
        XCTAssertEqual(summary.monthlyIncome.minorUnits, 0)
        XCTAssertEqual(summary.monthlyNet.minorUnits, 0)
    }
}
