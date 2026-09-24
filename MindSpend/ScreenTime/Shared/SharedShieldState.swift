import Foundation

/// Extension'ların (ShieldAction, ShieldConfiguration) SwiftData'ya bağımlı
/// olmadan okuyabildiği hafif durum (rehber madde 12). Ana app her
/// ShieldSession değişikliğinde bu değeri günceller; extension'lar sadece
/// okur, App Group `UserDefaults` üzerinden.
struct SharedShieldState: Codable {
    var activeSessionId: UUID?
    var ruleName: String?
    var expiresAt: Date?
    var reasonMessage: String?

    static let storageKey = "com.mindspend.sharedShieldState"

    static var current: SharedShieldState {
        get {
            guard let data = AppGroupConstants.sharedDefaults.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode(SharedShieldState.self, from: data) else {
                return SharedShieldState()
            }
            return decoded
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            AppGroupConstants.sharedDefaults.set(data, forKey: storageKey)
        }
    }

    var isActive: Bool {
        guard let expiresAt else { return false }
        return activeSessionId != nil && expiresAt > .now
    }
}
