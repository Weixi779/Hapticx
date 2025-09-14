import CoreHaptics
import Foundation

// MARK: - Pattern Provider Protocol

protocol HapticxPatternProvider {
    func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern
    func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern
}

// MARK: - Default Pattern Implementation

struct HapticxPattern: HapticxPatternProvider {
    
    func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern {
        switch feedback {
        case .tap(let intensity, let sharpness):
            return try createTransientPattern(intensity: intensity.raw, sharpness: sharpness.raw)
            
        case .continuous(let duration, let intensity, let fadeIn, let fadeOut):
            return try createContinuousPattern(duration: duration, intensity: intensity.raw, fadeIn: fadeIn, fadeOut: fadeOut)
            
        case .success:
            return try createSuccessPattern()
            
        case .error:
            return try createErrorPattern()
            
        case .warning:
            return try createWarningPattern()
            
        case .selection:
            return try createSelectionPattern()
            
        case .sequence(let events):
            return try createPattern(for: events)
        }
    }
    
    func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern {
        let hapticEvents = try events.map { try createCHEvent(from: $0) }
        return try CHHapticPattern(events: hapticEvents, parameters: [])
    }
}

// MARK: - Private Pattern Creation Methods

private extension HapticxPattern {
    
    func createCHEvent(from event: HapticxEvent) throws -> CHHapticEvent {
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
            
        case .continuous(let duration, let intensity, let time):
            return CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity.raw),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: time,
                duration: duration
            )
            
        case .wait:
            throw HapticxError.engineNotInitialized // Wait events need special handling
        }
    }
    
    func createTransientPattern(intensity: Float, sharpness: Float) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
    
    func createContinuousPattern(duration: TimeInterval, intensity: Float, fadeIn: TimeInterval, fadeOut: TimeInterval) throws -> CHHapticPattern {
        let parameters = [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ]
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: parameters,
            relativeTime: 0,
            duration: duration
        )
        
        var curves: [CHHapticParameterCurve] = []
        
        // Add fade curves if specified
        if fadeIn > 0 || fadeOut > 0 {
            var controlPoints: [CHHapticParameterCurve.ControlPoint] = []
            
            if fadeIn > 0 {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0))
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: min(fadeIn, duration), value: intensity))
            } else {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: intensity))
            }
            
            if fadeOut > 0 {
                let fadeStartTime = max(fadeIn, duration - fadeOut)
                if fadeStartTime < duration {
                    controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: fadeStartTime, value: intensity))
                }
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: 0))
            } else if fadeIn > 0 && fadeIn < duration {
                controlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: intensity))
            }
            
            let curve = CHHapticParameterCurve(
                parameterID: CHHapticDynamicParameter.ID.hapticIntensityControl,
                controlPoints: controlPoints,
                relativeTime: 0
            )
            curves.append(curve)
        }
        
        return try CHHapticPattern(events: [event], parameterCurves: curves)
    }
    
    func createSuccessPattern() throws -> CHHapticPattern {
        // Two quick taps with increasing intensity
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.1
            )
        ]
        
        return try CHHapticPattern(events: events, parameters: [])
    }
    
    func createErrorPattern() throws -> CHHapticPattern {
        // One heavy continuous vibration
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0,
            duration: 0.3
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
    
    func createWarningPattern() throws -> CHHapticPattern {
        // Three quick sharp taps
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.2
            )
        ]
        
        return try CHHapticPattern(events: events, parameters: [])
    }
    
    func createSelectionPattern() throws -> CHHapticPattern {
        // Light single tap
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ],
            relativeTime: 0
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
}