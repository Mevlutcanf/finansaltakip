import SwiftUI
import SwiftData
import UIKit

struct RoastView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RoastViewModel?
    @State private var tone: RoastTone = .balanced
    @State private var shareCardURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                viewModel = RoastViewModel(
                    transactionRepository: TransactionRepository(context: modelContext),
                    avoidedPurchaseRepository: AvoidedPurchaseRepository(context: modelContext)
                )
                Task { await viewModel?.generate(tone: tone) }
            }
        }
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
