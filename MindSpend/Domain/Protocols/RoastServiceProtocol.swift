import Foundation

enum RoastTone: String, CaseIterable, Identifiable {
    case mild
    case balanced
    case savage

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mild: return "Yumuşak"
        case .balanced: return "Dengeli"
        case .savage: return "Sert"
        }
    }
}

struct RoastInputSummary {
    let topCategory: SpendingCategory?
    let topTrigger: SpendingTrigger?
    let triggerOccurrenceCount: Int
    let avoidedCount: Int
    let avoidedTotal: Money
    let totalSpend: Money
}

/// AI sağlayıcısı kodun içine sabitlenmez (rehber madde 8). Yalnızca
/// aggregate özet gönderilir; işlem listesi veya not gönderilmez.
protocol RoastServiceProtocol {
    func generateRoast(summary: RoastInputSummary, tone: RoastTone) async -> String
}
