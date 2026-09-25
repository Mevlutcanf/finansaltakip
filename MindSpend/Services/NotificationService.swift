import Foundation
import UserNotifications

/// V1: yalnızca local notification. Cooldown yaklaşırken/bitişinde ve
/// haftalık reflection için kullanılır. İzin verilmemişse `add` sessizce
/// hiçbir şey yapmaz — uygulama çalışmaya devam eder.
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Cooldown süresi dolmadan kısa bir süre önce erken uyarı gönderir.
    /// Aynı `item` için tekrar çağrılırsa aynı identifier'ı kullandığından
    /// (`UNUserNotificationCenter.add` var olan isteği değiştirir) duplicate
    /// bildirim oluşmaz.
    func scheduleCooldownExpiringSoon(for item: AvoidedPurchase) {
        guard CooldownNotificationScheduler.shouldScheduleExpiringSoon(for: item) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cooldown yaklaşıyor"
        content.body = "\(item.itemName) için karar anı yaklaşıyor."
        content.sound = .default

        let interval = CooldownNotificationScheduler.expiringSoonFireDate(for: item).timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        let request = UNNotificationRequest(
            identifier: CooldownNotificationScheduler.expiringSoonIdentifier(for: item),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleCooldownExpired(for item: AvoidedPurchase) {
        guard CooldownNotificationScheduler.shouldScheduleExpired(for: item) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cooldown süresi doldu"
        content.body = "\(item.itemName) için hâlâ istiyor musun?"
        content.sound = .default

        let interval = max(item.cooldownExpiresAt.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: CooldownNotificationScheduler.expiredIdentifier(for: item),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelCooldownNotification(for item: AvoidedPurchase) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            CooldownNotificationScheduler.expiringSoonIdentifier(for: item),
            CooldownNotificationScheduler.expiredIdentifier(for: item)
        ])
    }

    /// Rehber madde 33 — spam olmayacak şekilde, haftada bir kez.
    func scheduleWeeklyReflection() {
        let content = UNMutableNotificationContent()
        content.title = "Haftalık Farkındalık"
        content.body = "Bu hafta erteleyip vazgeçtiğin alışverişlere bir bak."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Pazartesi
        dateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-reflection", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelWeeklyReflection() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-reflection"])
    }
}
