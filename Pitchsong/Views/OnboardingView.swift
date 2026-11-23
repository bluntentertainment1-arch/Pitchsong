import SwiftUI

private struct OnboardingCard {
    let icon: String
    let tint: Color
    let title: String
    let text: String
}

/// Four swipeable cards shown only the first time the app is opened.
struct OnboardingView: View {
    let onFinish: () -> Void

    @AppStorage(StorageKey.remindersEnabled) private var remindersEnabled = false
    @ObservedObject private var notifications = NotificationManager.shared
    @State private var page = 0
    @State private var isWorking = false

    private let cards: [OnboardingCard] = [
        OnboardingCard(
            icon: "waveform",
            tint: Theme.magenta,
            title: "Welcome to Pitchsong",
            text: "Music promotion from Blunt Entertainment. Put your songs in front of new listeners."
        ),
        OnboardingCard(
            icon: "square.grid.2x2.fill",
            tint: Theme.violet,
            title: "Choose your promotion",
            text: "Spotify playlist pitching, TikTok and Instagram creators, music blogs, or a full combo."
        ),
        OnboardingCard(
            icon: "message.fill",
            tint: Color(hex: 0x25D366),
            title: "Order on WhatsApp",
            text: "Pick a package and send your order. Our team replies with the price. Payment is arranged on WhatsApp, never inside the app."
        ),
        OnboardingCard(
            icon: "bell.badge.fill",
            tint: Theme.amber,
            title: "Never miss a drop",
            text: "Get a reminder every Friday at 10 AM when new playlists are open for pitching. You can change this any time in Settings."
        )
    ]

    private var isLast: Bool { page == cards.count - 1 }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button("Skip") { withAnimation(.easeInOut) { page = cards.count - 1 } }
                        .appFont(15, weight: .semibold)
                        .foregroundColor(Theme.muted)
                        .opacity(isLast ? 0 : 1)
                        .disabled(isLast)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                TabView(selection: $page) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        OnboardingPage(card: cards[index])
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                dots

                VStack(spacing: 10) {
                    if isLast {
                        Button {
                            enableReminders()
                        } label: {
                            Label("Turn on notifications", systemImage: "bell.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isWorking)

                        Button {
                            onFinish()
                        } label: {
                            Text("Not now")
                        }
                        .buttonStyle(GhostButtonStyle())
                    } else {
                        Button {
                            withAnimation(.easeInOut) { page += 1 }
                        } label: {
                            Text("Next")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .readableWidth(560)
        }
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<cards.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AnyShapeStyle(Theme.cta) : AnyShapeStyle(Theme.line2))
                    .frame(width: index == page ? 26 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: page)
            }
        }
    }

    private func enableReminders() {
        isWorking = true
        Task { @MainActor in
            let granted = await notifications.requestAuthorization()
            if granted {
                remindersEnabled = true
                await notifications.scheduleFridayReminder()
            }
            isWorking = false
            onFinish()
        }
    }
}

private struct OnboardingPage: View {
    let card: OnboardingCard

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [card.tint.opacity(0.55), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                Circle()
                    .stroke(card.tint.opacity(0.45), lineWidth: 1.5)
                    .frame(width: 150, height: 150)
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Theme.surface2)
                    Image(systemName: card.icon)
                        .appFont(52, weight: .semibold)
                        .foregroundColor(card.tint)
                }
                .frame(width: 118, height: 118)
                .shadow(color: card.tint.opacity(0.7), radius: 28)
            }
            .frame(height: 240)

            Text(card.title)
                .appFont(28, weight: .black, design: .rounded)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(card.text)
                .appFont(16)
                .foregroundColor(Theme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .card(padding: 14, highlighted: true)
    }
}
