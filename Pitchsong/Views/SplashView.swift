import SwiftUI

/// Animated launch splash: glowing logo with pulsing rings and a moving sound wave.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appear = false
    @State private var pulse = false
    @State private var wave = false

    private let barHeights: [CGFloat] = [14, 26, 40, 24, 48, 30, 38, 20, 12]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 20) {
                ZStack {
                    ring(delay: 0)
                    ring(delay: 0.8)
                    BrandMark(size: 116)
                        .scaleEffect(appear ? 1 : 0.55)
                        .opacity(appear ? 1 : 0)
                }
                .frame(width: 230, height: 230)

                HStack(spacing: 5) {
                    ForEach(0..<barHeights.count, id: \.self) { index in
                        Capsule()
                            .fill(Theme.cta)
                            .frame(width: 5, height: wave ? barHeights[index] : 6)
                            .animation(barAnimation(index), value: wave)
                    }
                }
                .frame(height: 50)
                .shadow(color: Theme.magenta.opacity(0.6), radius: 10)

                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        Text("PITCH").foregroundColor(Theme.text)
                        Text("SONG").foregroundColor(Theme.orange)
                    }
                    .appFont(34, weight: .black, design: .rounded)
                    .tracking(3)
                    Text("by Blunt Entertainment")
                        .appFont(14, weight: .medium)
                        .foregroundColor(Theme.muted)
                    Text("Pitch your sound.")
                        .appFont(13)
                        .foregroundColor(Theme.magentaText)
                        .padding(.top, 6)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 14)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                appear = true
            }
            wave = true
            if !reduceMotion {
                pulse = true
            }
        }
    }

    private func barAnimation(_ index: Int) -> Animation? {
        if reduceMotion { return nil }
        return Animation.easeInOut(duration: 0.55)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.07)
    }

    private func ring(delay: Double) -> some View {
        Circle()
            .stroke(Theme.cta, lineWidth: 2)
            .frame(width: 140, height: 140)
            .scaleEffect(pulse ? 1.65 : 0.85)
            .opacity(pulse ? 0 : 0.8)
            .animation(
                .easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(delay),
                value: pulse
            )
    }
}
