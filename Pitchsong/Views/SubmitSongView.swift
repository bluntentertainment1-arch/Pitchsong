import SwiftUI

struct SubmitSongView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: RequestStore
    @Environment(\.openURL) private var openURL

    private enum Step: Int {
        case song = 1, package, review, done
    }

    @State private var step: Step = .song

    @State private var artist = ""
    @State private var songTitle = ""
    @State private var songLink = ""
    @State private var genre = "Afrobeats"

    @State private var category: PromoCategory = .spotify
    @State private var selectedPackage: PromoPackage? = nil

    @State private var showErrors = false
    @State private var showFreeForm = false
    @State private var lastSentPackageName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if step != .done {
                        ScreenHeader(
                            kicker: "New campaign",
                            title: "Submit a song",
                            subtitle: "Three quick steps. We'll open WhatsApp with your order ready to send."
                        ).withMenu()
                        stepper
                    }

                    switch step {
                    case .song: songStep
                    case .package: packageStep
                    case .review: reviewStep
                    case .done: doneStep
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .readableWidth(680)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
        .onReceive(router.$preselectedPackageID) { id in
            guard let id, let package = PromotionCatalog.package(id: id) else { return }
            selectedPackage = package
            category = package.category
            if step == .done { resetForm() }
            // Jump to details first; the package is already chosen.
            step = isSongValid ? .package : .song
            DispatchQueue.main.async {
                router.preselectedPackageID = nil
            }
        }
        .sheet(isPresented: $showFreeForm) {
            SafariView(url: Contact.freeSubmissionURL)
                .ignoresSafeArea()
        }
    }

    // MARK: - Validation

    private var trimmedArtist: String { artist.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedTitle: String { songTitle.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedLink: String { songLink.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var isLinkValid: Bool {
        guard let url = URL(string: trimmedLink),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host, host.contains(".") else { return false }
        return true
    }

    private var isSongValid: Bool {
        !trimmedArtist.isEmpty && !trimmedTitle.isEmpty && isLinkValid
    }

    // MARK: - Stepper

    private var stepper: some View {
        HStack(spacing: 8) {
            ForEach([Step.song, .package, .review], id: \.rawValue) { s in
                VStack(spacing: 6) {
                    Capsule()
                        .fill(s.rawValue <= step.rawValue ? AnyShapeStyle(Theme.cta) : AnyShapeStyle(Theme.surface2))
                        .frame(height: 4)
                    Text(label(for: s))
                        .appFont(11, weight: .bold)
                        .tracking(1)
                        .foregroundColor(s == step ? Theme.text : (s.rawValue < step.rawValue ? Theme.magenta : Theme.faint))
                }
            }
        }
    }

    private func label(for step: Step) -> String {
        switch step {
        case .song: return "SONG"
        case .package: return "PACKAGE"
        case .review: return "SEND"
        case .done: return ""
        }
    }

    // MARK: - Step 1: song

    private var songStep: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tell us about your song")
                    .appFont(20, weight: .bold, design: .rounded)
                    .foregroundColor(Theme.text)

                field(
                    title: "Artist name",
                    placeholder: "e.g. Kai Nova",
                    text: $artist,
                    error: showErrors && trimmedArtist.isEmpty ? "Enter your artist name." : nil
                )
                field(
                    title: "Song title",
                    placeholder: "e.g. Glasshouse",
                    text: $songTitle,
                    error: showErrors && trimmedTitle.isEmpty ? "Enter the song title." : nil
                )
                field(
                    title: "Song link",
                    placeholder: "https://open.spotify.com/track/…",
                    text: $songLink,
                    keyboard: .URL,
                    hint: "Paste your Spotify link (or another streaming link).",
                    error: showErrors && !isLinkValid ? "Enter a valid link starting with https://" : nil
                )

                VStack(alignment: .leading, spacing: 8) {
                    fieldLabel("Genre")
                    FlowChips(items: Genres.all, selected: genre) { genre = $0 }
                }
            }
            .card(padding: 18)

            Button {
                if isSongValid {
                    showErrors = false
                    withAnimation { step = .package }
                } else {
                    showErrors = true
                }
            } label: {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())

            VStack(alignment: .leading, spacing: 8) {
                Text("Just want to send a song for free?")
                    .appFont(14, weight: .bold)
                    .foregroundColor(Theme.text)
                Text("The free form is open to everyone. Placement is not guaranteed.")
                    .appFont(12.5)
                    .foregroundColor(Theme.muted)
                Button {
                    showFreeForm = true
                } label: {
                    Text("Open free submission form")
                }
                .buttonStyle(GhostButtonStyle())
            }
            .card(padding: 16)
        }
    }

    // MARK: - Step 2: package

    private var packageStep: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PromoCategory.allCases) { c in
                        let on = category == c
                        Button {
                            category = c
                        } label: {
                            Text(c.chipTitle)
                                .appFont(13.5, weight: on ? .bold : .semibold)
                                .foregroundColor(on ? Theme.ctaText : Theme.muted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    Group {
                                        if on { Capsule().fill(Theme.cta) } else { Capsule().fill(Theme.surface.opacity(0.6)) }
                                    }
                                )
                                .overlay(Capsule().stroke(on ? Color.clear : Theme.line2, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(spacing: 10) {
                ForEach(PromotionCatalog.packages(for: category)) { package in
                    let on = selectedPackage?.id == package.id
                    Button {
                        selectedPackage = package
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                                .appFont(22)
                                .foregroundColor(on ? Theme.magenta : Theme.faint)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(package.name)
                                        .appFont(12.5, weight: .heavy)
                                        .tracking(0.6)
                                        .foregroundColor(Theme.muted)
                                    if let badge = package.badge {
                                        Pill(text: badge, color: Theme.amberText)
                                    }
                                }
                                Text(package.headline)
                                    .appFont(20, weight: .black, design: .rounded)
                                    .foregroundColor(Theme.text)
                                Text(package.details.joined(separator: " · "))
                                    .appFont(12.5)
                                    .foregroundColor(Theme.muted)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card(padding: 14, highlighted: on)
                    }
                    .buttonStyle(.plain)
                }
            }

            if showErrors && selectedPackage == nil {
                Text("Pick a package to continue.")
                    .font(.footnote)
                    .foregroundColor(Theme.danger)
            }

            HStack(spacing: 10) {
                Button {
                    withAnimation { step = .song }
                } label: {
                    Text("Back")
                }
                .buttonStyle(GhostButtonStyle())

                Button {
                    if selectedPackage != nil {
                        showErrors = false
                        withAnimation { step = .review }
                    } else {
                        showErrors = true
                    }
                } label: {
                    Text("Review")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: - Step 3: review

    private var reviewStep: some View {
        VStack(spacing: 16) {
            if let package = selectedPackage {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Review your order")
                        .appFont(20, weight: .bold, design: .rounded)
                        .foregroundColor(Theme.text)

                    summaryRow("Artist", trimmedArtist)
                    summaryRow("Song", trimmedTitle)
                    summaryRow("Link", trimmedLink)
                    summaryRow("Genre", genre)

                    Divider().overlay(Theme.line)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.name)
                            .appFont(12.5, weight: .heavy)
                            .tracking(0.6)
                            .foregroundColor(Theme.muted)
                        Text(package.headline)
                            .appFont(22, weight: .black, design: .rounded)
                            .foregroundColor(Theme.text)
                        ForEach(package.details, id: \.self) { d in
                            Label(d, systemImage: "checkmark.circle.fill")
                                .appFont(13)
                                .foregroundColor(Theme.muted)
                        }
                    }
                }
                .card(padding: 18)

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lock.shield.fill").foregroundColor(Theme.amberText)
                    Text("Nothing is charged in this app. Our team replies on WhatsApp with the price and payment details.")
                        .appFont(12.5)
                        .foregroundColor(Theme.amberText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(Theme.amber.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.amber.opacity(0.3), lineWidth: 1))

                legalLinks

                HStack(spacing: 10) {
                    Button {
                        withAnimation { step = .package }
                    } label: {
                        Text("Back")
                    }
                    .buttonStyle(GhostButtonStyle())

                    Button {
                        send(package)
                    } label: {
                        Label("Send on WhatsApp", systemImage: "paperplane.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            } else {
                Button {
                    withAnimation { step = .package }
                } label: {
                    Text("Choose a package")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var legalLinks: some View {
        HStack(spacing: 4) {
            Text("By sending you agree to our")
                .appFont(11.5)
                .foregroundColor(Theme.faint)
            NavigationLink {
                LegalDocumentView(title: "Terms of Use", updated: LegalContent.updated,
                                  sections: LegalContent.terms)
            } label: {
                Text("Terms").underline()
                    .appFont(11.5, weight: .semibold)
                    .foregroundColor(Theme.magentaText)
            }
            Text("and")
                .appFont(11.5)
                .foregroundColor(Theme.faint)
            NavigationLink {
                LegalDocumentView(title: "Privacy Policy", updated: LegalContent.updated,
                                  sections: LegalContent.privacy)
            } label: {
                Text("Privacy Policy").underline()
                    .appFont(11.5, weight: .semibold)
                    .foregroundColor(Theme.magentaText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Done

    private var doneStep: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 30)
            ZStack {
                Circle()
                    .fill(Theme.success.opacity(0.15))
                    .frame(width: 96, height: 96)
                Circle()
                    .stroke(Theme.success, lineWidth: 2)
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .appFont(40, weight: .bold)
                    .foregroundColor(Theme.successText)
            }
            Text("Order ready on WhatsApp")
                .appFont(26, weight: .black, design: .rounded)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
            Text("Send the message in WhatsApp to reach our team about your \(lastSentPackageName). If WhatsApp didn't open, you can send it again from My Requests.")
                .appFont(14)
                .foregroundColor(Theme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    router.tab = .requests
                } label: {
                    Text("View my requests")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    resetForm()
                } label: {
                    Text("Submit another song")
                }
                .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func send(_ package: PromoPackage) {
        let message = Contact.order(
            artist: trimmedArtist,
            song: trimmedTitle,
            link: trimmedLink,
            genre: genre,
            package: package
        )
        store.add(
            SongRequest(
                artistName: trimmedArtist,
                songTitle: trimmedTitle,
                songLink: trimmedLink,
                genre: genre,
                packageID: package.id,
                packageName: package.name,
                categoryTitle: package.category.chipTitle
            )
        )
        lastSentPackageName = package.name
        if let url = Contact.whatsappURL(message: message) {
            openURL(url)
        }
        withAnimation { step = .done }
    }

    private func resetForm() {
        songTitle = ""
        songLink = ""
        selectedPackage = nil
        showErrors = false
        withAnimation { step = .song }
    }

    // MARK: - Small views

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .appFont(12, weight: .bold)
            .tracking(1)
            .foregroundColor(Theme.muted)
    }

    private func field(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        hint: String? = nil,
        error: String? = nil
    ) -> some View {
        let isURL = keyboard == .URL
        let capitalization: TextInputAutocapitalization = isURL ? .never : .words
        return VStack(alignment: .leading, spacing: 6) {
            fieldLabel(title)
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.faint))
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled(isURL)
                .appFont(15.5)
                .foregroundColor(Theme.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Theme.bg.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(error == nil ? Theme.line2 : Theme.danger, lineWidth: 1)
                )
            if let error {
                Text(error)
                    .appFont(12)
                    .foregroundColor(Theme.danger)
            } else if let hint {
                Text(hint)
                    .appFont(11.5)
                    .foregroundColor(Theme.faint)
            }
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .appFont(13)
                .foregroundColor(Theme.faint)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .appFont(14.5, weight: .semibold)
                .foregroundColor(Theme.text)
                .lineLimit(2)
                .truncationMode(.middle)
            Spacer(minLength: 0)
        }
    }
}

/// Wrapping chips for single selection.
struct FlowChips: View {
    let items: [String]
    let selected: String
    let onSelect: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                let on = item == selected
                Button {
                    onSelect(item)
                } label: {
                    Text(item)
                        .appFont(13, weight: on ? .bold : .semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(on ? Theme.ctaText : Theme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if on { Capsule().fill(Theme.cta) } else { Capsule().fill(Theme.surface.opacity(0.6)) }
                            }
                        )
                        .overlay(Capsule().stroke(on ? Color.clear : Theme.line2, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
