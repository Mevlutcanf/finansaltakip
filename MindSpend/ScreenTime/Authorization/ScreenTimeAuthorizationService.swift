import Foundation
import FamilyControls
import Observation

/// Family Controls yetkilendirmesini `individual` senaryosu için sarmalar
/// (rehber madde 10 — parent/child akışı MindSpend'in hedefi değildir).
///
/// NOT: `AuthorizationCenter` API yüzeyi Apple tarafından iOS sürümleri
/// arasında değişebilir. Bu servis uygulama sırasında güncel Apple
/// dokümantasyonuyla tekrar doğrulanmalıdır (bkz. rehber madde 49).
@Observable
final class ScreenTimeAuthorizationService {
    private(set) var status: ScreenTimeAuthorizationStatus = .notDetermined

    private let center = AuthorizationCenter.shared

    init() {
        refreshStatus()
    }

    func refreshStatus() {
        switch center.authorizationStatus {
        case .notDetermined:
            status = .notDetermined
        case .approved:
            status = .approved
        case .denied:
            status = .denied
        @unknown default:
            status = .notDetermined
        }
    }

    @MainActor
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            refreshStatus()
        } catch {
            // Kullanıcı reddetti veya sistem hatası; UI "denied" durumunu göstermeli.
            refreshStatus()
        }
    }
}
