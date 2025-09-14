import CoreHaptics
import Foundation

// MARK: - Hapticx Public API

public final class Hapticx {
    
    // MARK: - Singleton
    
    public static let shared = Hapticx()
    private var engine: HapticxEngine?
    private let patternProvider: HapticxPatternProvider = HapticxPattern()
    
    private init() {
        Task {
            engine = await HapticxEngine()
        }
    }
    
    // MARK: - Public API
    
    /// Plays a haptic feedback
    public static func play(_ feedback: HapticxFeedback) {
        Task {
            await shared.playFeedback(feedback)
        }
    }
    
    /// Quick tap feedback
    public static func tap(_ intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) {
        play(.tap(intensity: intensity, sharpness: sharpness))
    }
    
    /// Quick buzz feedback
    public static func buzz(duration: TimeInterval, intensity: HapticxIntensity = .medium, fadeIn: TimeInterval = 0, fadeOut: TimeInterval = 0) {
        play(.continuous(duration: duration, intensity: intensity, fadeIn: fadeIn, fadeOut: fadeOut))
    }
    
    /// Success feedback
    public static func success() {
        play(.success)
    }
    
    /// Error feedback
    public static func error() {
        play(.error)
    }
    
    /// Warning feedback
    public static func warning() {
        play(.warning)
    }
    
    /// Selection feedback
    public static func selection() {
        play(.selection)
    }
    
    // MARK: - App Lifecycle
    
    /// Call when app becomes active
    public static func applicationDidBecomeActive() {
        Task {
            try? await shared.engine?.startIfNeeded()
        }
    }
    
    /// Call when app will resign active
    public static func applicationWillResignActive() {
        Task {
            await shared.engine?.stop()
        }
    }
}

// MARK: - Private Implementation

private extension Hapticx {
    
    func playFeedback(_ feedback: HapticxFeedback) async {
        guard let engine = engine else { return }
        do {
            let pattern = try patternProvider.createPattern(for: feedback)
            try await engine.play(pattern: pattern)
        } catch {
            // Silent failure - logged by engine
        }
    }
    
}
