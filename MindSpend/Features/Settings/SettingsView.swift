import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    @State private var exportURL: URL?
    @State private var exportError: String?

    @AppStorage("weeklyReflectionEnabled") private var weeklyReflectionEnabled = true
    @AppStorage("defaultRoastTone") private var defaultRoastToneRaw = RoastTone.balanced.rawValue

    private var defaultRoastTone: Binding<RoastTone> {
        Binding(
            get: { RoastTone(rawValue: defaultRoastToneRaw) ?? .balanced },
            set: { defaultRoastToneRaw = $0.rawValue }
        )
    }

    var body: some View {
        List {
            Section("Kalkan ve İzinler") {
                NavigationLink {
                    ShieldSetupView()
                } label: {
                    Label("Ekran Süresi İzni ve Kalkan Kuralları", systemImage: "shield")
                }
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Bildirim İzinlerini Yönet", systemImage: "bell.badge")
                }
            }

            Section("Bildirimler") {
                Toggle(isOn: $weeklyReflectionEnabled) {
                    Label("Haftalık Farkındalık Hatırlatması", systemImage: "calendar.badge.clock")
                }
                .onChange(of: weeklyReflectionEnabled) { _, isEnabled in
                    if isEnabled {
                        NotificationService.shared.scheduleWeeklyReflection()
                    } else {
                        NotificationService.shared.cancelWeeklyReflection()
                    }
                }
            }

            Section("Roast My Wallet") {
                Picker(selection: defaultRoastTone) {
                    ForEach(RoastTone.allCases) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                } label: {
                    Label("Varsayılan Ton", systemImage: "flame")
                }
            }

            Section("Araçlar") {
                NavigationLink {
                    RecurringItemsView()
                } label: {
                    Label("Abonelikler ve Sürekli Gider/Gelir", systemImage: "arrow.triangle.2.circlepath")
                }
            }

            Section("Gizlilik") {
                NavigationLink {
                    PrivacyView()
                } label: {
                    Label("Gizlilik", systemImage: "lock.shield")
                }
                Button {
                    export(format: .csv)
                } label: {
                    Label("Verilerimi Dışa Aktar (CSV)", systemImage: "square.and.arrow.up")
                }
                Button {
                    export(format: .json)
                } label: {
                    Label("Verilerimi Dışa Aktar (JSON)", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Tüm Verileri Sil", systemImage: "trash")
                }
            }

            Section("Hakkında") {
                LabeledContent("Sürüm", value: appVersion)
                if let contactURL = URL(string: "mailto:destek@anpause.app") {
                    Link(destination: contactURL) {
                        Label("Bize Ulaş", systemImage: "envelope")
                    }
                }
            }

            if let exportError {
                Text(exportError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Ayarlar")
        .confirmationDialog(
            "Tüm veriler kalıcı olarak silinecek. Emin misin?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive, action: deleteAllData)
            Button("Vazgeç", role: .cancel) {}
        }
        .sheet(item: Binding(get: { exportURL.map(ShareFileItem.init) }, set: { exportURL = $0?.url })) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    private var appVersion: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(shortVersion) (\(build))"
    }

    private func deleteAllData() {
        try? modelContext.delete(model: Transaction.self)
        try? modelContext.delete(model: AvoidedPurchase.self)
        try? modelContext.delete(model: ShieldRule.self)
        try? modelContext.delete(model: ShieldSession.self)
        try? modelContext.delete(model: NoSpendDay.self)
        try? modelContext.delete(model: RecurringItem.self)
        try? modelContext.save()
    }

    private func export(format: ExportFormat) {
        do {
            let transactions = try TransactionRepository(context: modelContext).fetchAll()
            let avoided = try AvoidedPurchaseRepository(context: modelContext).fetchAll()
            exportURL = try ExportService().export(transactions: transactions, avoidedPurchases: avoided, format: format)
            exportError = nil
        } catch {
            exportError = "Export başarısız oldu. Lütfen tekrar dene."
        }
    }
}
