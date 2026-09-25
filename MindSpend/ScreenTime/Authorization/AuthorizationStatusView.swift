import SwiftUI

struct AuthorizationStatusView: View {
    let status: ScreenTimeAuthorizationStatus
    let errorMessage: String?
    let onRequest: () -> Void

    var body: some View {
        switch status {
        case .notDetermined:
            VStack(alignment: .leading, spacing: 12) {
                Text("Kalkanı kullanmak için ekran süresi izni gerekiyor.")
                    .font(.subheadline)
                Button("İzin Ver", action: onRequest)
                    .buttonStyle(PrimaryButtonStyle())

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .premiumCard()

        case .denied:
            VStack(alignment: .leading, spacing: 8) {
                Label("İzin reddedildi", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text("Kalkanı kullanmak için Ayarlar > Ekran Süresi'nden AnPause'a izin verebilirsin.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .premiumCard()

        case .approved:
            EmptyView()
        }
    }
}
