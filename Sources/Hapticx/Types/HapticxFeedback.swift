import Foundation

// MARK: - Haptic Feedback

public enum HapticxFeedback: Sendable {
    // Basic haptics
    case tap(intensity: HapticxIntensity, sharpness: HapticxSharpness)
    case continuous(duration: HapticxDuration, intensity: HapticxIntensity, sharpness: HapticxSharpness)
    
    // Semantic haptics
    case success
    case error
    case warning
    case selection
}

public extension HapticxFeedback {
    static var tap: Self { .tap(intensity: .medium, sharpness: .medium) }
    static func tap(_ intensity: HapticxIntensity) -> Self { .tap(intensity: intensity, sharpness: .medium) }
    
    static func buzz(_ duration: HapticxDuration = .medium, intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) -> Self {
        .continuous(duration: duration, intensity: intensity, sharpness: sharpness)
    }
}
