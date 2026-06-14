import Foundation

/// The state of the talking AI orb.
public enum OrbState: Equatable {
    case idle
    case listening
    case thinking
    case speaking(audioLevel: Float)  // 0.0 – 1.0

    var baseScale: CGFloat {
        switch self {
        case .idle:                     return 1.0
        case .listening:                return 1.05
        case .thinking:                 return 0.95
        case .speaking(let lvl):        return 1.0 + CGFloat(lvl) * 0.18
        }
    }

    var pulseSpeed: Double {
        switch self {
        case .idle:                     return 3.0
        case .listening:                return 1.8
        case .thinking:                 return 2.5
        case .speaking(let lvl):        return 1.2 - Double(lvl) * 0.4
        }
    }

    var glowOpacity: Double {
        switch self {
        case .idle:                     return 0.25
        case .listening:                return 0.45
        case .thinking:                 return 0.35
        case .speaking(let lvl):        return 0.35 + Double(lvl) * 0.45
        }
    }

    /// Primary gradient colors. Two stops blended for the orb face.
    var colors: (Color, Color) {
        switch self {
        case .idle:      return (.init(hue: 0.62, saturation: 0.7, brightness: 0.9),
                                 .init(hue: 0.72, saturation: 0.8, brightness: 0.8))
        case .listening: return (.init(hue: 0.55, saturation: 0.8, brightness: 1.0),
                                 .init(hue: 0.65, saturation: 0.9, brightness: 0.9))
        case .thinking:  return (.init(hue: 0.75, saturation: 0.6, brightness: 0.85),
                                 .init(hue: 0.82, saturation: 0.7, brightness: 0.75))
        case .speaking:  return (.init(hue: 0.50, saturation: 0.7, brightness: 1.0),
                                 .init(hue: 0.60, saturation: 0.9, brightness: 0.95))
        }
    }
}

// Expose SwiftUI Color for the enum without importing SwiftUI at package root.
#if canImport(SwiftUI)
import SwiftUI
#else
// Stub so the file compiles on non-Apple platforms (CI, Linux).
struct Color {
    init(hue: Double, saturation: Double, brightness: Double) {}
}
#endif
