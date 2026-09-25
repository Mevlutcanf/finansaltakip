import Foundation

/// Onboarding tamamlandığında bir kez kaydedilen tarih — "İlk 7 Gün"
/// meydan okumasının başlangıcını belirlemek için kullanılır.
enum FirstLaunchTracker {
    private static let key = "com.anpause.firstLaunchDate"

    static var firstLaunchDate: Date? {
        let stored = UserDefaults.standard.double(forKey: key)
        return stored > 0 ? Date(timeIntervalSince1970: stored) : nil
    }

    static func recordFirstLaunchIfNeeded(now: Date = .now) {
        guard UserDefaults.standard.double(forKey: key) == 0 else { return }
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: key)
    }
}
