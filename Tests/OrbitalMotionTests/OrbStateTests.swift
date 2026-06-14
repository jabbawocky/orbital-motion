import XCTest
@testable import OrbitalMotion

final class OrbStateTests: XCTestCase {

    func testIdleBaseScale() {
        XCTAssertEqual(OrbState.idle.baseScale, 1.0)
    }

    func testSpeakingScalesWithAudioLevel() {
        let low  = OrbState.speaking(audioLevel: 0.0).baseScale
        let high = OrbState.speaking(audioLevel: 1.0).baseScale
        XCTAssertGreaterThan(high, low, "Higher audio level should produce larger scale")
    }

    func testGlowOpacityIncreasesDuringSpeaking() {
        let idle    = OrbState.idle.glowOpacity
        let loud    = OrbState.speaking(audioLevel: 1.0).glowOpacity
        XCTAssertGreaterThan(loud, idle)
    }

    func testPulseSpeedDecreasesWithLouderSpeech() {
        let quiet = OrbState.speaking(audioLevel: 0.0).pulseSpeed
        let loud  = OrbState.speaking(audioLevel: 1.0).pulseSpeed
        XCTAssertGreaterThan(quiet, loud, "Louder speech should pulse faster (lower period)")
    }

    func testEquality() {
        XCTAssertEqual(OrbState.idle, OrbState.idle)
        XCTAssertNotEqual(OrbState.idle, OrbState.listening)
        XCTAssertEqual(OrbState.speaking(audioLevel: 0.5), OrbState.speaking(audioLevel: 0.5))
    }
}
