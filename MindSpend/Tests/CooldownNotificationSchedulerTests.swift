import XCTest
@testable import MindSpend

final class CooldownNotificationSchedulerTests: XCTestCase {
    func testLeadTimeIsCappedAtFifteenMinutesForLongCooldowns() {
        let start = Date(timeIntervalSince1970: 0)
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: start,
            cooldownExpiresAt: start.addingTimeInterval(24 * 3600),
            emotion: .fomo
        )

        XCTAssertEqual(CooldownNotificationScheduler.leadTime(for: item), 15 * 60)
    }

    func testLeadTimeIsHalfDurationForShortCooldowns() {
        let start = Date(timeIntervalSince1970: 0)
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: start,
            cooldownExpiresAt: start.addingTimeInterval(10 * 60), // 10 dk toplam cooldown
            emotion: .fomo
        )

        XCTAssertEqual(CooldownNotificationScheduler.leadTime(for: item), 5 * 60)
    }

    func testExpiringSoonFireDateIsBeforeExpiration() {
        let start = Date(timeIntervalSince1970: 0)
        let expires = start.addingTimeInterval(3600)
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: start,
            cooldownExpiresAt: expires,
            emotion: .fomo
        )

        let fireDate = CooldownNotificationScheduler.expiringSoonFireDate(for: item)

        XCTAssertLessThan(fireDate, expires)
        XCTAssertEqual(expires.timeIntervalSince(fireDate), 15 * 60)
    }

    func testShouldNotScheduleExpiringSoonWhenFireDateAlreadyPassed() {
        let now = Date()
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: now.addingTimeInterval(-3600),
            cooldownExpiresAt: now.addingTimeInterval(-10), // zaten bitmiş
            emotion: .fomo
        )

        XCTAssertFalse(CooldownNotificationScheduler.shouldScheduleExpiringSoon(for: item, now: now))
    }

    func testShouldScheduleExpiringSoonWhenFireDateIsInFuture() {
        let now = Date()
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: now,
            cooldownExpiresAt: now.addingTimeInterval(3600),
            emotion: .fomo
        )

        XCTAssertTrue(CooldownNotificationScheduler.shouldScheduleExpiringSoon(for: item, now: now))
    }

    func testShouldNotScheduleExpiredNotificationForAlreadyExpiredCooldown() {
        let now = Date()
        let item = AvoidedPurchase(
            itemName: "A",
            amountMinorUnits: 100,
            cooldownStartedAt: now.addingTimeInterval(-3600),
            cooldownExpiresAt: now.addingTimeInterval(-10),
            emotion: .fomo
        )

        XCTAssertFalse(CooldownNotificationScheduler.shouldScheduleExpired(for: item, now: now))
    }

    func testIdentifiersAreStablePerItemAndDistinctPerNotificationType() {
        let item = AvoidedPurchase(itemName: "A", amountMinorUnits: 100, cooldownExpiresAt: .now, emotion: .fomo)

        let expiring = CooldownNotificationScheduler.expiringSoonIdentifier(for: item)
        let expired = CooldownNotificationScheduler.expiredIdentifier(for: item)

        XCTAssertNotEqual(expiring, expired)
        XCTAssertTrue(expiring.hasPrefix(item.id.uuidString))
        XCTAssertTrue(expired.hasPrefix(item.id.uuidString))
        // Aynı item için ikinci çağrı da aynı identifier'ı üretmeli (duplicate'siz replace davranışı için).
        XCTAssertEqual(expiring, CooldownNotificationScheduler.expiringSoonIdentifier(for: item))
    }
}
