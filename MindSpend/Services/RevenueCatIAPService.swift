import Foundation
import RevenueCat

/// RevenueCat'e bağımlı tek katman. UI ve geri kalan uygulama bu sınıfa
/// değil `IAPServiceProtocol`'e bağımlıdır (rehber madde 26).
///
/// RevenueCat public SDK key'i `MANUAL_APPLE_SETUP.md` madde 4'te
/// tanımlanan dashboard kurulumundan sonra `configure()` içine eklenmelidir.
/// Key'i doğrudan kaynak koduna gömmek yerine bir build ayarı / secret
/// üzerinden enjekte etmek tercih edilmelidir.
final class RevenueCatIAPService: IAPServiceProtocol {
    static func configure(apiKey: String) {
        Purchases.configure(withAPIKey: apiKey)
    }

    func fetchOfferings() async throws -> [PremiumOffering] {
        let offerings = try await Purchases.shared.offerings()
        guard let current = offerings.current else { return [] }
        return current.availablePackages.map { package in
            PremiumOffering(
                id: package.identifier,
                title: package.storeProduct.localizedTitle,
                priceString: package.storeProduct.localizedPriceString,
                period: package.storeProduct.subscriptionPeriod?.periodTitle ?? ""
            )
        }
    }

    func purchase(offeringId: String) async throws -> PremiumState {
        let offerings = try await Purchases.shared.offerings()
        guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == offeringId }) else {
            return .free
        }
        let result = try await Purchases.shared.purchase(package: package)
        return Self.premiumState(from: result.customerInfo)
    }

    func restorePurchases() async throws -> PremiumState {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return Self.premiumState(from: customerInfo)
    }

    func currentPremiumState() async -> PremiumState {
        guard let customerInfo = try? await Purchases.shared.customerInfo() else { return .free }
        return Self.premiumState(from: customerInfo)
    }

    private static func premiumState(from customerInfo: CustomerInfo) -> PremiumState {
        guard let entitlement = customerInfo.entitlements["premium"], entitlement.isActive else {
            return .free
        }
        return .premium(expiresAt: entitlement.expirationDate)
    }
}

private extension SubscriptionPeriod {
    var periodTitle: String {
        switch unit {
        case .month: return "aylık"
        case .year: return "yıllık"
        case .week: return "haftalık"
        case .day: return "günlük"
        @unknown default: return ""
        }
    }
}
