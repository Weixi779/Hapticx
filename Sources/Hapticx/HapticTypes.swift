import Foundation

// MARK: - Haptic Intensity

public enum HapticIntensity: Sendable {
    case light, medium, heavy
    case custom(Float)
    
    var raw: Float {
        switch self {
        case .light:  return 0.3
        case .medium: return 0.7
        case .heavy:  return 1.0
        case .custom(let v): return max(0, min(1, v))
        }
    }
}

// MARK: - Haptic Sharpness

public enum HapticSharpness: Sendable {
    case soft, medium, sharp
    case custom(Float)
    
    var raw: Float {
        switch self {
        case .soft:   return 0.2
        case .medium: return 0.5
        case .sharp:  return 0.8
        case .custom(let v): return max(0, min(1, v))
        }
    }
}

// MARK: - Haptic Feedback

public enum HapticFeedback {
    // Basic haptics
    case tap(intensity: HapticIntensity, sharpness: HapticSharpness)
    case continuous(duration: TimeInterval,
                    intensity: HapticIntensity,
                    fadeIn: TimeInterval,
                    fadeOut: TimeInterval)
    
    // Semantic haptics
    case success
    case error
    case warning
    case selection
}

public extension HapticFeedback {
    static var tap: Self { .tap(intensity: .medium, sharpness: .medium) }
    static func tap(_ intensity: HapticIntensity) -> Self { .tap(intensity: intensity, sharpness: .medium) }

    static func buzz(_ duration: TimeInterval,
                     intensity: HapticIntensity = .medium,
                     fadeIn: TimeInterval = 0,
                     fadeOut: TimeInterval = 0) -> Self {
        .continuous(duration: duration, intensity: intensity, fadeIn: fadeIn, fadeOut: fadeOut)
    }
}
