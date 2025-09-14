import Foundation

// MARK: - Haptic Duration

public enum HapticxDuration: Sendable {
    case short, medium, long
    case custom(TimeInterval)
    
    var raw: TimeInterval {
        switch self {
        case .short:  return 0.1
        case .medium: return 0.3
        case .long:   return 0.8
        case .custom(let v): return HapticxUtils.clampTime(v)
        }
    }
}