import StoreKit
import UIKit

enum ReviewManager {
    /// The "Rate app" button. With an App Store ID it opens the review page directly
    /// (Apple allows this link); without one it asks iOS to show the rating sheet.
    static func rateApp() {
        if let url = AppConfig.writeReviewURL {
            UIApplication.shared.open(url)
        } else {
            requestInAppReview()
        }
    }

    /// Asks iOS to show its standard rating prompt. iOS decides whether it actually appears
    /// (it limits how often any app can show it), so this never forces a dialog.
    static func requestInAppReview() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
