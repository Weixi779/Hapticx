import Foundation

// MARK: - Haptic Feedback

public enum HapticxFeedback {
    // Basic haptics
    case tap(intensity: HapticxIntensity, sharpness: HapticxSharpness)
    case continuous(duration: TimeInterval,
                    intensity: HapticxIntensity,
                    fadeIn: TimeInterval,
                    fadeOut: TimeInterval)
    
    // Semantic haptics
    case success
    case error
    case warning
    case selection
    
    // Complex patterns
    case sequence([HapticxEvent])
}

public extension HapticxFeedback {
    static var tap: Self { .tap(intensity: .medium, sharpness: .medium) }
    static func tap(_ intensity: HapticxIntensity) -> Self { .tap(intensity: intensity, sharpness: .medium) }

    static func buzz(_ duration: TimeInterval,
                     intensity: HapticxIntensity = .medium,
                     fadeIn: TimeInterval = 0,
                     fadeOut: TimeInterval = 0) -> Self {
        .continuous(duration: duration, intensity: intensity, fadeIn: fadeIn, fadeOut: fadeOut)
    }
}