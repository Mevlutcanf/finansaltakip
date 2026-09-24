import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AnPause Premium")
                        .font(.largeTitle.bold())

                    Text("Premium açıldığında sürekli değer sunar:")
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("Sınırsız Kalkan Kuralı")
                        featureRow("Gelişmiş İçgörüler ve uzun dönem analiz")
                        featureRow("Kaçınılan Alışveriş geçmişi ve gelişmiş özet")
                        featureRow("AI Roast")
                        featureRow("Gelişmiş raporlar / export")
                    }

                    if subscriptionManager.offerings.isEmpty {
                        Text("Paketler yüklenemedi ya da henüz yapılandırılmadı.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(subscriptionManager.offerings) { offering in
                            Button {
                                Task { await subscriptionManager.purchase(offeringId: offering.id) }
                            } label: {
                                HStack {
                                    Text(offering.title)
                                    Spacer()
                                    Text("\(offering.priceString) / \(offering.period)")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    Button("Satın Almaları Geri Yükle") {
                        Task { await subscriptionManager.restore() }
                    }
                    .font(.caption)

                    if let error = subscriptionManager.lastErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .task { await subscriptionManager.loadOfferings() }
        }
    }

    private func featureRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.primary)
    }
}
