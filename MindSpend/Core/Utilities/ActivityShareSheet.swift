import SwiftUI
import UIKit

/// Ortak `UIActivityViewController` sarmalayıcısı — export dosyaları ve
/// paylaşılabilir sonuç kartları (Roast, "vazgeçtim" anı) aynı sheet'i kullanır.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareFileItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
