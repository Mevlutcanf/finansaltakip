import SwiftUI
import SwiftData

struct RoastView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RoastViewModel?
    @State private var tone: RoastTone = .balanced

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
                            .frame(maxWidth: .infinity)
                    } else {
                        RoastCard(text: viewModel.roastText)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Roast My Wallet")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text(text)
                .font(.body)
            ShareLink(item: text) {
                Label("Paylaş", systemImage: "square.and.arrow.up")
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}
