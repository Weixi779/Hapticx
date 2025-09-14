# Hapticx

A modern, lightweight Core Haptics wrapper for iOS 16+ built with Swift Concurrency.

## Features

- 🎯 **Simple API**: Easy-to-use static methods and builder pattern
- ⚡ **Swift Concurrency**: Built with actors for thread safety
- 🔄 **Auto Recovery**: Self-healing engine with lifecycle management
- 📱 **iOS 16+ Only**: No legacy compatibility, modern Swift 5.9+
- 🎪 **Type Safe**: Enumerated parameters with custom value support
- 🏗️ **Flexible**: Both direct calls and sequence building

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/username/Hapticx.git", from: "0.1.0")
]
```

Or add via Xcode: **File > Add Package Dependencies**

## Quick Start

### Basic Haptics

```swift
import Hapticx

// Simple tap
Hapticx.tap()
Hapticx.tap(.heavy, sharpness: .sharp)

// Continuous vibration
Hapticx.buzz(duration: .medium, intensity: .heavy)

// Semantic feedback
Hapticx.success()
Hapticx.error()
Hapticx.warning()
Hapticx.selection()
```

### Direct Event API

```swift
// Play events with absolute timing
Hapticx.playEvents([
    .tap(intensity: .light, sharpness: .soft, at: 0.0),
    .continuous(duration: .short, intensity: .medium, at: 0.2),
    .tap(intensity: .heavy, sharpness: .sharp, at: 0.5)
])
```

### Sequence Builder (with wait)

```swift
// Use builder for complex sequences
Hapticx.playSequence { builder in
    builder.tap(.light)
           .wait(.short)
           .continuous(.medium, intensity: .heavy)
           .wait(.medium)
           .success()
}
```

## API Reference

### Basic Types

```swift
// Intensity levels
HapticxIntensity: .light, .medium, .heavy, .custom(Float)

// Sharpness levels  
HapticxSharpness: .soft, .medium, .sharp, .custom(Float)

// Duration presets
HapticxDuration: .short, .medium, .long, .custom(TimeInterval)
```

### Feedback Types

```swift
// Direct feedback
HapticxFeedback.tap(intensity: .medium, sharpness: .sharp)
HapticxFeedback.continuous(duration: .short, intensity: .heavy, sharpness: .soft)

// Semantic presets
HapticxFeedback.success  // Two quick taps
HapticxFeedback.error    // Heavy continuous
HapticxFeedback.warning  // Three sharp taps
HapticxFeedback.selection // Light tap
```

### Lifecycle Integration

```swift
// In your AppDelegate or App
func applicationDidBecomeActive() {
    Hapticx.applicationDidBecomeActive()
}

func applicationWillResignActive() {
    Hapticx.applicationWillResignActive()
}
```

## Architecture

Hapticx uses a clean layered architecture:

```
HapticxFeedback → [HapticxEvent] → CHHapticPattern
     ↓              ↓                ↓
  Semantic       Standard Events   Core Haptics
```

- **Types/**: Basic enums and type definitions
- **Pattern/**: Conversion and processing logic  
- **HapticxEngine**: Actor-based engine management
- **Hapticx**: Main public API entry point

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Device Support

- Hapticx automatically detects device capabilities
- Gracefully handles unsupported devices (simulators)
- Uses lazy initialization for optimal performance

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.
