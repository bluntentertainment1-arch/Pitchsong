import SwiftUI

/// The round hamburger button that opens the Menu sheet.
struct MenuButton: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Button {
            router.showMenu = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .appFont(17, weight: .bold)
                .foregroundColor(Theme.text)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.surface2.opacity(0.85)))
                .overlay(Circle().stroke(Theme.line2, lineWidth: 1))
                .shadow(color: Theme.magenta.opacity(0.40), radius: 10, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Menu")
    }
}

/// A row used inside cards: round-cornered icon, title, optional subtitle, optional chevron.
struct InfoRow: View {
    let icon: String
    let color: Color
    let title: String
    var subtitle: String? = nil
    var showsChevron = true

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.18))
                Image(systemName: icon)
                    .appFont(16, weight: .semibold)
                    .foregroundColor(color)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .appFont(15, weight: .semibold)
                    .foregroundColor(Theme.text)
                if let subtitle {
                    Text(subtitle)
                        .appFont(12.5)
                        .foregroundColor(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .appFont(12, weight: .bold)
                    .foregroundColor(Theme.faint)
            }
        }
        .padding(12)
        .contentShape(Rectangle())
    }
}

/// "Share app" row. Shares the App Store link once AppConfig.appStoreID is set.
struct ShareAppRow: View {
    private var label: some View {
        InfoRow(
            icon: "square.and.arrow.up",
            color: Theme.cyanText,
            title: "Share app",
            subtitle: "Tell other artists about Pitchsong",
            showsChevron: false
        )
    }

    var body: some View {
        if let url = AppConfig.appStoreURL {
            ShareLink(
                item: url,
                subject: Text("Pitchsong by Blunt Entertainment"),
                message: Text(AppConfig.shareMessage)
            ) {
                label
            }
            .buttonStyle(.plain)
        } else {
            ShareLink(item: AppConfig.shareMessage) {
                label
            }
            .buttonStyle(.plain)
        }
    }
}

/// "Rate app" row.
struct RateAppRow: View {
    var body: some View {
        Button {
            ReviewManager.rateApp()
        } label: {
            InfoRow(
                icon: "star.fill",
                color: Theme.amberText,
                title: "Rate app",
                subtitle: "Enjoying Pitchsong? Leave a rating",
                showsChevron: false
            )
        }
        .buttonStyle(.plain)
    }
}
