import SwiftUI

// All packages below are copied from the Blunt Entertainment / Findock website (PromotionPage.tsx).
// Prices are NOT shown in the app: they are agreed with the team on WhatsApp.

enum PromoCategory: String, CaseIterable, Identifiable {
    case spotify, tiktok, instagram, blog, combo

    var id: String { rawValue }

    /// Short label used on chips.
    var chipTitle: String {
        switch self {
        case .spotify: return "Spotify"
        case .tiktok: return "TikTok"
        case .instagram: return "Instagram"
        case .blog: return "Blogs & Press"
        case .combo: return "Combos"
        }
    }

    /// Title on the home tiles.
    var tileTitle: String {
        switch self {
        case .spotify: return "Spotify Playlist Promotion"
        case .tiktok: return "TikTok Music Marketing"
        case .instagram: return "Instagram Music Campaign"
        case .blog: return "Press Release Campaigns"
        case .combo: return "Full Promotion Combos"
        }
    }

    /// Title on the packages page.
    var pageTitle: String {
        switch self {
        case .spotify: return "Spotify Playlist Promotion"
        case .tiktok: return "TikTok Sound Use Promotion"
        case .instagram: return "Instagram Sound Use Promotion"
        case .blog: return "Music Blog/Website Promotion"
        case .combo: return "FULL Music Promotion Packages (multiple platforms)"
        }
    }

    var blurb: String {
        switch self {
        case .spotify: return "Pitch your song to playlist curators and reach new listeners."
        case .tiktok: return "Promote your track through creators who use your sound."
        case .instagram: return "Promote your music on Instagram Reels and posts."
        case .blog: return "Get your music in front of music blogs and websites."
        case .combo: return "Promotion across several platforms in one package."
        }
    }

    var symbol: String {
        switch self {
        case .spotify: return "music.note.list"
        case .tiktok: return "play.rectangle.fill"
        case .instagram: return "camera.fill"
        case .blog: return "newspaper.fill"
        case .combo: return "flame.fill"
        }
    }

