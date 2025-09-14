import Foundation

// MARK: - Haptic Event

public enum HapticxEvent: Sendable {
    case tap(intensity: HapticxIntensity, sharpness: HapticxSharpness, at: TimeInterval = 0)
    case continuous(duration: HapticxDuration, intensity: HapticxIntensity, sharpness: HapticxSharpness = .medium, at: TimeInterval = 0)
    
    var relativeTime: TimeInterval {
        switch self {
        case .tap(_, _, let time):
            return time
        case .continuous(_, _, _, let time):
            return time
        }
    }
}
