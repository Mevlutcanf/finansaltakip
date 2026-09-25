import SwiftUI
import SwiftData

struct AvoidedPurchasesView: View {
    @Query(sort: \AvoidedPurchase.createdAt, order: .reverse) private var items: [AvoidedPurchase]
    @Environment(\.modelContext) private var modelContext
    @State private var celebrating: AvoidedPurchase?

    var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView(
                    "Henüz kaçınılan alışveriş yok",
                    systemImage: "hand.raised",
                    description: Text("Bir alışveriş isteğini ertelediğinde burada görünecek.")
                )
            } else {
                ForEach(items) { item in
                    AvoidedPurchaseRow(item: item, onResolve: resolve)
                }
            }
        }
        .navigationTitle("Kaçınılan Alışverişler")
        .sheet(item: $celebrating) { item in
            AvoidedCelebrationView(item: item)
        }
    }

    private func resolve(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) {
        try? AvoidedPurchaseRepository(context: modelContext).update(item, status: status)
        if status != .pending {
            NotificationService.shared.cancelCooldownNotification(for: item)
        }
        if status == .avoided {
            celebrating = item
        }
    }
}

private struct AvoidedPurchaseRow: View {
    let item: AvoidedPurchase
    let onResolve: (AvoidedPurchase, AvoidedPurchaseStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.itemName)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(item.money.formatted)
                    .font(.subheadline.weight(.semibold))
            }
            Text(item.emotion.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)

            if item.isCooldownActive {
                Text("Cooldown sonu: \(item.cooldownExpiresAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            } else if item.status == .pending {
                HStack {
                    Button("Vazgeçtim") { onResolve(item, .avoided) }
                        .buttonStyle(.bordered)
                    Button("Aldım") { onResolve(item, .purchased) }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                Text(item.status == .avoided ? "Vazgeçildi" : "Satın alındı")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(item.status == .avoided ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Kullanıcı bir dürtüyü yendiğinde anında pekiştirme sağlayan kısa kutlama
/// ekranı — Roast My Wallet'ın aylık özetini beklemeden her küçük zaferi
/// görünür kılar.
private struct AvoidedCelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    let item: AvoidedPurchase
    @State private var shareCardURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)

                Text("Vazgeçtin!")
                    .font(.title.bold())

                Text("\(item.itemName) — \(item.money.formatted) cebinde kaldı.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button {
                    shareCardURL = ShareCardRenderer.renderPNG(
                        icon: "hand.raised.fill",
                        headline: "Vazgeçtim!",
                        message: "\(item.itemName) — \(item.money.formatted) cebimde kaldı.",
                        footer: "AnPause ile dürtünü yendin",
                        filePrefix: "anpause-avoided"
                    )
                } label: {
                    Label("Paylaş", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .sheet(item: Binding(get: { shareCardURL.map(ShareFileItem.init) }, set: { shareCardURL = $0?.url })) { shareItem in
                ShareSheet(activityItems: [shareItem.url])
            }
        }
    }
}
