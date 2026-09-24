import SwiftUI
import SwiftData
import FamilyControls

struct ShieldSetupView: View {
    @Query(sort: \ShieldRule.createdAt, order: .reverse) private var rules: [ShieldRule]
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ShieldSession> { $0.statusRaw == "active" }) private var activeSessions: [ShieldSession]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var authService = ScreenTimeAuthorizationService()
    @State private var showAddRule = false
    @State private var showPaywall = false
    @State private var activationError: String?

    private var canAddRule: Bool {
        subscriptionManager.state.isPremium || rules.count < FreeTierLimits.maxShieldRules
    }

    var body: some View {
        List {
            if authService.status != .approved {
                AuthorizationStatusView(status: authService.status) {
                    Task { await authService.requestAuthorization() }
                }
            }

            if rules.isEmpty {
                ContentUnavailableView(
                    "Henüz kalkan kuralı yok",
                    systemImage: "shield",
                    description: Text("Alışveriş uygulamalarına veya sitelerine cooldown eklemek için bir kural oluştur.")
                )
            } else {
                ForEach(rules) { rule in
                    ShieldRuleRow(
                        rule: rule,
                        isActive: activeSessions.contains { $0.ruleId == rule.id },
                        isAuthorized: authService.status == .approved,
                        onActivate: { duration in activateShield(rule: rule, duration: duration) }
                    )
                }
                .onDelete(perform: deleteRules)
            }

            if let activationError {
                Text(activationError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Kalkan")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if canAddRule {
                        showAddRule = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Label("Yeni Kural", systemImage: "plus")
                }
                .disabled(authService.status != .approved)
            }
        }
        .sheet(isPresented: $showAddRule) {
            AddShieldRuleView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear { authService.refreshStatus() }
    }

    private func deleteRules(at offsets: IndexSet) {
        let repository = ShieldRuleRepository(context: modelContext)
        for index in offsets {
            try? repository.delete(rules[index])
        }
    }

    private func activateShield(rule: ShieldRule, duration: CooldownDuration) {
        let service = ShieldService(sessionRepository: ShieldSessionRepository(context: modelContext))
        do {
            try service.activateShield(for: rule, duration: duration, reason: nil)
            activationError = nil
        } catch {
            activationError = "Kalkan etkinleştirilemedi. Lütfen tekrar dene."
        }
    }
}

private struct ShieldRuleRow: View {
    let rule: ShieldRule
    let isActive: Bool
    let isAuthorized: Bool
    let onActivate: (CooldownDuration) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.name)
                        .font(.subheadline.weight(.medium))
                    Text("Varsayılan cooldown: \(rule.defaultCooldownMinutes) dk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isActive {
                    Label("Aktif", systemImage: "shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }

            if !isActive, isAuthorized {
                Menu("Kalkanı Aç") {
                    ForEach(CooldownDuration.allCases) { duration in
                        Button(duration.displayName) { onActivate(duration) }
                    }
                }
                .font(.caption.weight(.medium))
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AddShieldRuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var cooldown: CooldownDuration = .oneHour
    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Kural Adı") {
                    TextField("Örn. Alışveriş", text: $name)
                }
                Section("Varsayılan Cooldown") {
                    Picker("Cooldown", selection: $cooldown) {
                        ForEach(CooldownDuration.allCases) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Korunacak Uygulama ve Siteler") {
                    Button {
                        showPicker = true
                    } label: {
                        HStack {
                            Text("Seç")
                            Spacer()
                            Text(selectionSummary)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Yeni Kalkan Kuralı")
            .familyActivityPicker(isPresented: $showPicker, selection: $selection)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var selectionSummary: String {
        let count = selection.applicationTokens.count
            + selection.categoryTokens.count
            + selection.webDomainTokens.count
        return count == 0 ? "Seçilmedi" : "\(count) öğe"
    }

    private func save() {
        let rule = ShieldRule(
            name: name,
            selectionData: FamilyActivitySelectionCoding.encode(selection),
            defaultCooldownMinutes: cooldown.minutes
        )
        try? ShieldRuleRepository(context: modelContext).add(rule)
        dismiss()
    }
}
