# Hapticx

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A lightweight Swift Core Haptics library for iOS with async/await, reusable haptic patterns, sequence builder, and lifecycle-safe playback.

Hapticx is a small Swift haptics package built on Core Haptics and `CHHapticEngine`. It gives iOS apps a simple API for haptic feedback while keeping engine startup, recovery, lifecycle handling, and unsupported hardware checks out of feature code.

[中文简介](README.zh.md)

## Why Hapticx

Core Haptics is powerful, but app code often repeats the same setup: create a `CHHapticEngine`, check hardware support, build `CHHapticPattern` events, recover from resets, and avoid simulator failures. Hapticx keeps that layer compact and reusable.

Use the simple semantic API for common UI feedback, or compose a haptic sequence when timing, intensity, sharpness, and duration matter. It is still a lightweight library, not a full audio or game feedback framework.

## Features

- Core Haptics playback backed by `CHHapticEngine`
- Simple feedback calls: `tap`, `buzz`, `success`, `error`, `warning`, `selection`
- Swift Concurrency internally, with actor-based engine management
- Reusable haptic patterns and a chainable haptic sequence builder
- Type-safe intensity, sharpness, and duration presets with custom values
- Lifecycle-safe playback with explicit app active/inactive hooks
- Graceful no-op behavior on simulators or devices without haptics
- No external dependencies

## Installation

### Swift Package Manager

Add Hapticx in Xcode using **File > Add Package Dependencies**, or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Weixi779/Hapticx.git", from: "0.1.0")
]
```

Then add `Hapticx` to your app target.

## Quick Start

```swift
import Hapticx

Hapticx.tap()
Hapticx.tap(.heavy, sharpness: .sharp)

Hapticx.buzz(duration: .medium, intensity: .heavy)
```

The public calls are intentionally small. Hapticx handles the Core Haptics engine work behind the scenes.

## Semantic Feedback

Use semantic haptic feedback for common app states:

```swift
Hapticx.success()
Hapticx.error()
Hapticx.warning()
Hapticx.selection()
```

You can also pass semantic patterns through the direct feedback API:

```swift
Hapticx.playFeedback(.success)
Hapticx.playFeedback(.buzz(.short, intensity: .medium, sharpness: .soft))
```

## Sequence Builder

Compose a haptic sequence with taps, waits, continuous events, and semantic feedback:

```swift
Hapticx.playSequence { builder in
    builder
        .tap(.light)
        .wait(.short)
        .continuous(.medium, intensity: .heavy)
        .wait(.short)
        .success()
}
```

This is useful for haptic patterns in games, rhythm interactions, workout cues, onboarding moments, or custom controls.

## Custom Events

For precise timing, build a haptic sequence directly with events:

```swift
Hapticx.playEvents([
    .tap(intensity: .light, sharpness: .soft, at: 0.0),
    .continuous(duration: .short, intensity: .medium, sharpness: .medium, at: 0.12),
    .tap(intensity: .heavy, sharpness: .sharp, at: 0.35)
])
```

Available value types:

```swift
HapticxIntensity.light
HapticxIntensity.medium
HapticxIntensity.heavy
HapticxIntensity.custom(0.85)

HapticxSharpness.soft
HapticxSharpness.medium
HapticxSharpness.sharp
HapticxSharpness.custom(0.7)

HapticxDuration.short
HapticxDuration.medium
HapticxDuration.long
HapticxDuration.custom(0.45)
```

## SwiftUI Example

```swift
import SwiftUI
import Hapticx

struct CheckoutButton: View {
    var body: some View {
        Button("Confirm") {
            Hapticx.success()
        }
    }
}
```

For SwiftUI haptics with app lifecycle handling:

```swift
import SwiftUI
import Hapticx

@main
struct DemoApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        Hapticx.applicationDidBecomeActive()
                    case .inactive, .background:
                        Hapticx.applicationWillResignActive()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
```

## Lifecycle Handling

Hapticx lazily creates its `CHHapticEngine`, starts it when needed, and recreates it after system resets or stops. You can also forward app lifecycle events so the engine can start or release resources at the right time:

```swift
Hapticx.applicationDidBecomeActive()
Hapticx.applicationWillResignActive()
```

## Device Support

Hapticx checks `CHHapticEngine.capabilitiesForHardware().supportsHaptics` before playback. On simulators and unsupported devices, calls return without throwing or crashing.

Test haptic feedback on real hardware. Simulator support is expected to be limited.

## When to Use Hapticx

- You want iOS haptics built on Core Haptics instead of only `UIImpactFeedbackGenerator`
- You need simple semantic feedback plus reusable haptic patterns
- You want to compose a haptic sequence with timing, waits, and continuous events
- You prefer Swift Package Manager and a small dependency surface
- You want engine lifecycle handling without scattering `CHHapticEngine` code across your app

## When Not to Use Hapticx

- You only need one or two basic UIKit feedback calls
- You need audio-haptic synchronization or advanced Core Haptics parameter curves
- You need a cross-platform abstraction for Android, watchOS, or web haptics
- You want a visual editor or a complete game feedback system

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Roadmap

- More documented reusable haptic patterns
- Optional async public APIs for callers that want explicit playback control
- Additional examples for SwiftUI haptics and interaction-heavy apps
- Tests for event conversion and sequence ordering

## License

Hapticx is available under the MIT License. See [LICENSE](LICENSE) for details.
