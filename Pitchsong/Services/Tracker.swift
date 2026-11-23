import Foundation
import FirebaseCore
import FirebaseAnalytics

/// Thin wrapper around Firebase Analytics.
/// - Never records artist names, song titles, links or anything typed into the order form.
/// - Does not use the advertising ID and does not track people across other apps.
/// - The user can switch it off in Settings.
enum Tracker {
    private static var isConfigured = false

    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: StorageKey.analyticsEnabled) as? Bool ?? true
    }

    /// Call once at launch. Does nothing (instead of crashing) if GoogleService-Info.plist is missing.
    static func start() {
        guard !isConfigured else { return }
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else { return }
        FirebaseApp.configure()
        isConfigured = true
        Analytics.setAnalyticsCollectionEnabled(isEnabled)
    }

    static func setEnabled(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: StorageKey.analyticsEnabled)
        guard isConfigured else { return }
        Analytics.setAnalyticsCollectionEnabled(on)
    }

    static func log(_ name: String, _ parameters: [String: Any]? = nil) {
        guard isConfigured, isEnabled else { return }
        Analytics.logEvent(name, parameters: parameters)
    }
}
