import Foundation

/// Contact details taken from the Blunt Entertainment website.
enum Contact {
    /// Number the website uses for package orders (international format, no "+").
    static let whatsappNumber = "2347087934907"
    static let whatsappDisplay = "+234 708 793 4907"

    /// General "contact us" link from the website home page.
    static let whatsappGeneralLink = URL(string: "https://wa.me/message/I5ASBQKJQKJCF1")!

    static let email = "bluntentertainment1@gmail.com"
    static let instagramHandle = "@bluntt_kidd"
    static let instagramURL = URL(string: "https://instagram.com/bluntt_kidd")!

    // MARK: WhatsApp

    private static func encode(_ text: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? text
    }

    static func whatsappURL(message: String) -> URL? {
        URL(string: "https://wa.me/\(whatsappNumber)?text=\(encode(message))")
    }

    /// Quick question about a package (same wording as the website).
    static func packageInquiry(_ package: PromoPackage) -> String {
        var text = "Hi! I'm interested in the \(package.name).\n\n"
        text += "Features:\n"
        text += package.features.map { "- \($0)" }.joined(separator: "\n")
        text += "\n\nCould you please provide more information about pricing and how to get started?"
        return text
    }

    /// Full order including the artist's song details.
    static func order(
        artist: String,
        song: String,
        link: String,
        genre: String,
        package: PromoPackage
    ) -> String {
        var text = "Hi Blunt Entertainment! I'd like to order a promotion through the Pitchsong app.\n\n"
        text += "Package: \(package.name) (\(package.category.chipTitle))\n"
        text += package.features.map { "- \($0)" }.joined(separator: "\n")
        text += "\n\nArtist: \(artist)\n"
        text += "Song: \(song)\n"
        text += "Link: \(link)\n"
        text += "Genre: \(genre)\n\n"
        text += "Please send the price and how to pay so we can get started."
        return text
    }
}
