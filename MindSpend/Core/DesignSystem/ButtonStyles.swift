import SwiftUI

/// Tam genişlikli, degrade dolgulu birincil aksiyon butonu. Onboarding ve
/// Pre-Purchase Check gibi akış-CTA'larında kullanılır; basılınca hafif
/// küçülüp haptic verir.
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: isDisabled
                        ? [.gray.opacity(0.5), .gray.opacity(0.4)]
                        : [Theme.accent, Theme.accentDeep],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

/// Küçük/ikincil aksiyonlar için hafif bas-küçül geri bildirimi.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
