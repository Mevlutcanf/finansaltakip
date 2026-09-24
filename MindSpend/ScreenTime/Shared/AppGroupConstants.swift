import Foundation

/// Ana app ile Shield/DeviceActivity extension'ları arasında paylaşılan
/// App Group tanımı. Gerçek Bundle ID belirlendiğinde `MANUAL_APPLE_SETUP.md`
/// madde 1'deki App Group ile birebir eşleşmelidir.
enum AppGroupConstants {
    static let identifier = "group.com.anpause.app"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}
