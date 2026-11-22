import SwiftUI

// MARK: - Colors (same palette as the PitchWave web demo)

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension Color {
    /// A color that changes with the app's light / dark appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(
            UIColor { traits in
                let hex = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: CGFloat((hex >> 16) & 0xFF) / 255,
                    green: CGFloat((hex >> 8) & 0xFF) / 255,
                    blue: CGFloat(hex & 0xFF) / 255,
                    alpha: 1
                )
            }
        )
    }
}

enum Theme {
    // Surfaces and text adapt to light / dark mode.
    static let bg = Color(light: 0xF6F2FD, dark: 0x0C0713)
    static let bg2 = Color(light: 0xEEE7FA, dark: 0x140B20)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1A1029)
    static let surface2 = Color(light: 0xEFE8FB, dark: 0x221537)
    static let line = Color(hex: 0xA78BFA, opacity: 0.22)
    static let line2 = Color(hex: 0x8B5CF6, opacity: 0.36)

    static let text = Color(light: 0x1B1030, dark: 0xF4EEFC)
    static let muted = Color(light: 0x5E5280, dark: 0xA89AC6)
    static let faint = Color(light: 0x857AA3, dark: 0x7A6B9C)

    // Bright brand colors: used for gradients, glows and fills (same in both modes).
    static let violet = Color(hex: 0x8B5CF6)
    static let violet2 = Color(hex: 0xA78BFA)
    static let magenta = Color(hex: 0xFF3D8A)
    static let orange = Color(hex: 0xFF7A3D)
    static let amber = Color(hex: 0xFFB224)
    static let cyan = Color(hex: 0x3FD0FF)
    static let blue = Color(hex: 0x4D7DFF)
    static let success = Color(hex: 0x3DDC97)

    // Same hues, darker in light mode so small text stays readable.
    static let magentaText = Color(light: 0xC71F66, dark: 0xFF3D8A)
    static let amberText = Color(light: 0xB45309, dark: 0xFFB224)
    static let cyanText = Color(light: 0x0E7490, dark: 0x3FD0FF)
    static let successText = Color(light: 0x15803D, dark: 0x3DDC97)
    static let violet2Text = Color(light: 0x6D28D9, dark: 0xA78BFA)
    static let danger = Color(light: 0xD91F3F, dark: 0xFF5470)

    static let ctaText = Color(hex: 0x20081A)

    static let cta = LinearGradient(
        colors: [magenta, orange, amber],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let cool = LinearGradient(
        colors: [magenta, violet, cyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Maximum width of content so iPad screens stay readable.
    static let contentWidth: CGFloat = 760
}

// MARK: - Background

/// Glowing abstract aurora: soft drifting light orbs plus two slowly turning neon rings.
/// Sizes scale with the screen, so it looks right on iPhone and iPad. Motion stops when
/// the user turns on Reduce Motion.
struct AppBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var drift = false
    @State private var spin = false

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let m = max(size.width, size.height)

            ZStack {
                Theme.bg

                orb(Theme.magenta, diameter: m * 0.85, opacity: 0.50,
                    x: size.width * (drift ? 0.05 : 0.25), y: size.height * (drift ? 0.08 : 0.20))
                orb(Theme.violet, diameter: m * 0.95, opacity: 0.50,
                    x: size.width * (drift ? 0.95 : 0.75), y: size.height * (drift ? 0.92 : 0.78))
                orb(Theme.cyan, diameter: m * 0.55, opacity: 0.22,
                    x: size.width * (drift ? 0.85 : 0.60), y: size.height * (drift ? 0.30 : 0.45))
                orb(Theme.amber, diameter: m * 0.40, opacity: 0.16,
                    x: size.width * (drift ? 0.15 : 0.35), y: size.height * (drift ? 0.70 : 0.55))

                ring(diameter: m * 1.05, lineWidth: 3, opacity: 0.30, rotation: spin ? 360 : 0)
                    .position(x: size.width * 0.95, y: size.height * 0.12)
                ring(diameter: m * 0.75, lineWidth: 2, opacity: 0.22, rotation: spin ? -360 : 0)
                    .position(x: size.width * 0.02, y: size.height * 0.92)

                // gentle dark vignette keeps text readable
                LinearGradient(
                    colors: [Theme.bg.opacity(0.0), Theme.bg.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 16).repeatForever(autoreverses: true)) {
                drift = true
            }
            withAnimation(.linear(duration: 80).repeatForever(autoreverses: false)) {
                spin = true
            }
        }
    }

    private func orb(_ color: Color, diameter: CGFloat, opacity: Double, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(colorScheme == .dark ? opacity : opacity * 0.55), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter / 2
                )
            )
            .frame(width: diameter, height: diameter)
            .blendMode(colorScheme == .dark ? .plusLighter : .normal)
            .position(x: x, y: y)
    }

    private func ring(diameter: CGFloat, lineWidth: CGFloat, opacity: Double, rotation: Double) -> some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [Theme.magenta, Theme.violet, Theme.cyan, Theme.amber, Theme.magenta],
                    center: .center
                ),
                lineWidth: lineWidth
            )
            .frame(width: diameter, height: diameter)
            .blur(radius: 5)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Dynamic Type friendly fonts

