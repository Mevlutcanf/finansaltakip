import SwiftUI
import SwiftData

struct AvoidedPurchasesView: View {
    @Query(sort: \AvoidedPurchase.createdAt, order: .reverse) private var items: [AvoidedPurchase]
    @Environment(\.modelContext) private var modelContext

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
    }

    private func resolve(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) {
        try? AvoidedPurchaseRepository(context: modelContext).update(item, status: status)
        if status != .pending {
            NotificationService.shared.cancelCooldownNotification(for: item)
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
