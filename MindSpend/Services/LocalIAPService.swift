import Foundation

/// RevenueCat henüz yapılandırılmadan önce veya preview/test ortamlarında
/// kullanılan varsayılan implementasyon. Kullanıcı her zaman `free` kalır;
/// gerçek satın alma yapılmaz.
final class LocalIAPService: IAPServiceProtocol {
    func fetchOfferings() async throws -> [PremiumOffering] { [] }

    func purchase(offeringId: String) async throws -> PremiumState { .free }

    func restorePurchases() async throws -> PremiumState { .free }

    func currentPremiumState() async -> PremiumState { .free }
}
