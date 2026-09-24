import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(symbol: "hourglass", title: "Alışveriş dürtüsüne biraz zaman kazandır."),
        OnboardingPage(symbol: "heart.text.square", title: "Duygularını fark et."),
        OnboardingPage(symbol: "shield", title: "İstersen alışveriş uygulamalarına cooldown koy."),
        OnboardingPage(symbol: "lock.shield", title: "Verilerin cihazında kalır.")
    ]

    var body: some View {
        VStack {
            TabView(selection: $pageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)

            if pageIndex == pages.count - 1 {
                Button("İlk Kalkanını Oluştur") {
                    onFinish()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                Button("Devam Et") {
                    withAnimation { pageIndex += 1 }
                }
                .buttonStyle(.bordered)
                .padding()
            }

            Button("Atla") { onFinish() }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }
}

private struct OnboardingPage {
    let symbol: String
    let title: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text(page.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
