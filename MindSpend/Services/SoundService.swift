import Foundation
import AVFoundation

/// Uygulamaya özel, kısa ve yumuşak ses efektleri. Sistem bildirim sesleri
/// yerine (`NotificationService`) yalnızca uygulama içi anlık geri bildirim
/// için kullanılır — sessiz modda veya çalma başarısız olursa sessizce
/// hiçbir şey yapmaz, UI akışını asla bloklamaz.
final class SoundService {
    static let shared = SoundService()

    enum Effect: String {
        case tick
        case celebration
        case shieldActivate = "shield_activate"
    }

    private var player: AVAudioPlayer?

    private init() {}

    func play(_ effect: Effect) {
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav", subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.6
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            // Ses çalınamadı; sessizce yok say, kullanıcı deneyimini bloklama.
        }
    }
}
