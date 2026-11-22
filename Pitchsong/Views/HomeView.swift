import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL
    @State private var showFreeForm = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ScaledMetric(relativeTo: .largeTitle) private var baseHero: CGFloat = 38

    private var heroSize: CGFloat { sizeClass == .regular ? baseHero * 1.45 : baseHero }

    private let categoryColumns = [GridItem(.adaptive(minimum: 240), spacing: 14)]
    private let whyColumns = [GridItem(.adaptive(minimum: 220), spacing: 14)]

    private let steps: [(String, String, String)] = [
        ("music.note", "Submit your song", "Add your song link, genre and the package you like."),
        ("square.grid.2x2", "Pick a package", "Spotify, TikTok, Instagram, blogs or a full combo."),
        ("message.fill", "Confirm on WhatsApp", "Our team sends the price and payment details. Nothing is charged in the app."),
        ("waveform", "We run your campaign", "We pitch your song to playlist curators, creators and blogs. They decide what to feature.")
    ]

    private let reasons: [(String, String, String)] = [
        ("target", "Audience-first", "We aim for genuine engagement and organic growth."),
        ("bolt.fill", "Fast campaign setup", "Setup typically takes 24–72 hours after confirmation."),
        ("banknote", "Affordable pricing", "Budget-friendly packages for upcoming artists."),
        ("globe.africa.fill", "Global + African market", "Strong understanding of both markets.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    BrandHeader()
                    hero
                    categories
                    howItWorks
                    why
                    proof
                    freeSubmission
                    contactCTA
                    disclaimer
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
                .readableWidth()
            }
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showFreeForm) {
            SafariView(url: Contact.freeSubmissionURL)
                .ignoresSafeArea()
        }
    }

    // MARK: Sections

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Kicker(text: "Music promotion · Nigeria, expanding to Africa & Europe")
            VStack(alignment: .leading, spacing: 0) {
                Text("Your sound,")
                    .font(.system(size: heroSize, weight: .black, design: .rounded))
                    .foregroundColor(Theme.text)
                GradientText(text: "in rotation.", font: .system(size: heroSize, weight: .black, design: .rounded))
            }
            Text("Promotion packages that help your music reach new listeners through playlist curators, creators and music blogs. You keep your rights. They keep the choice.")
                .appFont(15)
                .foregroundColor(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button {
                    router.tab = .submit
                } label: {
                    Text("Submit a song")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    router.tab = .packages
                } label: {
                    Text("See packages")
                }
                .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 4)
        }
        .card(padding: 22)
    }

    private var categories: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(kicker: "What we do", title: "Music growth & promotion")
            LazyVGrid(columns: categoryColumns, spacing: 14) {
                ForEach(PromoCategory.allCases) { category in
                    Button {
                        router.openCategory(category)
                    } label: {
                        CategoryTile(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(kicker: "How it works", title: "From link to launch")
            VStack(spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle().fill(Theme.surface2)
                            Text("\(index + 1)")
                                .appFont(14, weight: .heavy, design: .rounded)
                                .foregroundColor(Theme.amberText)
                        }
                        .frame(width: 32, height: 32)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.1)
                                .appFont(15, weight: .bold)
                                .foregroundColor(Theme.text)
                            Text(step.2)
                                .appFont(13)
                                .foregroundColor(Theme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .card(padding: 14)
                }
            }
        }
    }

    private var why: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(kicker: "Why artists work with us", title: "Built for upcoming artists")
            LazyVGrid(columns: whyColumns, spacing: 14) {
                ForEach(Array(reasons.enumerated()), id: \.offset) { _, reason in
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: reason.0)
                            .appFont(20, weight: .semibold)
                            .foregroundColor(Theme.magentaText)
                        Text(reason.1)
                            .appFont(15, weight: .bold)
                            .foregroundColor(Theme.text)
                        Text(reason.2)
                            .appFont(13)
                            .foregroundColor(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card(padding: 16)
                }
            }
        }
    }

    private var proof: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(kicker: "Example results", title: "A past campaign")
            VStack(spacing: 10) {
                AsyncImage(url: URL(string: "https://i.postimg.cc/RvXx3Qwm/3F072D0D-694E-40F2-AB9F-36001CE18EFF.jpg")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    case .failure:
                        Label("Screenshot unavailable offline", systemImage: "photo")
                            .font(.footnote)
                            .foregroundColor(Theme.faint)
                            .frame(maxWidth: .infinity, minHeight: 80)
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    }
                }
                Text("Example screenshot from Spotify for Artists for a past campaign. Results vary and are not guaranteed.")
                    .appFont(12)
                    .foregroundColor(Theme.muted)
                    .multilineTextAlignment(.center)
            }
            .card(padding: 14)
        }
    }

    private var freeSubmission: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill").foregroundColor(Theme.cyanText)
                Text("Free song submission")
                    .appFont(16, weight: .bold)
                    .foregroundColor(Theme.text)
            }
            Text("Not ready for a package? Send your song for free. Placement is not guaranteed. For a full campaign, pick any of our packages.")
                .appFont(13)
                .foregroundColor(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                showFreeForm = true
            } label: {
                Text("Open free submission form")
            }
            .buttonStyle(GhostButtonStyle())
        }
        .card(padding: 18)
    }

    private var contactCTA: some View {
        VStack(spacing: 12) {
            Text("Ready to push your music?")
                .appFont(22, weight: .black, design: .rounded)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
            Text("Let's turn your next release into visibility.")
                .appFont(14)
                .foregroundColor(Theme.muted)
            Button {
                openURL(Contact.whatsappGeneralLink)
            } label: {
                Label("Contact us on WhatsApp", systemImage: "message.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .card(padding: 22, highlighted: true)
    }

    private var disclaimer: some View {
        Text(Legal.short)
            .appFont(11.5)
            .foregroundColor(Theme.faint)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CategoryTile: View {
    let category: PromoCategory

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(category.gradient)
                Image(systemName: category.symbol)
                    .appFont(22, weight: .semibold)
                    .foregroundColor(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.tileTitle)
                    .appFont(15, weight: .bold)
                    .foregroundColor(Theme.text)
                    .multilineTextAlignment(.leading)
                Text(category.blurb)
                    .appFont(12.5)
                    .foregroundColor(Theme.muted)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Text("Choose package")
                    Image(systemName: "arrow.right")
                }
                .appFont(12.5, weight: .bold)
                .foregroundColor(Theme.amberText)
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 14)
    }
}

enum Legal {
    static let short = "Pitchsong is an independent promotion service by Blunt Entertainment. Results vary. Estimates are not promises, and no placement, stream count or follower growth is guaranteed. Playlist curators, creators and blogs always make their own decision to feature a song. We do not buy placements or sell fake streams. Not affiliated with, endorsed by, or sponsored by Spotify, TikTok, Instagram, WhatsApp or Apple."
}
