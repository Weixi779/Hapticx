import CoreHaptics
import Foundation

// MARK: - Hapticx Public API

public final class Hapticx {
    
    // MARK: - Singleton
    
    public static let shared = Hapticx()
    private var engine: HapticxEngine?
    private let patternProvider = HapticxPattern()
    
    private init() {
        Task {
            engine = await HapticxEngine()
        }
    }
    
    // MARK: - Public API
    
    /// Plays a haptic feedback
    public static func playFeedback(_ feedback: HapticxFeedback) {
        Task {
            await shared.playFeedback(feedback)
        }
    }
    
    /// Quick tap feedback
    public static func tap(_ intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) {
        playFeedback(.tap(intensity: intensity, sharpness: sharpness))
    }
    
    /// Quick buzz feedback
    public static func buzz(duration: HapticxDuration = .medium, intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) {
        playFeedback(.continuous(duration: duration, intensity: intensity, sharpness: sharpness))
    }
    
    /// Success feedback
    public static func success() {
        playFeedback(.success)
    }
    
    /// Error feedback
    public static func error() {
        playFeedback(.error)
    }
    
    /// Warning feedback
    public static func warning() {
        playFeedback(.warning)
    }
    
    /// Selection feedback
    public static func selection() {
        playFeedback(.selection)
    }
    
    /// Play sequence of events
    public static func playEvents(_ events: [HapticxEvent]) {
        Task {
            await shared.playEvents(events)
        }
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
    
    func playEvents(_ events: [HapticxEvent]) async {
        guard let engine = engine else { return }
        do {
            let pattern = try patternProvider.createPattern(for: events)
            try await engine.play(pattern: pattern)
        } catch {
            // Silent failure - logged by engine
        }
    }
    
}
