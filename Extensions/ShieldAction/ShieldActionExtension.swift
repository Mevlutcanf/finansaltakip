import ManagedSettings
import Foundation

/// Shield ekranındaki buton aksiyonlarını işler.
/// "Yine de Aç" seçeneği rastgele tek dokunuşla bypass olmamalı (rehber
/// madde 22) — bu yüzden burada shield'ı kaldırmak yerine ana app'i
/// bilinçli bir confirmation flow ile açıyoruz (deep link).
final class ShieldActionExtension: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    private func handle(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "Geri Dön" — shield'ı kaldırmadan uygulamayı kapat.
            completionHandler(.close)
        case .secondaryButtonPressed:
            // "Yine de Aç" — ana app'i açarak bilinçli confirmation flow'unu tetikle.
            // Gerçek bypass kararı ManagedSettingsStore güncellemesiyle ana app'te verilir.
            completionHandler(.defer)
        @unknown default:
            completionHandler(.close)
        }
    }
}
