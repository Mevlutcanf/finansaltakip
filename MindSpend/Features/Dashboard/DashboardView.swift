import SwiftUI
import SwiftData
import UIKit

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var showAddTransaction = false
    @State private var showPrePurchaseCheck = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let viewModel {
                    weeklyChallengeSection(viewModel: viewModel)
                    behavioralSummarySection(viewModel: viewModel)
                    streakSection(viewModel: viewModel)
                    summaryCards(viewModel: viewModel)
                    activeShieldSection(viewModel: viewModel)
                    recentTransactionsSection(viewModel: viewModel)
                    NavigationLink {
                        RoastView()
                    } label: {
                        Label("Roast My Wallet", systemImage: "flame")
                            .symbolEffect(.pulse)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding()
            .animation(.easeOut(duration: 0.35), value: viewModel == nil)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("AnPause")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Harcama Kaydet") { showAddTransaction = true }
                    Button("Alışveriş İsteği") { showPrePurchaseCheck = true }
                } label: {
                    Label("Yeni", systemImage: "plus.circle.fill")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $showPrePurchaseCheck) {
            PrePurchaseCheckView()
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(
                    transactionRepository: TransactionRepository(context: modelContext),
                    avoidedPurchaseRepository: AvoidedPurchaseRepository(context: modelContext),
                    shieldSessionRepository: ShieldSessionRepository(context: modelContext),
                    noSpendDayRepository: NoSpendDayRepository(context: modelContext)
                )
            }
            viewModel?.refresh()
        }
    }

    @ViewBuilder
    private func weeklyChallengeSection(viewModel: DashboardViewModel) -> some View {
        if let challenge = viewModel.weeklyChallenge {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("İlk 7 Gün Meydan Okuması", systemImage: "flag.checkered")
                        .font(.subheadline.weight(.semibold))
                        .symbolEffect(.bounce, value: challenge.activeDays)
                    Spacer()
                    Text("\(challenge.activeDays)/\(challenge.totalDays)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.accent)
                }
                ProgressView(value: Double(challenge.activeDays), total: Double(challenge.totalDays))
                    .tint(Theme.accent)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: challenge.activeDays)
                Text(challenge.isCompleted
                    ? "Harika! İlk haftanı tamamladın."
                    : "Her gün en az bir harcama kaydet, alışveriş ertele ya da 'harcama yapmadım' de.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .premiumCard()
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
    }

    /// Rehber madde 2: ana metrik "ne kadar harcadım" değil "neden ve ne
    /// sıklıkla dürtü yaşıyorum" olmalı — bu yüzden bu bölüm para kartlarının
    /// önünde, en üstte gösterilir.
    @ViewBuilder
    private func behavioralSummarySection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Ayki Davranışın")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryCard(
                    title: "Kaydedilen dürtü",
                    value: "\(viewModel.behavioralMetrics.impulseCount)",
                    symbolName: "bolt.heart"
                )
                SummaryCard(
                    title: "Başlatılan cooldown",
                    value: "\(viewModel.behavioralMetrics.cooldownsStarted)",
                    symbolName: "hourglass"
                )
            }
            HStack(spacing: 12) {
                SummaryCard(
                    title: "En sık duygu",
                    value: viewModel.behavioralMetrics.topEmotion?.displayName ?? "—",
                    symbolName: viewModel.behavioralMetrics.topEmotion?.symbolName ?? "circle"
                )
                SummaryCard(
                    title: "En sık tetikleyici",
                    value: viewModel.behavioralMetrics.topTrigger?.displayName ?? "—",
                    symbolName: viewModel.behavioralMetrics.topTrigger?.symbolName ?? "questionmark.circle"
                )
            }
        }
    }

    @ViewBuilder
    private func streakSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("\(viewModel.streak.noSpendDayStreak) günlük seri", systemImage: "flame.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ember)
                    .symbolEffect(.bounce, value: viewModel.streak.noSpendDayStreak)
                Spacer()
                if !viewModel.isTodayConfirmedNoSpend {
                    Button("Bugün harcama yapmadım") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            viewModel.confirmNoSpendToday()
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.bordered)
                    .tint(Theme.ember)
                }
            }
            Text("Bu hafta \(viewModel.streak.cooldownStreakThisWeek) kez dürtünü erteledin.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .premiumCard()
    }

    @ViewBuilder
    private func summaryCards(viewModel: DashboardViewModel) -> some View {
        VStack(spacing: 12) {
            SummaryCard(
                title: "Bu ay harcama",
                value: viewModel.monthlySpend.formatted,
                symbolName: "creditcard"
            )
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Kaçınılan alışveriş",
                    value: "\(viewModel.avoidedCount)",
                    symbolName: "hand.raised"
                )
                SummaryCard(
                    title: "Kaçınılan tutar",
                    value: viewModel.avoidedPotential.formatted,
                    symbolName: "banknote"
                )
            }
        }
    }

    @ViewBuilder
    private func activeShieldSection(viewModel: DashboardViewModel) -> some View {
        if !viewModel.activeShieldSessions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktif Kalkan")
                    .font(.headline)
                ForEach(viewModel.activeShieldSessions) { session in
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(Theme.ember)
                            .symbolEffect(.pulse)
                        Text("Bitiş: \(session.expiresAt.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .premiumCard()
                }
            }
        }
    }

    @ViewBuilder
    private func recentTransactionsSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Son İşlemler")
                .font(.headline)

            if viewModel.recentTransactions.isEmpty {
                Text("Henüz kayıtlı işlem yok.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.recentTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.title3.bold())
                .contentTransition(.numericText())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard()
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Image(systemName: transaction.category.symbolName)
                .font(.subheadline)
                .foregroundStyle(Theme.accent)
                .frame(width: 28, height: 28)
                .background(Theme.accent.opacity(0.12), in: Circle())
            VStack(alignment: .leading) {
                Text(transaction.category.displayName)
                    .font(.subheadline.weight(.medium))
                Text(transaction.emotion.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.money.formatted)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}
