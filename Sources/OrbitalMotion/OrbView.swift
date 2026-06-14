#if canImport(SwiftUI)
import SwiftUI

/// A glassmorphism talking-AI orb that animates reactively based on OrbState.
public struct OrbView: View {
    public let state: OrbState
    public var size: CGFloat

    @State private var pulsing = false

    public init(state: OrbState, size: CGFloat = 160) {
        self.state = state
        self.size = size
    }

    public var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [innerColor.opacity(state.glowOpacity), .clear],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: size * 0.18)
                .scaleEffect(pulsing ? 1.12 : 0.92)

            // Orb body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [innerColor, outerColor],
                        center: .init(x: 0.38, y: 0.32),
                        startRadius: size * 0.05,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(pulsing ? state.baseScale * 1.04 : state.baseScale * 0.97)
                // Glass specular highlight
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.45), .clear],
                                center: .init(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: size * 0.4
                            )
                        )
                )
                .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .onAppear { startPulse() }
        .onChange(of: state) { _ in
            pulsing = false
            startPulse()
        }
        .animation(.easeInOut(duration: 0.35), value: state)
    }

    // MARK: - Private

    private var innerColor: Color {
        switch state {
        case .idle:      return Color(hue: 0.62, saturation: 0.7, brightness: 0.9)
        case .listening: return Color(hue: 0.55, saturation: 0.8, brightness: 1.0)
        case .thinking:  return Color(hue: 0.75, saturation: 0.6, brightness: 0.85)
        case .speaking:  return Color(hue: 0.50, saturation: 0.7, brightness: 1.0)
        }
    }

    private var outerColor: Color {
        switch state {
        case .idle:      return Color(hue: 0.72, saturation: 0.8, brightness: 0.8)
        case .listening: return Color(hue: 0.65, saturation: 0.9, brightness: 0.9)
        case .thinking:  return Color(hue: 0.82, saturation: 0.7, brightness: 0.75)
        case .speaking:  return Color(hue: 0.60, saturation: 0.9, brightness: 0.95)
        }
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: state.pulseSpeed).repeatForever(autoreverses: true)) {
            pulsing = true
        }
    }
}

// MARK: - Preview

struct OrbView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 24) {
            VStack {
                OrbView(state: .idle, size: 100)
                Text("idle").font(.caption)
            }
            VStack {
                OrbView(state: .listening, size: 100)
                Text("listening").font(.caption)
            }
            VStack {
                OrbView(state: .thinking, size: 100)
                Text("thinking").font(.caption)
            }
            VStack {
                OrbView(state: .speaking(audioLevel: 0.8), size: 100)
                Text("speaking").font(.caption)
            }
        }
        .padding()
        .background(.black)
    }
}
#endif
