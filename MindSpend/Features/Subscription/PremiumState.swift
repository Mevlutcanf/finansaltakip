import Foundation

enum PremiumState: Equatable {
    case free
    case premium(expiresAt: Date?)

    var isPremium: Bool {
        if case .premium = self { return true }
        return false
    }
}
