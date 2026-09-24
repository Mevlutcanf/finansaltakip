import Foundation
import Observation

@Observable
final class SubscriptionManager {
    private(set) var state: PremiumState = .free
    private(set) var offerings: [PremiumOffering] = []
    private(set) var isLoading = false
    private(set) var lastErrorMessage: String?

    private let service: IAPServiceProtocol

    init(service: IAPServiceProtocol = LocalIAPService()) {
        self.service = service
    }

    func refresh() async {
        state = await service.currentPremiumState()
    }

    func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            offerings = try await service.fetchOfferings()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Paketler yüklenemedi. Lütfen tekrar dene."
        }
    }

    func purchase(offeringId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            state = try await service.purchase(offeringId: offeringId)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Satın alma tamamlanamadı."
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            state = try await service.restorePurchases()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Geri yükleme başarısız oldu."
        }
    }
}
