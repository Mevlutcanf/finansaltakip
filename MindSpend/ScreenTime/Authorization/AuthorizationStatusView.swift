import SwiftUI

struct AuthorizationStatusView: View {
    let status: ScreenTimeAuthorizationStatus
    let onRequest: () -> Void

    var body: some View {
        switch status {
        case .notDetermined:
            VStack(alignment: .leading, spacing: 12) {
                Text("Kalkanı kullanmak için ekran süresi izni gerekiyor.")
                    .font(.subheadline)
                Button("İzin Ver", action: onRequest)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .denied:
            VStack(alignment: .leading, spacing: 8) {
                Label("İzin reddedildi", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text("Kalkanı kullanmak için Ayarlar > Ekran Süresi'nden MindSpend'e izin verebilirsin.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .approved:
            EmptyView()
        }
    }
}
