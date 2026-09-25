import Foundation

enum RecurringItemKind: String, Codable, CaseIterable, Identifiable {
    case expense
    case income

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .expense: return NSLocalizedString("recurring.kind.expense", value: "Sürekli Gider", comment: "Recurring item kind: expense")
        case .income: return NSLocalizedString("recurring.kind.income", value: "Sürekli Gelir", comment: "Recurring item kind: income")
        }
    }

    var symbolName: String {
        switch self {
        case .expense: return "arrow.down.circle"
        case .income: return "arrow.up.circle"
        }
    }
}

enum BillingCycle: String, Codable, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monthly: return NSLocalizedString("recurring.cycle.monthly", value: "Aylık", comment: "Billing cycle: monthly")
        case .yearly: return NSLocalizedString("recurring.cycle.yearly", value: "Yıllık", comment: "Billing cycle: yearly")
        }
    }

    /// Aylık eşdeğer tutara çevirmek için bölünecek ay sayısı.
    var monthsInCycle: Int {
        switch self {
        case .monthly: return 1
        case .yearly: return 12
        }
    }
}
