import SwiftUI
import SwiftData

/// FAZ 3 (Screen Time) tamamlanana kadar bu ekran ManagedSettings/FamilyControls'e
/// bağımlı değildir; yalnızca ShieldRule kayıtlarını isim ve cooldown süresiyle yönetir.
/// FamilyActivityPicker entegrasyonu FAZ 3'te `selectionData` alanını dolduracak şekilde eklenecek.
struct ShieldSetupView: View {
    @Query(sort: \ShieldRule.createdAt, order: .reverse) private var rules: [ShieldRule]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddRule = false

    var body: some View {
        List {
            if rules.isEmpty {
                ContentUnavailableView(
                    "Henüz kalkan kuralı yok",
                    systemImage: "shield",
                    description: Text("Alışveriş uygulamalarına veya sitelerine cooldown eklemek için bir kural oluştur.")
                )
            } else {
                ForEach(rules) { rule in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.name)
                            .font(.subheadline.weight(.medium))
                        Text("Varsayılan cooldown: \(rule.defaultCooldownMinutes) dk")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Kalkan")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddRule = true
                } label: {
                    Label("Yeni Kural", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRule) {
            AddShieldRuleView()
        }
    }
}

private struct AddShieldRuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var cooldown: CooldownDuration = .oneHour

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
                Section {
                    Text("Uygulama ve web sitesi seçimi FAZ 3'te FamilyActivityPicker ile eklenecek.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Yeni Kalkan Kuralı")
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

    private func save() {
        let rule = ShieldRule(
            name: name,
            selectionData: Data(),
            defaultCooldownMinutes: cooldown.minutes
        )
        try? ShieldRuleRepository(context: modelContext).add(rule)
        dismiss()
    }
}
