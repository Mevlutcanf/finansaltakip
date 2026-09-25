import SwiftUI
import SwiftData
import UIKit

struct RoastView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("defaultRoastTone") private var defaultRoastToneRaw = RoastTone.balanced.rawValue
    @State private var viewModel: RoastViewModel?
    @State private var tone: RoastTone = .balanced
    @State private var shareCardURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                introCard

                Picker("Ton", selection: $tone) {
                    ForEach(RoastTone.allCases) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: tone) { _, newValue in
                    Task { await viewModel?.generate(tone: newValue) }
                }

                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        RoastCard(text: viewModel.roastText) {
                            SoundService.shared.play(.tick)
                            shareCardURL = ShareCardRenderer.renderPNG(
                                icon: "flame.fill",
                                headline: "Roast My Wallet",
                                message: viewModel.roastText,
                                footer: "AnPause ile dürtünü fark et",
                                filePrefix: "anpause-roast"
                            )
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    }
                }
            }
            .padding()
            .animation(.easeOut(duration: 0.3), value: viewModel?.isLoading)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Roast My Wallet")
        .sheet(item: Binding(get: { shareCardURL.map(ShareFileItem.init) }, set: { shareCardURL = $0?.url })) { item in
            ShareSheet(activityItems: [item.url])
        }
        .onAppear {
            if viewModel == nil {
                tone = RoastTone(rawValue: defaultRoastToneRaw) ?? .balanced
                viewModel = RoastViewModel(
                    transactionRepository: TransactionRepository(context: modelContext),
                    avoidedPurchaseRepository: AvoidedPurchaseRepository(context: modelContext)
                )
                Task { await viewModel?.generate(tone: tone) }
            }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bu ne işe yarar?")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            Text("Bu ayki gerçek harcama verilerinden (kategori, duygu, tetikleyici, vazgeçtiğin alışverişler) eğlenceli bir özet üretir. Uydurma sayı kullanmaz. Sonucu paylaşabilirsin.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct RoastCard: View {
    let text: String
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Theme.ember)
                .symbolEffect(.pulse)
            Text(text)
                .font(.body)
            Button(action: onShare) {
                Label("Paylaş", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard()
    }
}