    var gradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .spotify: colors = [Color(hex: 0x1DB954), Color(hex: 0x16A34A)]
        case .tiktok: colors = [Theme.magenta, Color(hex: 0xDB2777)]
        case .instagram: colors = [Theme.violet, Theme.magenta]
        case .blog: colors = [Theme.blue, Color(hex: 0x2563EB)]
        case .combo: colors = [Theme.orange, Color(hex: 0xDC2626)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct PromoPackage: Identifiable, Hashable {
    let category: PromoCategory
    let slug: String
    let name: String
    let features: [String]
    var badge: String? = nil

    var id: String { "\(category.rawValue)-\(slug)" }

    /// First feature is the headline (e.g. "30 Videos", "10 Playlists").
    var headline: String { features.first ?? name }
    var details: [String] { Array(features.dropFirst()) }
}

enum PromotionCatalog {
    private static func p(
        _ c: PromoCategory,
        _ slug: String,
        _ name: String,
        _ features: [String],
        badge: String? = nil
    ) -> PromoPackage {
        PromoPackage(category: c, slug: slug, name: name, features: features, badge: badge)
    }

    static let all: [PromoPackage] = [
        // ---------- Spotify (7) ----------
        p(.spotify, "starter", "STARTER PACKAGE",
          ["10 Playlists", "Est. 3,000 streams", "Perfect start for new releases"]),
        p(.spotify, "standard", "STANDARD PACKAGE",
          ["15 Playlists", "Est. 4,000 streams", "A solid step up in exposure"]),
        p(.spotify, "premium", "PREMIUM PACKAGE",
          ["20 Playlists", "Est. 6,000 streams", "Wider playlist exposure"]),
        p(.spotify, "professional", "PROFESSIONAL PACKAGE",
          ["22 Playlists", "Est. 10,000 streams", "Focused promotion for growing artists"],
          badge: "RECOMMENDED"),
        p(.spotify, "exposure", "EXPOSURE PACKAGE",
          ["24 Playlists", "Est. 20,000 streams", "More reach and audience engagement"],
          badge: "POPULAR"),
        p(.spotify, "superstar", "SUPERSTAR PACKAGE",
          ["25 Playlists", "Est. 50,000 streams", "Large-scale playlist promotion"]),
        p(.spotify, "alist", "A-LIST PACKAGE",
          ["30 Playlists", "Est. 100,000 streams", "Our biggest playlist campaign"],
          badge: "TOP TIER"),

        // ---------- TikTok (6) ----------
        p(.tiktok, "starter", "TIKTOK STARTER PACKAGE",
          ["30 Videos", "Independent TikTok creators", "Organic promotion"]),
        p(.tiktok, "standard", "TIKTOK STANDARD PACKAGE",
          ["50 Videos", "Independent TikTok creators", "Organic promotion"]),
        p(.tiktok, "professional", "TIKTOK PROFESSIONAL PACKAGE",
          ["100 Videos", "Independent TikTok creators", "Organic promotion"],
          badge: "POPULAR"),
        p(.tiktok, "trending", "TIKTOK TRENDING PACKAGE",
          ["250 Videos", "Independent TikTok creators", "Organic promotion"]),
        p(.tiktok, "discovery", "TIKTOK DISCOVERY PACKAGE",
          ["500 Videos", "Independent TikTok creators", "Organic promotion"]),
        p(.tiktok, "breakout", "TIKTOK BREAKOUT PACKAGE",
          ["1000 Videos", "Independent TikTok creators", "Organic promotion"]),

        // ---------- Instagram (4) ----------
        p(.instagram, "starter", "INSTAGRAM STARTER",
          ["50 sound uses", "Independent Instagram creators", "Reels & Posts"]),
        p(.instagram, "standard", "INSTAGRAM STANDARD",
          ["100 sound uses", "Independent Instagram creators", "Reels & Posts"],
          badge: "POPULAR"),
        p(.instagram, "professional", "INSTAGRAM PROFESSIONAL",
          ["200 sound uses", "Independent Instagram creators", "Reels & Posts"]),
        p(.instagram, "viral", "INSTAGRAM VIRAL",
          ["500 sound uses", "Independent Instagram creators", "Reels & Posts"]),

        // ---------- Blogs (6) ----------
        p(.blog, "starter", "3 BLOG POSTS",
          ["3 Blog posts", "Music/Entertainment websites", "Helps your online visibility"]),
        p(.blog, "standard", "6 BLOG POSTS",
          ["6 Blog posts", "Music/Entertainment websites", "Helps your online visibility"],
          badge: "POPULAR"),
        p(.blog, "professional", "10 BLOG POSTS",
          ["10 Blog posts", "Music/Entertainment websites", "Helps your online visibility"]),
        p(.blog, "premium", "15 BLOG POSTS",
          ["15 Blog posts", "Music/Entertainment websites", "Helps your online visibility"]),
        p(.blog, "elite", "20 BLOG POSTS",
          ["20 Blog posts", "Music/Entertainment websites", "Helps your online visibility"]),
        p(.blog, "ultimate", "25 BLOG POSTS",
          ["25 Blog posts", "Music/Entertainment websites", "Helps your online visibility"]),

        // ---------- Combos (6) ----------
        p(.combo, "starter", "STARTER COMBO",
          ["30 TikTok videos", "50 Instagram uses", "10 Spotify playlists (est. 3k streams)", "3 blog posts"]),
        p(.combo, "growth", "GROWTH COMBO",
          ["50 TikTok videos", "100 Instagram uses", "22 Spotify playlists (est. 10k streams)", "6 blog posts"],
          badge: "POPULAR"),
        p(.combo, "pro", "PRO COMBO",
          ["100 TikTok videos", "200 Instagram uses", "24 Spotify playlists (est. 20k streams)", "10 blog posts"]),
        p(.combo, "viral", "VIRAL COMBO",
          ["200 TikTok videos", "300 Instagram uses", "25 Spotify playlists (est. 30k streams)", "10 blog posts"]),
        p(.combo, "elite", "ELITE COMBO",
          ["500 TikTok videos", "500 Instagram uses", "25 Spotify playlists (est. 50k streams)", "15 blog posts"]),
        p(.combo, "gatekeepers", "GATEKEEPERS COMBO",
          ["1000 TikTok videos", "500 Instagram uses", "30 Spotify playlists (est. 100k streams)", "25 blog posts"])
    ]

    static func packages(for category: PromoCategory) -> [PromoPackage] {
        all.filter { $0.category == category }
    }

    static func package(id: String) -> PromoPackage? {
        all.first { $0.id == id }
    }
}

enum Genres {
    static let all = [
        "Afrobeats", "Afropop", "Amapiano", "Hip-Hop", "R&B", "Pop",
        "Dancehall", "Gospel", "Highlife", "Rock", "Electronic", "Other"
    ]
}
