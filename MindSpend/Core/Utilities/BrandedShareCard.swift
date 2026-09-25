import SwiftUI

/// Sosyal medyada (Instagram/TikTok Story formatı) paylaşılabilir, markalı
/// bir sonuç kartı. Roast My Wallet ve "vazgeçtim" anları gibi birden fazla
/// yerde aynı görsel dilin kullanılması için genelleştirildi.
struct BrandedShareCardView: View {
    let icon: String
    let headline: String
    let message: String
    let footer: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.10, blue: 0.22), Color(red: 0.24, green: 0.16, blue: 0.46)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundStyle(.orange)
                    Text("AnPause")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(headline)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text(message)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text(footer)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(48)
        }
        .frame(width: 1080, height: 1920)
    }
}

/// `BrandedShareCardView`'ı PNG'ye render edip geçici bir dosyaya yazar.
/// `ShareSheet` (bkz. `ActivityShareSheet.swift`) ile birlikte kullanılır.
@MainActor
enum ShareCardRenderer {
    static func renderPNG(
        icon: String,
        headline: String,
        message: String,
        footer: String,
        filePrefix: String
    ) -> URL? {
        let card = BrandedShareCardView(icon: icon, headline: headline, message: message, footer: footer)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 2

        guard let uiImage = renderer.uiImage, let data = uiImage.pngData() else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(filePrefix)-\(Int(Date.now.timeIntervalSince1970))")
            .appendingPathExtension("png")

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
