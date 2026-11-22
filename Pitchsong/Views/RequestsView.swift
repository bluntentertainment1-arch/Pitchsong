import SwiftUI

struct RequestsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: RequestStore
    @Environment(\.openURL) private var openURL

    @State private var pendingDelete: SongRequest? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeader(
                        kicker: "Your promotions",
                        title: "My requests",
                        subtitle: "Orders you started in this app. They are saved on this device only."
                    ).withMenu()

                    if store.requests.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.requests) { request in
                            RequestRow(
                                request: request,
                                onResend: { resend(request) },
                                onStatus: { store.setStatus($0, for: request) },
                                onDelete: { pendingDelete = request }
                            )
                        }
                        Text("Status is set by you. Our team confirms progress with you on WhatsApp.")
                            .appFont(11.5)
                            .foregroundColor(Theme.faint)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .readableWidth(760)
            }
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
        .confirmationDialog(
            "Delete this request?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let request = pendingDelete {
                    store.delete(request)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("This only removes it from this device. It doesn't cancel anything with our team.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .appFont(44)
                .foregroundColor(Theme.faint)
            Text("No requests yet")
                .appFont(17, weight: .bold)
                .foregroundColor(Theme.text)
            Text("Submit a song and pick a package to start your first campaign.")
                .appFont(13.5)
                .foregroundColor(Theme.muted)
                .multilineTextAlignment(.center)
            Button {
                router.tab = .submit
            } label: {
                Text("Submit a song")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 28)
    }

    private func resend(_ request: SongRequest) {
        guard let package = PromotionCatalog.package(id: request.packageID) else { return }
        let message = Contact.order(
            artist: request.artistName,
            song: request.songTitle,
            link: request.songLink,
            genre: request.genre,
            package: package
        )
        if let url = Contact.whatsappURL(message: message) {
            openURL(url)
        }
    }
}

struct RequestRow: View {
    let request: SongRequest
    let onResend: () -> Void
    let onStatus: (RequestStatus) -> Void
    let onDelete: () -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(request.songTitle)
                        .appFont(17, weight: .bold, design: .rounded)
                        .foregroundColor(Theme.text)
                    Text(request.artistName)
                        .appFont(13)
                        .foregroundColor(Theme.muted)
                }
                Spacer()
                Menu {
                    ForEach(RequestStatus.allCases) { status in
                        Button {
                            onStatus(status)
                        } label: {
                            if status == request.status {
                                Label(status.label, systemImage: "checkmark")
                            } else {
                                Text(status.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(request.status.label)
                        Image(systemName: "chevron.down")
                            .appFont(9, weight: .bold)
                    }
                    .appFont(12, weight: .bold)
                    .foregroundColor(request.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(request.status.color.opacity(0.14))
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 6) {
                Pill(text: request.categoryTitle, color: Theme.cyanText)
                Pill(text: request.genre, color: Theme.violet2Text)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(request.packageName)
                    .appFont(12.5, weight: .heavy)
                    .tracking(0.5)
                    .foregroundColor(Theme.amberText)
                Text(Self.dateFormatter.string(from: request.createdAt))
                    .appFont(12)
                    .foregroundColor(Theme.faint)
            }

            HStack(spacing: 10) {
                Button(action: onResend) {
                    Label("Open in WhatsApp", systemImage: "message.fill")
                }
                .buttonStyle(GhostButtonStyle())

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(Theme.danger)
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)
                        .background(Theme.danger.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(Theme.danger.opacity(0.4), lineWidth: 1)
                        )
                }
                .accessibilityLabel("Delete request")
            }
        }
        .card(padding: 16)
    }
}
