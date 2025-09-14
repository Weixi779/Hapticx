import Foundation

// MARK: - Sequence Builder

/// A builder for creating haptic event sequences with wait functionality
public class HapticxSequenceBuilder {
    
    private var events: [HapticxEvent] = []
    private var cursor: TimeInterval = 0
    
    public init() {}
    
    /// Add a tap event at current cursor position
    public func tap(_ intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) -> HapticxSequenceBuilder {
        events.append(.tap(intensity: intensity, sharpness: sharpness, at: cursor))
        return self
    }
    
    /// Add a continuous event at current cursor position
    public func continuous(_ duration: HapticxDuration, intensity: HapticxIntensity = .medium, sharpness: HapticxSharpness = .medium) -> HapticxSequenceBuilder {
        events.append(.continuous(duration: duration, intensity: intensity, sharpness: sharpness, at: cursor))
        return self
    }
    
    /// Move cursor forward by specified duration
    public func wait(_ duration: HapticxDuration) -> HapticxSequenceBuilder {
        cursor += duration.raw
        return self
    }
    
    /// Build the final event array, sorted by time
    public func build() -> [HapticxEvent] {
        return events.sorted { $0.relativeTime < $1.relativeTime }
    }
}

// MARK: - Convenience Extensions

public extension HapticxSequenceBuilder {
    
    /// Add success haptic pattern
    func success() -> HapticxSequenceBuilder {
        return tap(.medium, sharpness: .sharp)
            .wait(.short)
            .tap(.heavy, sharpness: .sharp)
    }
    
    /// Add error haptic pattern
    func error() -> HapticxSequenceBuilder {
        return continuous(.short, intensity: .heavy, sharpness: .soft)
    }
    
    /// Add warning haptic pattern
    func warning() -> HapticxSequenceBuilder {
        return tap(.medium, sharpness: .sharp)
            .wait(.short)
            .tap(.medium, sharpness: .sharp)
            .wait(.short)
            .tap(.medium, sharpness: .sharp)
    }
    
    /// Add selection haptic pattern
    func selection() -> HapticxSequenceBuilder {
        return tap(.light, sharpness: .medium)
    }
}