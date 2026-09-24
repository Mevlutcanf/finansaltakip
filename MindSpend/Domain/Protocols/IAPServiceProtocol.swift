import Foundation

struct PremiumOffering: Identifiable {
    let id: String
    let title: String
    let priceString: String
    let period: String
}

protocol IAPServiceProtocol {
    func fetchOfferings() async throws -> [PremiumOffering]
    func purchase(offeringId: String) async throws -> PremiumState
    func restorePurchases() async throws -> PremiumState
    func currentPremiumState() async -> PremiumState
}
