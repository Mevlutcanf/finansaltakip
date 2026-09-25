import SwiftUI
import SwiftData
import UIKit

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
    @State private var didAppear = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 120, height: 120)
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, value: didAppear)
                    }
                    .scaleEffect(didAppear ? 1 : 0.6)
                    .opacity(didAppear ? 1 : 0)

                    Text("Vazgeçtin!")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("\(item.itemName) — \(item.money.formatted) cebinde kaldı.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))

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
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 32)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .sheet(item: Binding(get: { shareCardURL.map(ShareFileItem.init) }, set: { shareCardURL = $0?.url })) { shareItem in
                ShareSheet(activityItems: [shareItem.url])
            }
            .onAppear {
                SoundService.shared.play(.celebration)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    didAppear = true
                }
            }
        }
    }
}
