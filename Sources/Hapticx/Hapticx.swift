import CoreHaptics
import Foundation

// MARK: - Hapticx Public API

public final class Hapticx {
    
    // MARK: - Singleton
    
    public static let shared = Hapticx()
    private var engine: HapticxEngine?
    
    private init() {
        Task {
            engine = await HapticxEngine()
        }
    }
    
    // MARK: - Public API
    
    /// Plays a haptic feedback
    public static func play(_ feedback: HapticFeedback) {
        Task {
            await shared.playFeedback(feedback)
        }
    }
    
    /// Quick tap feedback
    public static func tap(_ intensity: HapticIntensity = .medium, sharpness: HapticSharpness = .medium) {
        play(.tap(intensity: intensity, sharpness: sharpness))
    }
    
    /// Quick buzz feedback
    public static func buzz(duration: TimeInterval, intensity: HapticIntensity = .medium, fadeIn: TimeInterval = 0, fadeOut: TimeInterval = 0) {
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
    
    func playFeedback(_ feedback: HapticFeedback) async {
        guard let engine = engine else { return }
        do {
            let pattern = createPattern(for: feedback)
            try await engine.play(pattern: pattern)
        } catch {
            // Silent failure - logged by engine
        }
    }
    
    func createPattern(for feedback: HapticFeedback) -> CHHapticPattern {
        switch feedback {
        case .tap(let intensity, let sharpness):
            return createTransientPattern(intensity: intensity.raw, sharpness: sharpness.raw)
            
        case .continuous(let duration, let intensity, let fadeIn, let fadeOut):
            return createContinuousPattern(duration: duration, intensity: intensity.raw, fadeIn: fadeIn, fadeOut: fadeOut)
            
        case .success:
            return createSuccessPattern()
            
        case .error:
            return createErrorPattern()
            
        case .warning:
            return createWarningPattern()
            
        case .selection:
            return createSelectionPattern()
        }
    }
    
    // MARK: - Pattern Creation
    
    func createTransientPattern(intensity: Float, sharpness: Float) -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        
        do {
            return try CHHapticPattern(events: [event], parameters: [])
        } catch {
            // Fallback to empty pattern
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
    
    func createContinuousPattern(duration: TimeInterval, intensity: Float, fadeIn: TimeInterval, fadeOut: TimeInterval) -> CHHapticPattern {
        let parameters = [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ]
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: parameters,
            relativeTime: 0,
            duration: duration
        )
        
        var curves: [CHHapticParameterCurve] = []
        
        // Add fade curves if specified
        if fadeIn > 0 || fadeOut > 0 {
            var controlPoints: [CHHapticParameterCurve.ControlPoint] = []
            
            if fadeIn > 0 {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0))
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: min(fadeIn, duration), value: intensity))
            } else {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: intensity))
            }
            
            if fadeOut > 0 {
                let fadeStartTime = max(fadeIn, duration - fadeOut)
                if fadeStartTime < duration {
                    controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: fadeStartTime, value: intensity))
                }
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: 0))
            } else if fadeIn > 0 && fadeIn < duration {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: intensity))
            }
            
            let curve = CHHapticParameterCurve(
                parameterID: CHHapticDynamicParameter.ID.hapticIntensityControl,
                controlPoints: controlPoints,
                relativeTime: 0
            )
            curves.append(curve)
        }
        
        do {
            return try CHHapticPattern(events: [event], parameterCurves: curves)
        } catch {
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
    
    func createSuccessPattern() -> CHHapticPattern {
        // Two quick taps with increasing intensity
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.1
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
    
    func createErrorPattern() -> CHHapticPattern {
        // One heavy continuous vibration
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0,
            duration: 0.3
        )
        
        do {
            return try CHHapticPattern(events: [event], parameters: [])
        } catch {
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
    
    func createWarningPattern() -> CHHapticPattern {
        // Three quick sharp taps
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.2
            )
        ]
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
    
    func createSelectionPattern() -> CHHapticPattern {
        // Light single tap
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ],
            relativeTime: 0
        )
        
        do {
            return try CHHapticPattern(events: [event], parameters: [])
        } catch {
            return try! CHHapticPattern(events: [], parameters: [])
        }
    }
}
