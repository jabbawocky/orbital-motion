# Orbital Motion — Design Research

**Conducted:** 2026-06-14  
**Team:** Orbital Motion (OrbitOS)  
**Status:** SETTLED — morphing iridescent orb selected

---

## Question
What is the best graphical animation for a talking AI on iOS? Circle, star, orb, waveform, something else?

---

## Candidates Evaluated

| Design | Used By | Pros | Cons |
|--------|---------|------|------|
| **Morphing orb / sphere** | Apple Siri, ChatGPT Advanced Voice | Most recognised as "voice AI", rounded = unthreatening, can show all states clearly | Referential to Apple |
| Sound waveform | Google Assistant, classic Siri | Intuitively shows audio activity | Feels corporate; 1D |
| LED ring | Amazon Alexa | Hardware affordance; directional | Not applicable to software-only |
| Particle burst / star | — | Energetic, distinctive | Hard to read state; chaotic at high density |
| Blob / fluid morph | Various | Organic, friendly | Uncanny when colour-shifting |
| Static icon + pulse | Many apps | Trivial to implement | No expressiveness |

---

## Key Findings

### Shape
Rounded shapes (circle, sphere) consistently score higher on trust and approachability than angular shapes (star, burst). A sphere adds depth over a flat circle, making the animation feel alive with minimal extra code.

### Motion
- **Breathing idle** (slow scale oscillation 0.98–1.02×): signals "ready" without demanding attention  
- **Audio-reactive scale** (scale proportional to RMS amplitude): direct one-to-one mapping users understand immediately  
- **Shimmer highlight** (moving specular point): cheap but effective depth cue  
- **Orbiting micro-particles**: create a sense of energy without obscuring the orb face  

### Colour
- Cool-to-warm hue shift (blue → purple) during listening→speaking marks state transition perceptually, without relying on text labels
- Iridescent multi-stop gradient avoids owning a single brand colour, keeping the design neutral for embedding

### State mapping
Four states are sufficient and complete:
1. `idle` — slow breath, low glow, blue-purple
2. `listening` — medium pulse, higher glow, bright blue
3. `thinking` — slightly contracted, muted purple
4. `speaking(audioLevel:)` — scale + glow both driven by normalised RMS amplitude

### iOS implementation path
- **No external dependencies** — SwiftUI Canvas + `EllipticalGradient` + `TimelineView` covers everything
- Requires iOS 17 / macOS 14 for `EllipticalGradient`
- Audio reactivity: caller passes normalised RMS from `AVAudioEngine` as `audioLevel: Float`
- Accessibility: `accessibilityLabel` updates per state; `preferredColorScheme` and `accessibilityReduceMotion` can gate particle layer

---

## Settled Design

> **Morphing iridescent sphere with audio-reactive glow and orbiting micro-particles.**

Implemented in `Sources/OrbitalMotion/TalkingOrb.swift`.

Rationale:
- Orb/sphere is the category-defining form for voice AI (industry consensus)
- Audio-reactive scale makes the microphone → visual loop feel magical and immediate
- Iridescent gradient is visually distinctive without requiring external assets or animation files
- Four clearly differentiated states remove ambiguity about what the AI is doing
- Fully declarative SwiftUI — no UIKit, no Metal, no Lottie dependency
