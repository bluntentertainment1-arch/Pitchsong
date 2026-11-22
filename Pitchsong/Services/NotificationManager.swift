import Foundation
import UIKit
import UserNotifications

extension Notification.Name {
    /// Posted when the user taps the Friday reminder.
    static let pitchsongOpenSubmit = Notification.Name("pitchsong.openSubmit")
}

/// Asks for notification permission and schedules the weekly Friday 10:00 AM local reminder.
/// These are local notifications: no server, no push entitlement and no account needed.
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    static let fridayIdentifier = "pitchsong.friday.reminder"
    static let reminderTitle = "Pitchsong"
    static let reminderBody = "New Hot Playlists are Available, Submit your song for pitching"

    @Published private(set) var status: UNAuthorizationStatus = .notDetermined

    private var pendingOpenSubmit = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    var isAuthorized: Bool {
        status == .authorized || status == .provisional
    }

    // MARK: Permission

    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.status = settings.authorizationStatus
        }
    }

    /// Shows the iOS permission dialog (only the first time it is asked).
    @discardableResult
    func requestAuthorization() async -> Bool {
        var granted = false
        do {
            granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            granted = false
        }
        await refreshStatus()
        return granted
    }

    // MARK: Scheduling

    /// Every Friday at 10:00 in the user's local time zone.
    func scheduleFridayReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.fridayIdentifier])

        let content = UNMutableNotificationContent()
        content.title = Self.reminderTitle
        content.body = Self.reminderBody
        content.sound = .default

        var when = DateComponents()
        when.weekday = 6   // 1 = Sunday ... 6 = Friday
        when.hour = 10
        when.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.fridayIdentifier,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelFridayReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.fridayIdentifier])
    }

    // MARK: Opening the app from a notification

    /// True once if the app was opened by tapping the reminder before the UI was ready.
    func consumePendingOpenSubmit() -> Bool {
        let value = pendingOpenSubmit
        pendingOpenSubmit = false
        return value
    }

    // MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        pendingOpenSubmit = true
        await MainActor.run {
            NotificationCenter.default.post(name: .pitchsongOpenSubmit, object: nil)
        }
    }
}
