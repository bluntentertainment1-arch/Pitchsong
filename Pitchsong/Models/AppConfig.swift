import Foundation

/// Keys for everything the app remembers on the device.
enum StorageKey {
    static let darkMode = "pitchsong.darkMode"
    static let hasOnboarded = "pitchsong.hasOnboarded"
    static let installDate = "pitchsong.installDate"
    static let remindersEnabled = "pitchsong.remindersEnabled"
    static let ratePromptDone = "pitchsong.ratePromptDone"
}

enum AppConfig {
    /// The numeric Apple ID of the app: App Store Connect > your app > App Information > Apple ID.
    /// Leave empty until the app record exists. Once it is filled in:
    ///  - "Rate app" opens the App Store review page, and
    ///  - "Share app" shares the real App Store link.
    static let appStoreID = ""

    static var appStoreURL: URL? {
        appStoreID.isEmpty ? nil : URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    static var writeReviewURL: URL? {
        appStoreID.isEmpty ? nil : URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")
    }

    /// Days after install before iOS is asked to show the rating prompt.
    static let ratePromptAfterDays = 3

    static let shareMessage = "Check out Pitchsong by Blunt Entertainment. Promote your music with Spotify, TikTok, Instagram and blog campaigns."
}

enum AppLaunch {
    /// Remembers the first time the app was opened (used for the 3-day rating prompt).
    static func recordInstallDateIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: StorageKey.installDate) == nil {
            defaults.set(Date().timeIntervalSince1970, forKey: StorageKey.installDate)
        }
    }
}

/// Decides when to ask iOS to show its rating prompt: once, at least 3 days after install.
enum RatePrompt {
    static func isDue(now: Date = Date()) -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: StorageKey.ratePromptDone) { return false }
        let install = defaults.double(forKey: StorageKey.installDate)
        if install <= 0 { return false }
        let elapsed = now.timeIntervalSince1970 - install
        return elapsed >= Double(AppConfig.ratePromptAfterDays) * 86_400
    }

    static func markDone() {
        UserDefaults.standard.set(true, forKey: StorageKey.ratePromptDone)
    }
}
