import SwiftUI

/// Frosted-glass, ince degrade kenarlıklı kart görünümü. `.secondary.opacity()`
/// düz dolgusu yerine sistem materyali kullanır — hem light hem dark mode'da
/// otomatik uyum sağlar, hem de "vibe-coded" düz kutu hissini kırar.
private struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.accent.opacity(0.35), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)
    }
}

extension View {
    func premiumCard() -> some View {
        modifier(PremiumCardModifier())
    }
}
