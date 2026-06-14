/// TalkingOrb — the settled design for the Orbital Motion team.
///
/// Design verdict (2026-06-14): Morphing iridescent sphere with audio-reactive glow.
/// Research rationale: orb/sphere form is the most recognisable and trusted shape for
/// voice AI (Siri, ChatGPT Advanced Voice). Iridescent colour-shift reduces static
/// brand dependence. Breathing idle + audio-reactive scale makes state unambiguous.
///
/// Usage:
///   TalkingOrb(state: .speaking(audioLevel: 0.7), size: 200)
///
/// MCP / AI client integration:
///   Set `state` from your voice-pipeline audio level (0–1 Float normalised RMS).
///   The view is fully self-contained; no timer management required by the caller.

#if canImport(SwiftUI)
import SwiftUI

// MARK: - Main view

public struct TalkingOrb: View {
    public let state: OrbState
    public var size: CGFloat = 220

    @State private var breathPhase: Double = 0
    @State private var shimmerPhase: Double = 0
    @State private var particlePhase: Double = 0

    public init(state: OrbState, size: CGFloat = 220) {
        self.state = state
        self.size = size
    }

    public var body: some View {
        ZStack {
            ambientGlow
            orbBody
            shimmerHighlight
            particles
        }
        .frame(width: size, height: size)
        .onAppear { startAnimations() }
        .onChange(of: state) { _ in /* state transitions handled reactively */ }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isImage)
    }

    // MARK: Layers

    private var ambientGlow: some View {
        let (c1, c2) = state.colors
        return Circle()
            .fill(
                RadialGradient(
                    colors: [c1.opacity(state.glowOpacity), .clear],
                    center: .center,
                    startRadius: size * 0.1,
                    endRadius: size * 0.75
                )
            )
            .scaleEffect(1.35 + 0.08 * sin(breathPhase))
            .animation(.easeInOut(duration: state.pulseSpeed).repeatForever(autoreverses: true),
                       value: breathPhase)
    }

    private var orbBody: some View {
        let (c1, c2) = state.colors
        return Circle()
            .fill(
                EllipticalGradient(
                    colors: [
                        c1,
                        c2,
                        Color(hue: 0.82, saturation: 0.5, brightness: 0.5)
                    ],
                    center: UnitPoint(x: 0.35 + 0.05 * sin(shimmerPhase),
                                     y: 0.30 + 0.04 * cos(shimmerPhase))
                )
            )
            .scaleEffect(state.baseScale * (1 + 0.02 * sin(breathPhase * 1.3)))
            .shadow(color: c1.opacity(0.5), radius: size * 0.12)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: state.baseScale)
    }

    private var shimmerHighlight: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.55), .white.opacity(0.0)],
                    startPoint: .topLeading,
                    endPoint: .center
                )
            )
            .frame(width: size * 0.45, height: size * 0.30)
            .offset(x: -size * 0.12 + size * 0.03 * sin(shimmerPhase),
                    y: -size * 0.18)
            .blur(radius: 2)
    }

    private var particles: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2
            let r  = canvasSize.width * 0.38

            let count = 12
            for i in 0 ..< count {
                let angle  = (Double(i) / Double(count)) * .pi * 2 + particlePhase
                let jitter = 0.12 * sin(particlePhase * 2.3 + Double(i))
                let px     = cx + (r + r * jitter) * cos(angle)
                let py     = cy + (r + r * jitter) * sin(angle)
                let alpha  = 0.12 + 0.08 * sin(particlePhase * 1.7 + Double(i))
                context.fill(
                    Path(ellipseIn: CGRect(x: px - 2, y: py - 2, width: 4, height: 4)),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
        .blendMode(.plusLighter)
    }

    // MARK: Animations

    private func startAnimations() {
        withAnimation(.easeInOut(duration: state.pulseSpeed).repeatForever(autoreverses: true)) {
            breathPhase = .pi
        }
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            shimmerPhase = .pi * 2
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            particlePhase = .pi * 2
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .idle:          return "AI assistant idle"
        case .listening:     return "AI assistant listening"
        case .thinking:      return "AI assistant thinking"
        case .speaking:      return "AI assistant speaking"
        }
    }
}

// MARK: - Preview

#Preview("All States") {
    HStack(spacing: 24) {
        VStack {
            TalkingOrb(state: .idle, size: 100)
            Text("Idle").font(.caption)
        }
        VStack {
            TalkingOrb(state: .listening, size: 100)
            Text("Listening").font(.caption)
        }
        VStack {
            TalkingOrb(state: .thinking, size: 100)
            Text("Thinking").font(.caption)
        }
        VStack {
            TalkingOrb(state: .speaking(audioLevel: 0.75), size: 100)
            Text("Speaking").font(.caption)
        }
    }
    .padding(32)
    .background(Color.black)
}

#endif
