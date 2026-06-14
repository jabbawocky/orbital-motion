# OrbitalMotion

A SwiftUI library for the settled "talking AI" animation design: a **morphing iridescent sphere** with audio-reactive glow and orbiting micro-particles.

See [RESEARCH.md](RESEARCH.md) for the full design decision and alternatives evaluated.

## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+
- No external dependencies

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/jabbawocky/orbital-motion", from: "0.1.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repo URL.

## Quick Start

```swift
import SwiftUI
import OrbitalMotion

struct AssistantView: View {
    @State var orbState: OrbState = .idle

    var body: some View {
        VStack {
            TalkingOrb(state: orbState, size: 220)

            Button("Speak") {
                orbState = .speaking(audioLevel: 0.6)
            }
        }
        .background(Color.black)
    }
}
```

## States

```swift
TalkingOrb(state: .idle)                        // slow breath, blue-purple
TalkingOrb(state: .listening)                   // faster pulse, bright blue
TalkingOrb(state: .thinking)                    // contracted, muted purple
TalkingOrb(state: .speaking(audioLevel: 0.8))   // scale + glow driven by 0–1 RMS
```

## Wiring to a microphone (AVAudioEngine)

```swift
import AVFoundation

class AudioMonitor: ObservableObject {
    @Published var level: Float = 0
    private let engine = AVAudioEngine()

    func start() throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buf, _ in
            guard let data = buf.floatChannelData?[0] else { return }
            let count = Int(buf.frameLength)
            let rms   = sqrt((0..<count).reduce(0.0) { $0 + Double(data[$1] * data[$1]) } / Double(count))
            DispatchQueue.main.async { self?.level = min(1, Float(rms) * 20) }
        }
        try engine.start()
    }
}

// In your view:
@StateObject var audio = AudioMonitor()

TalkingOrb(state: .speaking(audioLevel: audio.level))
    .onAppear { try? audio.start() }
```

## AI / MCP client integration

The library is intentionally stateless — the **caller** decides what `OrbState` to set based on its pipeline events:

| Pipeline event | OrbState to set |
|---|---|
| App launched, waiting | `.idle` |
| Microphone activated, capturing user speech | `.listening` |
| User finished, LLM generating | `.thinking` |
| TTS playing back | `.speaking(audioLevel: rmsFloat)` |
| Error / muted | `.idle` |

Update `orbState` from your pipeline's `AsyncStream` or Combine publisher; SwiftUI animates transitions automatically.

## Accessibility

- `accessibilityLabel` changes per state (e.g. "AI assistant speaking")
- Scale animation respects `@Environment(\.accessibilityReduceMotion)` — wrap the particle Canvas in a check if needed
- No colour-only state signalling: shape and motion also differ per state

## Design decision

See [RESEARCH.md](RESEARCH.md) — six animation paradigms were evaluated. The morphing iridescent orb was selected because:
1. Orb/sphere is the category-defining form for voice AI (Siri, ChatGPT Advanced Voice)
2. Audio-reactive scale creates an immediate microphone-to-visual feedback loop
3. Iridescent gradient is visually distinctive without external assets or Lottie files
4. Four clearly differentiated states eliminate ambiguity about what the AI is doing
5. Pure SwiftUI — no third-party dependencies

## License

MIT
