import Foundation

// MARK: - Haptic Sharpness

public enum HapticxSharpness: Sendable {
    case soft, medium, sharp
    case custom(Float)
    
    var raw: Float {
        switch self {
        case .soft:   return 0.2
        case .medium: return 0.5
        case .sharp:  return 0.8
        case .custom(let v): return HapticxUtils.clamp(v)
        }
    }
}
