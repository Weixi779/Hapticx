import CoreHaptics
import Foundation
import os.log

// MARK: - HapticxEngine Actor

actor HapticxEngine {
    
    enum State {
        case stopped    // Engine is stopped
        case ready      // Engine is started and ready to play
    }
    
    // MARK: - Properties
    
    private(set) var state: State = .stopped
    private var engine: CHHapticEngine?
    
    // Device support check - note: simulators always return false, which is expected
    let isSupported: Bool
    
    // Logging
    private static let logger = Logger(subsystem: "com.hapticx.engine", category: "HapticEngine")
    
    // MARK: - Initialization
    
    init() async {
        isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        if isSupported {
            await createEngine()
        } else {
            Self.logger.info("Device does not support haptics (expected on simulator)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Ensures the haptic engine is started and ready (with auto-recovery)
    func startIfNeeded() async throws {
        guard isSupported else {
            throw HapticxError.deviceNotSupported
        }
        
        // Lazy creation + self-healing: recreate engine if nil
        if engine == nil {
            await createEngine()
        }
        
        guard let engine = engine else {
            throw HapticxError.engineNotInitialized
        }
        
        if state == .ready {
            return
        }
        
        do {
            try await engine.start()
            state = .ready
            Self.logger.debug("Engine started successfully")
        } catch {
            throw HapticxError.startFailed(error)
        }
    }
    
    /// Plays a haptic pattern
    func play(pattern: CHHapticPattern) async throws {
        try await startIfNeeded()
        
        guard let engine = engine else {
            throw HapticxError.engineNotInitialized
        }
        
        do {
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            // Note: No state change as transient haptics are too brief to track accurately
        } catch {
            throw HapticxError.playFailed(error)
        }
    }
    
    /// Stops the haptic engine and releases resources
    func stop() async {
        // Immediately set state to stopped and clear engine reference
        state = .stopped
        
        if let engine = engine {
            try? await engine.stop()
            Self.logger.debug("Engine stopped and released")
        }
        
        // Release the engine - startIfNeeded() will recreate when needed
        engine = nil
    }
}

// MARK: - Private Methods

private extension HapticxEngine {
    
    /// Creates the CHHapticEngine instance (doesn't start it)
    func createEngine() async {
        guard isSupported else { return }
        
        do {
            engine = try CHHapticEngine()
            setupHandlers()
            Self.logger.debug("Engine created successfully")
        } catch {
            Self.logger.error("Failed to create engine: \(error.localizedDescription)")
        }
    }
    
    /// Sets up system event handlers
    func setupHandlers() {
        engine?.resetHandler = { [weak self] in
            Task { [weak self] in
                await self?.handleReset()
            }
        }
        
        engine?.stoppedHandler = { [weak self] reason in
            Task { [weak self] in
                await self?.handleStopped(reason)
            }
        }
    }
    
    /// Handles engine reset by system - recreate engine for self-healing
    func handleReset() async {
        Self.logger.info("Engine reset by system - recreating")
        state = .stopped
        await createEngine() // Recreate engine instead of just changing state
    }
    
    /// Handles engine stopped by system - recreate engine for self-healing
    func handleStopped(_ reason: CHHapticEngine.StoppedReason) async {
        Self.logger.info("Engine stopped: \(reason.rawValue) - recreating")
        state = .stopped
        
        // Recreate engine for next use instead of just changing state
        await createEngine()
    }
}