struct AppFontModifier: ViewModifier {
    @ScaledMetric private var scaledSize: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, weight: Font.Weight, design: Font.Design) {
        _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: .body)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize, weight: weight, design: design))
    }
}

extension View {
    /// Fixed design sizes that still grow with the user's text-size setting.
    func appFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(AppFontModifier(size: size, weight: weight, design: design))
    }
}

// MARK: - Card & text helpers

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                highlighted ? Theme.magenta.opacity(0.10) : Theme.surface,
                                Theme.surface.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        highlighted
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Theme.magenta.opacity(0.9), Theme.violet.opacity(0.6), Theme.cyan.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                            : AnyShapeStyle(Theme.line),
                        lineWidth: highlighted ? 1.4 : 1
                    )
            )
            .shadow(
                color: highlighted ? Theme.magenta.opacity(0.38) : Theme.violet.opacity(0.14),
                radius: highlighted ? 20 : 12,
                x: 0,
                y: 6
            )
    }
}

/// Centers content and limits its width so iPad layouts stay readable.
struct ReadableWidthModifier: ViewModifier {
    var maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func card(padding: CGFloat = 16, highlighted: Bool = false) -> some View {
        modifier(CardStyle(padding: padding, highlighted: highlighted))
    }

    /// Wide content (lists and grids) can use up to 1000 pt on iPad; forms pass a smaller value.
    func readableWidth(_ maxWidth: CGFloat = 1000) -> some View {
        modifier(ReadableWidthModifier(maxWidth: maxWidth))
    }
}

struct GradientText: View {
    let text: String
    var font: Font = .body
    var gradient: LinearGradient = Theme.cool

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(.clear)
            .overlay(gradient.mask(Text(text).font(font)))
            .shadow(color: Theme.magenta.opacity(0.55), radius: 16, x: 0, y: 0)
    }
}

struct Kicker: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .appFont(11, weight: .bold)
            .tracking(2.2)
            .foregroundColor(Theme.magentaText)
    }
}

struct ScreenHeader: View {
    let kicker: String
    let title: String
    var subtitle: String? = nil
    var showsMenu = false

    /// Adds the hamburger Menu button on the right.
    func withMenu() -> ScreenHeader {
        var copy = self
        copy.showsMenu = true
        return copy
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            content
            if showsMenu {
                MenuButton()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            Kicker(text: kicker)
            Text(title)
                .appFont(30, weight: .black, design: .rounded)
                .foregroundColor(Theme.text)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appFont(15, weight: .bold)
            .foregroundColor(Theme.ctaText)
            .padding(.vertical, 13)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Theme.cta)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .shadow(color: Theme.magenta.opacity(0.55), radius: 16, x: 0, y: 4)
            .shadow(color: Theme.amber.opacity(0.25), radius: 26, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appFont(15, weight: .semibold)
            .foregroundColor(Theme.text)
            .padding(.vertical, 13)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Theme.surface2.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(Theme.line2, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

// MARK: - Brand mark (same glyph as the app icon)

struct BrandGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 32
        var p = Path()
        p.addRoundedRect(
            in: CGRect(x: 6 * s, y: 13 * s, width: 3.5 * s, height: 9 * s),
            cornerSize: CGSize(width: 1.75 * s, height: 1.75 * s)
        )
        p.addRoundedRect(
            in: CGRect(x: 12 * s, y: 8 * s, width: 3.5 * s, height: 16 * s),
            cornerSize: CGSize(width: 1.75 * s, height: 1.75 * s)
        )
        p.move(to: CGPoint(x: 19 * s, y: 10 * s))
        p.addLine(to: CGPoint(x: 27 * s, y: 16 * s))
        p.addLine(to: CGPoint(x: 19 * s, y: 22 * s))
        p.closeSubpath()
        return p
    }
}

struct BrandMark: View {
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .fill(Theme.surface2)
            BrandGlyph()
                .fill(Theme.cta)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .stroke(Theme.line2, lineWidth: 1)
        )
        .shadow(color: Theme.orange.opacity(0.55), radius: size * 0.3, x: 0, y: 0)
    }
}

struct BrandHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            BrandMark(size: 38)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("PITCH")
                        .foregroundColor(Theme.text)
                    Text("SONG")
                        .foregroundColor(Theme.orange)
                }
                .appFont(17, weight: .black, design: .rounded)
                .tracking(1.2)
                Text("by Blunt Entertainment")
                    .appFont(11, weight: .medium)
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            MenuButton()
        }
    }
}

// MARK: - Pill

struct Pill: View {
    let text: String
    var color: Color = Theme.violet2Text

    var body: some View {
        Text(text)
            .appFont(11.5, weight: .bold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
    }
}
