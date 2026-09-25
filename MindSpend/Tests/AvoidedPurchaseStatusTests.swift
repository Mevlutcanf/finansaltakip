import XCTest
@testable import MindSpend

private final class FakeAvoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol {
    var items: [AvoidedPurchase] = []

    func fetchAll() throws -> [AvoidedPurchase] { items }
    func fetchPending() throws -> [AvoidedPurchase] { items.filter { $0.status == .pending } }
    func add(_ item: AvoidedPurchase) throws { items.append(item) }
    func update(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) throws { item.status = status }
    func delete(_ item: AvoidedPurchase) throws { items.removeAll { $0.id == item.id } }
}

final class AvoidedPurchaseStatusTests: XCTestCase {
    func testFetchPendingExcludesResolvedItems() throws {
        let repo = FakeAvoidedPurchaseRepository()
        repo.items = [
            AvoidedPurchase(itemName: "Bekleyen", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .pending),
            AvoidedPurchase(itemName: "Vazgeçilen", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .avoided),
            AvoidedPurchase(itemName: "Alınan", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .purchased)
        ]

        let pending = try repo.fetchPending()

        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.itemName, "Bekleyen")
    }

    func testResolvingToAvoidedUpdatesStatusAndExcludesFromPending() throws {
        let repo = FakeAvoidedPurchaseRepository()
        let item = AvoidedPurchase(itemName: "A", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .pending)
        repo.items = [item]

        try repo.update(item, status: .avoided)

        XCTAssertEqual(item.status, .avoided)
        XCTAssertTrue(try repo.fetchPending().isEmpty)
    }

    func testResolvingToPurchasedIsDistinctFromAvoided() throws {
        let repo = FakeAvoidedPurchaseRepository()
        let item = AvoidedPurchase(itemName: "A", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo, status: .pending)
        repo.items = [item]

        try repo.update(item, status: .purchased)

        XCTAssertEqual(item.status, .purchased)
        XCTAssertNotEqual(item.status, .avoided)
    }

    func testIsCooldownActiveOnlyTrueWhilePendingAndBeforeExpiration() {
        let stillPending = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownExpiresAt: Date().addingTimeInterval(3600),
            emotion: .fomo,
            status: .pending
        )
        XCTAssertTrue(stillPending.isCooldownActive)

        let expiredButUnresolved = AvoidedPurchase(
            itemName: "B",
            amountMinorUnits: 100,
            cooldownExpiresAt: Date().addingTimeInterval(-3600),
            emotion: .fomo,
            status: .pending
        )
        XCTAssertFalse(expiredButUnresolved.isCooldownActive)

        let resolvedButNotExpired = AvoidedPurchase(
            itemName: "C",
            amountMinorUnits: 100,
            cooldownExpiresAt: Date().addingTimeInterval(3600),
            emotion: .fomo,
            status: .avoided
        )
        XCTAssertFalse(resolvedButNotExpired.isCooldownActive)
    }
}
