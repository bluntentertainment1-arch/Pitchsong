import SwiftUI

enum AppTab: Hashable {
    case home, packages, submit, requests
}

/// Lets any screen switch tabs, open the Menu, and hand a chosen package to the order form.
final class AppRouter: ObservableObject {
    @Published var tab: AppTab = .home
    @Published var packagesCategory: PromoCategory = .spotify
    @Published var preselectedPackageID: String? = nil
    @Published var showMenu = false

    func startOrder(_ package: PromoPackage) {
        preselectedPackageID = package.id
        showMenu = false
        tab = .submit
    }

    func openCategory(_ category: PromoCategory) {
        packagesCategory = category
        showMenu = false
        tab = .packages
    }
}
