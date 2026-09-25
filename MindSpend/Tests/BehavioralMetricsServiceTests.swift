import XCTest
@testable import MindSpend

final class BehavioralMetricsServiceTests: XCTestCase {
    func testImpulseCountSumsTransactionsAndAvoidedPurchases() {
        let transactions = [
            Transaction(amountMinorUnits: 1000, category: .food, emotion: .neutral),
            Transaction(amountMinorUnits: 2000, category: .fashion, emotion: .stress)
        ]
        let avoided = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .fomo)
        ]

        let metrics = BehavioralMetricsService.compute(transactions: transactions, avoidedPurchases: avoided)

        XCTAssertEqual(metrics.impulseCount, 3)
        XCTAssertEqual(metrics.cooldownsStarted, 1)
    }

    func testAvoidedCountOnlyCountsAvoidedStatus() {
        let avoided = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .fomo, status: .avoided),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 700, cooldownExpiresAt: .now, emotion: .stress, status: .purchased),
            AvoidedPurchase(itemName: "C", amountMinorUnits: 900, cooldownExpiresAt: .now, emotion: .boredom, status: .pending)
        ]

        let metrics = BehavioralMetricsService.compute(transactions: [], avoidedPurchases: avoided)

        XCTAssertEqual(metrics.avoidedCount, 1)
        XCTAssertEqual(metrics.cooldownsStarted, 3)
    }

    func testTopEmotionIsMostFrequentAcrossBothSources() {
        let transactions = [
            Transaction(amountMinorUnits: 1000, category: .food, emotion: .stress),
            Transaction(amountMinorUnits: 1000, category: .food, emotion: .stress)
        ]
        let avoided = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .stress),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .boredom)
        ]

        let metrics = BehavioralMetricsService.compute(transactions: transactions, avoidedPurchases: avoided)

        XCTAssertEqual(metrics.topEmotion, .stress)
    }

    func testTopTriggerIgnoresNilTriggers() {
        let avoided = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .fomo, trigger: .discount),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .fomo, trigger: .discount),
            AvoidedPurchase(itemName: "C", amountMinorUnits: 500, cooldownExpiresAt: .now, emotion: .fomo, trigger: nil)
        ]

        let metrics = BehavioralMetricsService.compute(transactions: [], avoidedPurchases: avoided)

        XCTAssertEqual(metrics.topTrigger, .discount)
    }

    func testEmptyInputReturnsNilTopValues() {
        let metrics = BehavioralMetricsService.compute(transactions: [], avoidedPurchases: [])

        XCTAssertEqual(metrics.impulseCount, 0)
        XCTAssertNil(metrics.topEmotion)
        XCTAssertNil(metrics.topTrigger)
    }
}
