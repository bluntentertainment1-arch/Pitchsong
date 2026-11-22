import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(StorageKey.darkMode) private var isDarkMode = true
    @AppStorage(StorageKey.remindersEnabled) private var remindersEnabled = false
    @ObservedObject private var notifications = NotificationManager.shared
    @State private var showDeniedAlert = false

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }

    /// The switch shows "on" only when the user wants reminders AND iOS allows notifications.
    private var remindersBinding: Binding<Bool> {
        Binding(
            get: { remindersEnabled && notifications.isAuthorized },
            set: { setReminders($0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(kicker: "Preferences", title: "Settings")

                section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        InfoRow(
                            icon: isDarkMode ? "moon.stars.fill" : "sun.max.fill",
                            color: Theme.violet2Text,
                            title: "Dark mode",
                            subtitle: isDarkMode ? "Dark theme is on" : "Light theme is on",
                            showsChevron: false
                        )
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Theme.magenta))
                    .padding(.trailing, 12)
                }

                section("Notifications") {
                    Toggle(isOn: remindersBinding) {
                        InfoRow(
                            icon: "bell.badge.fill",
                            color: Theme.amberText,
                            title: "Friday playlist reminder",
                            subtitle: "Every Friday at 10:00 AM",
                            showsChevron: false
                        )
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Theme.magenta))
                    .padding(.trailing, 12)
                }
                Text("“\(NotificationManager.reminderBody)”")
                    .appFont(12)
                    .foregroundColor(Theme.faint)
                    .padding(.horizontal, 6)

                section("About") {
                    NavigationLink {
                        LegalDocumentView(title: "About Us", updated: nil,
                                          sections: LegalContent.about, showsBrand: true)
                    } label: {
                        InfoRow(icon: "person.2.fill", color: Theme.cyanText, title: "About us")
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Theme.line)
                    NavigationLink {
                        LegalDocumentView(title: "Privacy Policy", updated: LegalContent.updated,
                                          sections: LegalContent.privacy)
                    } label: {
                        InfoRow(icon: "hand.raised.fill", color: Theme.amberText, title: "Privacy policy")
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Theme.line)
                    NavigationLink {
                        LegalDocumentView(title: "Terms of Use", updated: LegalContent.updated,
                                          sections: LegalContent.terms)
                    } label: {
                        InfoRow(icon: "doc.text.fill", color: Theme.violet2Text, title: "Terms of use")
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Theme.line)
                    NavigationLink {
                        ContactUsView()
                    } label: {
                        InfoRow(icon: "message.fill", color: Color(hex: 0x25D366), title: "Contact us")
                    }
                    .buttonStyle(.plain)
                }

                section("Support Pitchsong") {
                    RateAppRow()
                    Divider().overlay(Theme.line)
                    ShareAppRow()
                }

                Text("Pitchsong \(appVersion)\n© 2026 Blunt Entertainment")
                    .appFont(11.5)
                    .foregroundColor(Theme.faint)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .readableWidth(640)
        }
        .background(AppBackground())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task {
            await notifications.refreshStatus()
        }
        .alert("Notifications are off", isPresented: $showDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Turn on notifications for Pitchsong in the iPhone Settings app to get the Friday reminder.")
        }
    }

    // MARK: Actions

    private func setReminders(_ on: Bool) {
        Task { @MainActor in
            if on {
                await notifications.refreshStatus()
                if notifications.status == .notDetermined {
                    _ = await notifications.requestAuthorization()
                }
                if notifications.isAuthorized {
                    remindersEnabled = true
                    await notifications.scheduleFridayReminder()
                } else {
                    remindersEnabled = false
                    showDeniedAlert = true
                }
            } else {
                remindersEnabled = false
                notifications.cancelFridayReminder()
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .appFont(11.5, weight: .bold)
                .tracking(1.6)
                .foregroundColor(Theme.faint)
                .padding(.leading, 6)
            VStack(spacing: 0) {
                content()
            }
            .card(padding: 4)
        }
    }
}
