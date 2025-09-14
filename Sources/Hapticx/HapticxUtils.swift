import Foundation

// MARK: - Internal Utilities

internal struct HapticxUtils {
    
    /// Clamps a value to [0, 1] range for haptic parameters
    static func clamp(_ value: Float) -> Float {
        return max(0, min(1, value))
    }
    
    /// Clamps a time interval to be non-negative
    static func clampTime(_ time: TimeInterval) -> TimeInterval {
        return max(0, time)
    }
}