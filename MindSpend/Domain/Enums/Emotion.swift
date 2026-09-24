import Foundation

enum Emotion: String, Codable, CaseIterable, Identifiable {
    case stress
    case boredom
    case excitement
    case anxiety
    case fomo
    case neutral

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stress: return NSLocalizedString("emotion.stress", value: "Stres", comment: "Emotion: stress")
        case .boredom: return NSLocalizedString("emotion.boredom", value: "Can Sıkıntısı", comment: "Emotion: boredom")
        case .excitement: return NSLocalizedString("emotion.excitement", value: "Heyecan", comment: "Emotion: excitement")
        case .anxiety: return NSLocalizedString("emotion.anxiety", value: "Kaygı", comment: "Emotion: anxiety")
        case .fomo: return NSLocalizedString("emotion.fomo", value: "FOMO", comment: "Emotion: fomo")
        case .neutral: return NSLocalizedString("emotion.neutral", value: "Nötr", comment: "Emotion: neutral")
        }
    }

    var symbolName: String {
        switch self {
        case .stress: return "bolt.heart"
        case .boredom: return "hourglass"
        case .excitement: return "sparkles"
        case .anxiety: return "waveform.path.ecg"
        case .fomo: return "clock.arrow.circlepath"
        case .neutral: return "circle"
        }
    }
}
