# Hapticx

A modern, lightweight Core Haptics wrapper for iOS 16+.

## Features

- 🎯 **Modern Swift**: Built with Swift 5.9+ and Swift Concurrency
- 🛡️ **Thread Safe**: Actor-based architecture for safe concurrent access
- 🔄 **Auto Recovery**: Intelligent engine lifecycle management
- ⚡ **Lazy Loading**: Engine starts only when needed
- 🎨 **Semantic API**: Human-readable haptic feedback methods
- 📱 **iOS 16+**: No legacy baggage, pure Core Haptics

## Quick Start

### Installation

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/yourusername/Hapticx.git", from: "1.0.0")
```

### Basic Usage

```swift
import Hapticx

// Simple tap
await Hapticx.tap(intensity: 0.7, sharpness: 0.5)

// Continuous buzz
await Hapticx.buzz(duration: 2.0, intensity: 0.8)

// Semantic feedback
await Hapticx.success()
await Hapticx.error()
```

## Requirements

- iOS 16.0+
- Swift 5.9+
- Device with Taptic Engine support

## License

MIT License. See LICENSE for details.
