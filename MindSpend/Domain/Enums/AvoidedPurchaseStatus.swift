import Foundation

enum AvoidedPurchaseStatus: String, Codable {
    case pending
    case avoided
    case purchased
}

enum ShieldSessionStatus: String, Codable {
    case active
    case expired
    case cancelled
}
