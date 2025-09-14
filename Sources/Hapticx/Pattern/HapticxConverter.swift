import Foundation

// MARK: - Converter Protocol

/// Converts HapticxFeedback to HapticxEvent array
public protocol HapticxConverter: Sendable {
    func convert(_ feedback: HapticxFeedback) -> [HapticxEvent]
}

// MARK: - Default Implementation

/// Default feedback to events converter
struct FeedbackConverter: HapticxConverter {
    
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
