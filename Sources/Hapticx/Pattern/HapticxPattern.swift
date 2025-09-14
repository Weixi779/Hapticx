import CoreHaptics
import Foundation

// MARK: - Pattern Provider Protocol

public protocol HapticxPatternProvider: Sendable {
    func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern
    func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern
}

// MARK: - Clean Pattern Implementation

public struct HapticxPattern: HapticxPatternProvider {
    
    private let converter: HapticxConverter = FeedbackConverter()
    private let processor: HapticxProcessor = EventProcessor()
    
    public init() {}
    
    public func createPattern(for feedback: HapticxFeedback) throws -> CHHapticPattern {
        let events = converter.convert(feedback)
        return try processor.process(events)
    }
    
    public func createPattern(for events: [HapticxEvent]) throws -> CHHapticPattern {
        return try processor.process(events)
    }
}

