import Foundation

/// Cooldown bildirimlerinin zamanlama hesaplarını `UNUserNotificationCenter`'dan
/// bağımsız, saf/deterministik fonksiyonlar olarak tutar — böylece test
/// edilebilir. Gerçek zamanlama `NotificationService` içinde bu değerleri kullanır.
enum CooldownNotificationScheduler {
    static let expiringSoonIdentifierSuffix = "-expiring"
    static let expiredIdentifierSuffix = "-expired"

    static func expiredIdentifier(for item: AvoidedPurchase) -> String {
        item.id.uuidString + expiredIdentifierSuffix
    }

    static func expiringSoonIdentifier(for item: AvoidedPurchase) -> String {
        item.id.uuidString + expiringSoonIdentifierSuffix
    }

    /// Erken uyarının süre dolmadan ne kadar önce geleceği. Çok kısa
    /// cooldown'larda (örn. 15 dk) toplam sürenin yarısını geçmez, böylece
    /// bildirim cooldown başlamadan önceki bir zamana denk gelmez.
    static func leadTime(for item: AvoidedPurchase) -> TimeInterval {
        let totalInterval = item.cooldownExpiresAt.timeIntervalSince(item.cooldownStartedAt)
        guard totalInterval > 0 else { return 0 }
        return min(15 * 60, totalInterval / 2)
    }

    static func expiringSoonFireDate(for item: AvoidedPurchase) -> Date {
        item.cooldownExpiresAt.addingTimeInterval(-leadTime(for: item))
    }

    /// Erken uyarı yalnızca gelecekte (en az 1 saniye sonra) ateşlenecekse
    /// planlanmalı — geçmişte kalan bir tarih için bildirim planlamak
    /// anlamsızdır ve `UNTimeIntervalNotificationTrigger` hata verir.
    static func shouldScheduleExpiringSoon(for item: AvoidedPurchase, now: Date = .now) -> Bool {
        expiringSoonFireDate(for: item).timeIntervalSince(now) > 1
    }

    static func shouldScheduleExpired(for item: AvoidedPurchase, now: Date = .now) -> Bool {
        item.cooldownExpiresAt.timeIntervalSince(now) > 1
    }
}
