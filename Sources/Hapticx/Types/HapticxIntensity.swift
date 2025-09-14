import Foundation

// MARK: - Haptic Intensity

public enum HapticxIntensity: Sendable {
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