import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: RequestStore

    @AppStorage(StorageKey.hasOnboarded) private var hasOnboarded = false
    @AppStorage(StorageKey.remindersEnabled) private var remindersEnabled = false
    @AppStorage(StorageKey.darkMode) private var isDarkMode = true
    @ObservedObject private var notifications = NotificationManager.shared

    @State private var showSplash = true

    var body: some View {
        ZStack {
            TabView(selection: $router.tab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(AppTab.home)

                PackagesView()
                    .tabItem { Label("Packages", systemImage: "square.grid.2x2.fill") }
                    .tag(AppTab.packages)

                SubmitSongView()
                    .tabItem { Label("Submit", systemImage: "plus.circle.fill") }
                    .tag(AppTab.submit)

                RequestsView()
                    .tabItem { Label("My Requests", systemImage: "list.bullet.rectangle.fill") }
                    .tag(AppTab.requests)
            }
            .tint(Theme.magenta)

            // First launch only. The splash sits on top and fades away to reveal it.
            if !hasOnboarded {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasOnboarded = true
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .sheet(isPresented: $router.showMenu) {
            MenuView()
                .environmentObject(router)
                .environmentObject(store)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pitchsongOpenSubmit)) { _ in
            router.showMenu = false
            router.tab = .submit
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            maybeAskForRating()
        }
        .task {
            await notifications.refreshStatus()
            if remindersEnabled {
                if notifications.isAuthorized {
                    await notifications.scheduleFridayReminder()
                } else {
                    remindersEnabled = false
                }
            }

            try? await Task.sleep(nanoseconds: 2_400_000_000)
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }

            if notifications.consumePendingOpenSubmit() {
                router.tab = .submit
            }
            maybeAskForRating()
        }
    }

    /// Asks iOS for its rating prompt once, 3 days or more after install.
    private func maybeAskForRating() {
        guard !showSplash, hasOnboarded, RatePrompt.isDue() else { return }
        RatePrompt.markDone()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            ReviewManager.requestInAppReview()
        }
    }
}
