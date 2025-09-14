import CoreHaptics
import Foundation

// MARK: - Conversion Protocols

/// Converts HapticxFeedback to HapticxEvent array
protocol HapticxFeedbackConverter {
    func convert(_ feedback: HapticxFeedback) -> [HapticxEvent]
}

/// Processes HapticxEvent array to CHHapticPattern
protocol HapticxEventProcessor {
    func process(_ events: [HapticxEvent]) throws -> CHHapticPattern
}

// MARK: - Default Implementations

/// Default feedback to events converter
struct DefaultFeedbackConverter: HapticxFeedbackConverter {
    
    func convert(_ feedback: HapticxFeedback) -> [HapticxEvent] {
        switch feedback {
        case .tap(let intensity, let sharpness):
            return [.tap(intensity: intensity, sharpness: sharpness, at: 0)]
            
        case .continuous(let duration, let intensity, let sharpness):
            return [.continuous(duration: duration, intensity: intensity, sharpness: sharpness, at: 0)]
            
        case .success:
            return [
                .tap(intensity: .medium, sharpness: .sharp, at: 0),
                .tap(intensity: .heavy, sharpness: .sharp, at: 0.1)
            ]
            
        case .error:
            return [.continuous(duration: .short, intensity: .heavy, sharpness: .soft, at: 0)]
            
        case .warning:
            return [
                .tap(intensity: .medium, sharpness: .sharp, at: 0),
                .tap(intensity: .medium, sharpness: .sharp, at: 0.1),
                .tap(intensity: .medium, sharpness: .sharp, at: 0.2)
            ]
            
        case .selection:
            return [.tap(intensity: .light, sharpness: .medium, at: 0)]
        }
    }
}

/// Default event processor
struct DefaultEventProcessor: HapticxEventProcessor {
    
    func process(_ events: [HapticxEvent]) throws -> CHHapticPattern {
        let processedEvents = try handleTimeOffsets(events)
        let chEvents = try processedEvents.map { try $0.toCHEvent() }
        return try CHHapticPattern(events: chEvents, parameters: [])
    }
    
    private func handleTimeOffsets(_ events: [HapticxEvent]) throws -> [HapticxEvent] {
        var processedEvents: [HapticxEvent] = []
        var timeOffset: TimeInterval = 0
        
        for event in events {
            switch event {
            case .wait(let duration):
                timeOffset += duration.raw
                
            case .tap(let intensity, let sharpness, let time):
                let finalTime = HapticxUtils.clampTime(time + timeOffset)
                processedEvents.append(.tap(intensity: intensity, sharpness: sharpness, at: finalTime))
                
            case .continuous(let duration, let intensity, let sharpness, let time):
                let finalTime = HapticxUtils.clampTime(time + timeOffset)
                processedEvents.append(.continuous(duration: duration, intensity: intensity, sharpness: sharpness, at: finalTime))
            }
        }
        
        // Sort by relative time
        return processedEvents.sorted { $0.relativeTime < $1.relativeTime }
    }
}

// MARK: - HapticxEvent Extensions

private extension HapticxEvent {
    
    func toCHEvent() throws -> CHHapticEvent {
        switch self {
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
            
        case .wait:
            throw HapticxError.invalidPattern("Wait events should be processed before creating CHHapticEvent")
        }
    }
}
