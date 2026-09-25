import SwiftUI
import SwiftData
import UIKit

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var showAddTransaction = false
    @State private var showPrePurchaseCheck = false
    @State private var showQuickActions = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let viewModel {
                        weeklyChallengeSection(viewModel: viewModel)
                        behavioralSummarySection(viewModel: viewModel)
                        streakSection(viewModel: viewModel)
                        summaryCards(viewModel: viewModel)
                        activeShieldSection(viewModel: viewModel)
                        recentTransactionsSection(viewModel: viewModel)
                        roastEntryCard
                    }
                }
                .padding()
                .padding(.bottom, 70)
                .animation(.easeOut(duration: 0.35), value: viewModel == nil)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())

            quickActionButton
        }
        .navigationTitle("AnPause")
        .toolbar {
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

    // MARK: - Floating quick-action button

    private var quickActionButton: some View {
        VStack(alignment: .trailing, spacing: 14) {
            if showQuickActions {
                quickActionRow(title: "Alışveriş İsteği", systemImage: "hourglass") {
                    showPrePurchaseCheck = true
                    collapseQuickActions()
                }
                quickActionRow(title: "Harcama Kaydet", systemImage: "creditcard") {
                    showAddTransaction = true
                    collapseQuickActions()
                }
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    showQuickActions.toggle()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(colors: [Theme.accent, Theme.accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
                    .shadow(color: Theme.accent.opacity(0.5), radius: 16, x: 0, y: 8)
                    .rotationEffect(.degrees(showQuickActions ? 45 : 0))
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    private func quickActionRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)

                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.accent, in: Circle())
            }
        }
    }

    private func collapseQuickActions() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showQuickActions = false
        }
    }

    // MARK: - Sections

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
    /// önünde, en üstte gösterilir. Kartlar Analiz ekranına götürür.
    @ViewBuilder
    private func behavioralSummarySection(viewModel: DashboardViewModel) -> some View {
        NavigationLink {
            InsightsView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Bu Ayki Davranışın")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    MiniStat(title: "Kaydedilen dürtü", value: "\(viewModel.behavioralMetrics.impulseCount)", symbolName: "bolt.heart")
                    MiniStat(title: "Başlatılan cooldown", value: "\(viewModel.behavioralMetrics.cooldownsStarted)", symbolName: "hourglass")
                }
                HStack(spacing: 12) {
                    MiniStat(
                        title: "En sık duygu",
                        value: viewModel.behavioralMetrics.topEmotion?.displayName ?? "—",
                        symbolName: viewModel.behavioralMetrics.topEmotion?.symbolName ?? "circle"
                    )
                    MiniStat(
                        title: "En sık tetikleyici",
                        value: viewModel.behavioralMetrics.topTrigger?.displayName ?? "—",
                        symbolName: viewModel.behavioralMetrics.topTrigger?.symbolName ?? "questionmark.circle"
                    )
                }
            }
            .premiumCard()
        }
        .buttonStyle(PressableButtonStyle())
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
            NavigationLink {
                HistoryView()
            } label: {
                SummaryCard(
                    title: "Bu ay harcama",
                    value: viewModel.monthlySpend.formatted,
                    symbolName: "creditcard"
                )
            }
            .buttonStyle(PressableButtonStyle())

            HStack(spacing: 12) {
                NavigationLink {
                    AvoidedPurchasesView()
                } label: {
                    SummaryCard(
                        title: "Kaçınılan alışveriş",
                        value: "\(viewModel.avoidedCount)",
                        symbolName: "hand.raised"
                    )
                }
                .buttonStyle(PressableButtonStyle())

                NavigationLink {
                    AvoidedPurchasesView()
                } label: {
                    SummaryCard(
                        title: "Kaçınılan tutar",
                        value: viewModel.avoidedPotential.formatted,
                        symbolName: "banknote"
                    )
                }
                .buttonStyle(PressableButtonStyle())
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
            HStack {
                Text("Son İşlemler")
                    .font(.headline)
                Spacer()
                NavigationLink("Tümünü Gör") {
                    HistoryView()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.accent)
            }

            if viewModel.recentTransactions.isEmpty {
                Text("Henüz kayıtlı işlem yok.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                VStack(spacing: 4) {
                    ForEach(viewModel.recentTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .premiumCard()
            }
        }
    }

    private var roastEntryCard: some View {
        NavigationLink {
            RoastView()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(Theme.ember)
                    .symbolEffect(.pulse)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Roast My Wallet")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("Bu ayki harcama davranışının eğlenceli, gerçek verilerle özeti — paylaşılabilir.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .premiumCard()
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct MiniStat: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: symbolName)
                .font(.caption)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .foregroundStyle(.primary)
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
