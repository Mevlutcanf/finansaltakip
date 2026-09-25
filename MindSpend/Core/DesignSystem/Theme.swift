import SwiftUI

/// AnPause'un görsel kimliği — paylaşım kartlarında (`BrandedShareCardView`)
/// zaten kurulan indigo/mor + amber paletiyle tutarlı, uygulamanın geri
/// kalanına yayılan tek bir kaynak.
enum Theme {
    static let accent = Color(red: 0.40, green: 0.35, blue: 0.95)
    static let accentDeep = Color(red: 0.24, green: 0.16, blue: 0.46)
    static let ember = Color(red: 0.98, green: 0.55, blue: 0.24)

    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.07, green: 0.08, blue: 0.17), Color(red: 0.18, green: 0.12, blue: 0.33)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardCornerRadius: CGFloat = 20
}
