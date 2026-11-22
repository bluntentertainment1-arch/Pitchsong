import SwiftUI
import SafariServices

/// Shows a web page (the free submission form) inside the app.
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredBarTintColor = UIColor(Theme.bg)
        controller.preferredControlTintColor = UIColor(Theme.magenta)
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
