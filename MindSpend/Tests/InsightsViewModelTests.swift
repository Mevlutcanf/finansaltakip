import XCTest
@testable import MindSpend

private final class FakeTransactionRepository: TransactionRepositoryProtocol {
    var items: [Transaction] = []

    func fetchAll() throws -> [Transaction] { items }
    func fetch(from startDate: Date, to endDate: Date) throws -> [Transaction] {
        items.filter { $0.date >= startDate && $0.date <= endDate }
    }
    func add(_ transaction: Transaction) throws { items.append(transaction) }
    func delete(_ transaction: Transaction) throws { items.removeAll { $0.id == transaction.id } }
}

private final class FakeAvoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol {
    var items: [AvoidedPurchase] = []

    func fetchAll() throws -> [AvoidedPurchase] { items }
    func fetchPending() throws -> [AvoidedPurchase] { items.filter { $0.status == .pending } }
    func add(_ item: AvoidedPurchase) throws { items.append(item) }
    func update(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) throws { item.status = status }
    func delete(_ item: AvoidedPurchase) throws { items.removeAll { $0.id == item.id } }
}

final class InsightsViewModelTests: XCTestCase {
    func testEmotionBreakdownAggregatesAmountsPerEmotion() {
        let transactionRepo = FakeTransactionRepository()
        transactionRepo.items = [
            Transaction(amountMinorUnits: 1000, category: .food, emotion: .stress),
            Transaction(amountMinorUnits: 500, category: .food, emotion: .stress),
            Transaction(amountMinorUnits: 2000, category: .fashion, emotion: .boredom)
        ]

        let viewModel = InsightsViewModel(
            transactionRepository: transactionRepo,
            avoidedPurchaseRepository: FakeAvoidedPurchaseRepository()
        )
        viewModel.refresh()

        let stress = viewModel.emotionBreakdown.first { $0.emotion == .stress }
        XCTAssertEqual(stress?.total.minorUnits, 1500)
        XCTAssertEqual(viewModel.emotionBreakdown.first?.emotion, .boredom, "En yüksek tutar en üstte sıralanmalı")
    }

    func testTriggerBreakdownAggregatesAmountsAndIgnoresNilTrigger() {
        let transactionRepo = FakeTransactionRepository()
        transactionRepo.items = [
            Transaction(amountMinorUnits: 1200, category: .food, emotion: .neutral, trigger: .discount),
            Transaction(amountMinorUnits: 300, category: .food, emotion: .neutral, trigger: nil)
        ]

        let viewModel = InsightsViewModel(
            transactionRepository: transactionRepo,
            avoidedPurchaseRepository: FakeAvoidedPurchaseRepository()
        )
        viewModel.refresh()

        XCTAssertEqual(viewModel.triggerBreakdown.count, 1)
        XCTAssertEqual(viewModel.triggerBreakdown.first?.trigger, .discount)
        XCTAssertEqual(viewModel.triggerBreakdown.first?.total.minorUnits, 1200)
    }

    func testAvoidedTotalOnlyCountsAvoidedStatus() {
        let avoidedRepo = FakeAvoidedPurchaseRepository()
        avoidedRepo.items = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 1000, cooldownExpiresAt: .now, emotion: .fomo, status: .avoided),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 5000, cooldownExpiresAt: .now, emotion: .fomo, status: .purchased)
        ]

        let viewModel = InsightsViewModel(
            transactionRepository: FakeTransactionRepository(),
            avoidedPurchaseRepository: avoidedRepo
        )
        viewModel.refresh()

        XCTAssertEqual(viewModel.avoidedCount, 1)
        XCTAssertEqual(viewModel.avoidedTotal.minorUnits, 1000)
    }

    func testBehaviorCycleReflectsRealStageCountsFromAvoidedPurchases() {
        let items = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .pending),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .avoided),
            AvoidedPurchase(itemName: "C", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .purchased)
        ]

        let cycle = InsightsViewModel.makeBehaviorCycle(from: items)

        XCTAssertEqual(cycle.first { $0.title == "Dürtü Kaydedildi" }?.count, 3)
        XCTAssertEqual(cycle.first { $0.title == "Cooldown Tamamlandı" }?.count, 2, "pending hariç, avoided+purchased")
        XCTAssertEqual(cycle.first { $0.title == "Vazgeçildi" }?.count, 1)
    }

    func testBehaviorCycleIsAllZeroWhenNoAvoidedPurchasesExist() {
        let cycle = InsightsViewModel.makeBehaviorCycle(from: [])

        XCTAssertTrue(cycle.allSatisfy { $0.count == 0 })
    }
}
