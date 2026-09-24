import XCTest
@testable import MindSpend

private final class FakeNoSpendDayRepository: NoSpendDayRepositoryProtocol {
    var days: [NoSpendDay] = []

    func fetchAll() throws -> [NoSpendDay] { days }
    func confirmToday() throws { days.append(NoSpendDay()) }
    func isTodayConfirmed() throws -> Bool {
        days.contains { Calendar.current.isDateInToday($0.date) }
    }
}

private final class FakeAvoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol {
    var items: [AvoidedPurchase] = []

    func fetchAll() throws -> [AvoidedPurchase] { items }
    func fetchPending() throws -> [AvoidedPurchase] { items.filter { $0.status == .pending } }
    func add(_ item: AvoidedPurchase) throws { items.append(item) }
    func update(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) throws { item.status = status }
    func delete(_ item: AvoidedPurchase) throws { items.removeAll { $0.id == item.id } }
}

final class StreakServiceTests: XCTestCase {
    func testNoSpendStreakCountsConsecutiveDaysFromToday() {
        let noSpendRepo = FakeNoSpendDayRepository()
        let calendar = Calendar.current
        noSpendRepo.days = [
            NoSpendDay(date: .now),
            NoSpendDay(date: calendar.date(byAdding: .day, value: -1, to: .now)!),
            NoSpendDay(date: calendar.date(byAdding: .day, value: -2, to: .now)!)
        ]

        let service = StreakService(
            noSpendDayRepository: noSpendRepo,
            avoidedPurchaseRepository: FakeAvoidedPurchaseRepository()
        )

        XCTAssertEqual(service.summary().noSpendDayStreak, 3)
    }

    func testStreakBreaksOnGap() {
        let noSpendRepo = FakeNoSpendDayRepository()
        let calendar = Calendar.current
        noSpendRepo.days = [
            NoSpendDay(date: .now),
            NoSpendDay(date: calendar.date(byAdding: .day, value: -3, to: .now)!)
        ]

        let service = StreakService(
            noSpendDayRepository: noSpendRepo,
            avoidedPurchaseRepository: FakeAvoidedPurchaseRepository()
        )

        XCTAssertEqual(service.summary().noSpendDayStreak, 1)
    }

    func testStreakIsZeroWhenNoRecentConfirmation() {
        let noSpendRepo = FakeNoSpendDayRepository()
        noSpendRepo.days = [NoSpendDay(date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!)]

        let service = StreakService(
            noSpendDayRepository: noSpendRepo,
            avoidedPurchaseRepository: FakeAvoidedPurchaseRepository()
        )

        XCTAssertEqual(service.summary().noSpendDayStreak, 0)
    }

    func testCooldownStreakCountsThisWeeksAvoidedAttempts() {
        let avoidedRepo = FakeAvoidedPurchaseRepository()
        avoidedRepo.items = [
            AvoidedPurchase(itemName: "A", amountMinorUnits: 1000, cooldownExpiresAt: .now, emotion: .fomo),
            AvoidedPurchase(itemName: "B", amountMinorUnits: 2000, cooldownExpiresAt: .now, emotion: .stress)
        ]

        let service = StreakService(
            noSpendDayRepository: FakeNoSpendDayRepository(),
            avoidedPurchaseRepository: avoidedRepo
        )

        XCTAssertEqual(service.summary().cooldownStreakThisWeek, 2)
    }
}
