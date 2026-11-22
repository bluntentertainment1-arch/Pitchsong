import SwiftUI

struct PackagesView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 14, alignment: .top)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    ScreenHeader(
                        kicker: "Promotion packages",
                        title: "Pick your push.",
                        subtitle: "Choose a package, then confirm the price with our team on WhatsApp. Payment is arranged there, never inside the app."
                    ).withMenu()

                    categoryChips

                    VStack(alignment: .leading, spacing: 4) {
                        Text(router.packagesCategory.pageTitle)
                            .appFont(18, weight: .bold, design: .rounded)
                            .foregroundColor(Theme.text)
                        Text(router.packagesCategory.blurb)
                            .appFont(13.5)
                            .foregroundColor(Theme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(PromotionCatalog.packages(for: router.packagesCategory)) { package in
                            PackageCard(package: package)
                        }
                    }

                    Text(Legal.short)
                        .appFont(11.5)
                        .foregroundColor(Theme.faint)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .readableWidth()
            }
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PromoCategory.allCases) { category in
                    let selected = router.packagesCategory == category
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            router.packagesCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.symbol)
                            Text(category.chipTitle)
                        }
                        .appFont(13.5, weight: selected ? .bold : .semibold)
                        .foregroundColor(selected ? Theme.ctaText : Theme.muted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if selected {
                                    Capsule().fill(Theme.cta)
                                } else {
                                    Capsule().fill(Theme.surface.opacity(0.6))
                                }
                            }
                        )
                        .overlay(Capsule().stroke(selected ? Color.clear : Theme.line2, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct PackageCard: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    let package: PromoPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(package.name)
                    .appFont(13, weight: .heavy)
                    .tracking(0.8)
                    .foregroundColor(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if let badge = package.badge {
                    Text(badge)
                        .appFont(10, weight: .heavy)
                        .tracking(0.8)
                        .foregroundColor(Theme.ctaText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.cta)
                        .clipShape(Capsule())
                }
            }

            Text(package.headline)
                .appFont(26, weight: .black, design: .rounded)
                .foregroundColor(Theme.text)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(package.details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .appFont(14)
                            .foregroundColor(Theme.successText)
                            .padding(.top, 1)
                        Text(detail)
                            .appFont(13.5)
                            .foregroundColor(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Text("Results vary. Placement is up to each curator or creator.")
                .appFont(11.5)
                .foregroundColor(Theme.faint)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 4)

            VStack(spacing: 8) {
                Button {
                    router.startOrder(package)
                } label: {
                    Text("Order this package")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    if let url = Contact.whatsappURL(message: Contact.packageInquiry(package)) {
                        openURL(url)
                    }
                } label: {
                    Label("Ask on WhatsApp", systemImage: "message.fill")
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .card(padding: 18, highlighted: package.badge != nil)
    }
}
