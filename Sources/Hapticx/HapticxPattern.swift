import CoreHaptics
import Foundation

// MARK: - Pattern Provider Protocol

public protocol HapticxPatternProvider: Sendable {
    func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern
    func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern
}

// MARK: - Clean Pattern Implementation

public struct HapticxPattern: HapticxPatternProvider {
    
    private let feedbackConverter = DefaultFeedbackConverter()
    private let eventProcessor = DefaultEventProcessor()
    
    public init() {}
    
    public func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern {
        let events = feedbackConverter.convert(feedback)
        return try eventProcessor.process(events)
    }
    
    public func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern {
        return try eventProcessor.process(events)
    }
}

