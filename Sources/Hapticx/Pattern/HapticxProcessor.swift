import CoreHaptics
import Foundation

// MARK: - Processor Protocol

/// Processes HapticxEvent array to CHHapticPattern
public protocol HapticxProcessor: Sendable {
    func process(_ events: [HapticxEvent]) throws -> CHHapticPattern
}

// MARK: - Default Implementation

/// Default event processor
struct EventProcessor: HapticxProcessor {
    
    func process(_ events: [HapticxEvent]) throws -> CHHapticPattern {
        let normalizedEvents = normalizeEvents(events)
        let chEvents = try normalizedEvents.map { try convertToCHEvent($0) }
        return try CHHapticPattern(events: chEvents, parameters: [])
    }
    
    private func normalizeEvents(_ events: [HapticxEvent]) -> [HapticxEvent] {
        // Normalize time values and sort events
        let clampedEvents = events.map { event -> HapticxEvent in
            switch event {
            case .tap(let intensity, let sharpness, let time):
                let clampedTime = HapticxUtils.clampTime(time)
                return .tap(intensity: intensity, sharpness: sharpness, at: clampedTime)
                
            case .continuous(let duration, let intensity, let sharpness, let time):
                let clampedTime = HapticxUtils.clampTime(time)
                return .continuous(duration: duration, intensity: intensity, sharpness: sharpness, at: clampedTime)
            }
        }
        
        // Sort by relative time
        return clampedEvents.sorted { $0.relativeTime < $1.relativeTime }
    }
    
    private func convertToCHEvent(_ event: HapticxEvent) throws -> CHHapticEvent {
        switch event {
        case .tap(let intensity, let sharpness, let time):
            return CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity.raw),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness.raw)
                ],
                relativeTime: time
            )
            
        case .continuous(let duration, let intensity, let sharpness, let time):
            return CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity.raw),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness.raw)
                ],
                relativeTime: time,
                duration: duration.raw
            )
        }
    }
}
