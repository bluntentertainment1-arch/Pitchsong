import SwiftUI

@main
struct PitchsongApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = RequestStore()
    @AppStorage(StorageKey.darkMode) private var isDarkMode = true

    init() {
        Tracker.start()
        // Must be created at launch so taps on the Friday reminder are received.
        _ = NotificationManager.shared
        AppLaunch.recordInstallDateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(store)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .dynamicTypeSize(.xSmall ... .accessibility2)
        }
    }
}
