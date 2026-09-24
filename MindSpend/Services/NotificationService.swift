import Foundation
import UserNotifications

/// V1: yalnızca local notification. Cooldown bitişi ve haftalık reflection için kullanılır.
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleCooldownExpired(for item: AvoidedPurchase) {
        let content = UNMutableNotificationContent()
        content.title = "Cooldown süresi doldu"
        content.body = "\(item.itemName) için hâlâ istiyor musun?"
        content.sound = .default

        let interval = max(item.cooldownExpiresAt.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelCooldownNotification(for item: AvoidedPurchase) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
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
}
