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
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack {
                TabView(selection: $pageIndex) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .animation(.easeInOut, value: pageIndex)

                if pageIndex == pages.count - 1 {
                    Button("İlk Kalkanını Oluştur") {
                        onFinish()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Button("Devam Et") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            pageIndex += 1
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                }

                Button("Atla") { onFinish() }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pageIndex)
        }
    }
}

private struct OnboardingPage {
    let symbol: String
    let title: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.18))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isPulsing ? 1.08 : 0.92)

                Image(systemName: page.symbol)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }

            Text(page.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }
}
