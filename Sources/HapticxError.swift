import Foundation

// MARK: - Haptic Errors

public enum HapticxError: Error, LocalizedError {
    case deviceNotSupported
    case engineNotInitialized
    case startFailed(Error)
    case playFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .deviceNotSupported:
            return "Device does not support haptics"
        case .engineNotInitialized:
            return "Haptic engine failed to initialize"
        case .startFailed(let error):
            return "Failed to start engine: \(error.localizedDescription)"
        case .playFailed(let error):
            return "Failed to play haptic: \(error.localizedDescription)"
        }
    }
}