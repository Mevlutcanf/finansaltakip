import Foundation

enum CooldownDuration: Int, Codable, CaseIterable, Identifiable {
    case fifteenMinutes = 15
    case oneHour = 60
    case fourHours = 240
    case twentyFourHours = 1440

    var id: Int { rawValue }

    var minutes: Int { rawValue }

    var displayName: String {
        switch self {
        case .fifteenMinutes: return NSLocalizedString("cooldown.15m", value: "15 dakika", comment: "Cooldown 15 minutes")
        case .oneHour: return NSLocalizedString("cooldown.1h", value: "1 saat", comment: "Cooldown 1 hour")
        case .fourHours: return NSLocalizedString("cooldown.4h", value: "4 saat", comment: "Cooldown 4 hours")
        case .twentyFourHours: return NSLocalizedString("cooldown.24h", value: "24 saat", comment: "Cooldown 24 hours")
        }
    }

    func expirationDate(from start: Date = .now) -> Date {
        start.addingTimeInterval(TimeInterval(minutes * 60))
    }
}
