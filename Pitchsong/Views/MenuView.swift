import SwiftUI

/// The Menu sheet opened by the hamburger button.
struct MenuView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    @AppStorage(StorageKey.darkMode) private var isDarkMode = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        BrandMark(size: 64)
                        HStack(spacing: 0) {
                            Text("PITCH").foregroundColor(Theme.text)
                            Text("SONG").foregroundColor(Theme.orange)
                        }
                        .appFont(22, weight: .black, design: .rounded)
                        .tracking(1.5)
                        Text("by Blunt Entertainment")
                            .appFont(12.5)
                            .foregroundColor(Theme.muted)
                    }
                    .padding(.top, 8)

                    group("Promotions") {
                        promoRow(.spotify, title: "Spotify promotions", subtitle: "Playlist pitching",
                                 color: Color(hex: 0x1DB954))
                        divider
                        promoRow(.tiktok, title: "TikTok promotions", subtitle: "Creators using your sound",
                                 color: Theme.magentaText)
                        divider
                        promoRow(.blog, title: "Blog promotions", subtitle: "Music blogs and websites",
                                 color: Theme.blue)
                    }

                    group("Pitchsong") {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            InfoRow(icon: "gearshape.fill", color: Theme.violet2Text, title: "Settings",
                                    subtitle: "Appearance and reminders")
                        }
                        .buttonStyle(.plain)
                        divider
                        NavigationLink {
                            ContactUsView()
                        } label: {
                            InfoRow(icon: "message.fill", color: Color(hex: 0x25D366), title: "Contact us",
                                    subtitle: "WhatsApp, email, Instagram")
                        }
                        .buttonStyle(.plain)
                        divider
                        NavigationLink {
                            LegalDocumentView(title: "About Us", updated: nil,
                                              sections: LegalContent.about, showsBrand: true)
                        } label: {
                            InfoRow(icon: "person.2.fill", color: Theme.cyanText, title: "About us")
                        }
                        .buttonStyle(.plain)
                        divider
                        NavigationLink {
                            LegalDocumentView(title: "Privacy Policy", updated: LegalContent.updated,
                                              sections: LegalContent.privacy)
                        } label: {
                            InfoRow(icon: "hand.raised.fill", color: Theme.amberText, title: "Privacy policy")
                        }
                        .buttonStyle(.plain)
                    }

                    group("Support Pitchsong") {
                        RateAppRow()
                        divider
                        ShareAppRow()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
                .readableWidth(640)
            }
            .background(AppBackground())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.magentaText)
                }
            }
        }
        .tint(Theme.magenta)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    // MARK: Helpers

    private var divider: some View {
        Divider().overlay(Theme.line)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
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

    private func promoRow(_ category: PromoCategory, title: String, subtitle: String, color: Color) -> some View {
        Button {
            router.openCategory(category)
            dismiss()
        } label: {
            InfoRow(icon: category.symbol, color: color, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}
