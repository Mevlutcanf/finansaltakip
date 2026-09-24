import Foundation

enum SpendingTrigger: String, Codable, CaseIterable, Identifiable {
    case need
    case reward
    case discount
    case habit
    case social
    case convenience

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .need: return NSLocalizedString("trigger.need", value: "Gerçek ihtiyaç", comment: "Trigger: need")
        case .reward: return NSLocalizedString("trigger.reward", value: "Kendimi ödüllendirme", comment: "Trigger: reward")
        case .discount: return NSLocalizedString("trigger.discount", value: "İndirim", comment: "Trigger: discount")
        case .habit: return NSLocalizedString("trigger.habit", value: "Alışkanlık", comment: "Trigger: habit")
        case .social: return NSLocalizedString("trigger.social", value: "Sosyal etki", comment: "Trigger: social")
        case .convenience: return NSLocalizedString("trigger.convenience", value: "Kolaylık", comment: "Trigger: convenience")
        }
    }

    var symbolName: String {
        switch self {
        case .need: return "checkmark.seal"
        case .reward: return "gift"
        case .discount: return "tag"
        case .habit: return "repeat"
        case .social: return "person.2"
        case .convenience: return "hand.tap"
        }
    }
}
