import Foundation

// MARK: - Haptic Event

public enum HapticxEvent {
    case tap(intensity: HapticxIntensity, sharpness: HapticxSharpness, at: TimeInterval = 0)
    case continuous(duration: TimeInterval, intensity: HapticxIntensity, at: TimeInterval = 0)
    case wait(TimeInterval)
}