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
    private(set) var lastErrorMessage: String?

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
        lastErrorMessage = nil
        do {
            try await center.requestAuthorization(for: .individual)
            refreshStatus()
            if status != .approved {
                // Sistem hata fırlatmadı ama onay da vermedi; bu genellikle
                // cihaz/hesap Screen Time'ı desteklemiyor demektir.
                lastErrorMessage = "İzin isteği tamamlanamadı. Cihazının Ekran Süresi özelliğini desteklediğinden emin ol."
            }
        } catch {
            refreshStatus()
            lastErrorMessage = "Bu özellik şu anda kullanılamıyor (\(error.localizedDescription)). Uygulama Apple'ın Ekran Süresi iznini henüz alamadı — bu, geliştiricinin tamamlaması gereken ayrı bir Apple onay süreci."
        }
    }
}
