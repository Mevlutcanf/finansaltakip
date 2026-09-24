import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Shield ekranının görünümünü belirler (rehber madde 22).
/// Kullanıcıyı cezalandırmak değil, karar sürecine sürtünme eklemek amacıyla
/// AnPause markasıyla, kısa ve düşündürücü bir mesaj gösterir.
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        Self.makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        Self.makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        Self.makeConfiguration()
    }

    private static func makeConfiguration() -> ShieldConfiguration {
        let state = SharedShieldState.current
        let subtitle = state.reasonMessage ?? "Bu alışveriş isteği hâlâ 10 dakika sonra da aynı gelecek mi?"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            title: ShieldConfiguration.Label(text: "Burada bir duraklama var", color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .white.withAlphaComponent(0.8)),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Geri Dön", color: .white),
            primaryButtonBackgroundColor: .systemIndigo,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Yine de Aç", color: .white.withAlphaComponent(0.7))
        )
    }
}
