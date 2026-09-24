import Foundation

enum SpendingCategory: String, Codable, CaseIterable, Identifiable {
    case electronics
    case fashion
    case food
    case home
    case gaming
    case beauty
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .electronics: return NSLocalizedString("category.electronics", value: "Elektronik", comment: "Category: electronics")
        case .fashion: return NSLocalizedString("category.fashion", value: "Moda", comment: "Category: fashion")
        case .food: return NSLocalizedString("category.food", value: "Yiyecek", comment: "Category: food")
        case .home: return NSLocalizedString("category.home", value: "Ev", comment: "Category: home")
        case .gaming: return NSLocalizedString("category.gaming", value: "Oyun", comment: "Category: gaming")
        case .beauty: return NSLocalizedString("category.beauty", value: "Güzellik", comment: "Category: beauty")
        case .other: return NSLocalizedString("category.other", value: "Diğer", comment: "Category: other")
        }
    }

    var symbolName: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .fashion: return "tshirt"
        case .food: return "fork.knife"
        case .home: return "house"
        case .gaming: return "gamecontroller"
        case .beauty: return "sparkle"
        case .other: return "square.grid.2x2"
        }
    }
}
