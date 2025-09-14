# Hapticx API 设计

## 对外 API 设计 - 枚举式

### 基础设计
```swift
// 主要调用方式
Hapticx.play(.tap(intensity: .medium, sharpness: .sharp))
Hapticx.play(.buzz(duration: 2.0, intensity: .strong, fadeOut: 0.5))
Hapticx.play(.success)
Hapticx.play(.error)

// 或者静态方法快捷方式
Hapticx.tap(.medium, sharpness: .sharp)
Hapticx.success()
```

### HapticFeedback 枚举设计
```swift
public enum HapticFeedback {
    // 瞬态触觉
    case tap(intensity: HapticIntensity = .medium, sharpness: HapticSharpness = .medium)
    
    // 连续触觉
    case buzz(duration: TimeInterval, intensity: HapticIntensity = .medium, fadeOut: TimeInterval = 0)
    
    // 语义化触觉
    case success
    case error
    case warning
    case selection
    
    // 可选：复杂 Pattern
    case pattern(HapticPattern)
}

public enum HapticIntensity: Float, CaseIterable {
    case light = 0.3
    case medium = 0.7
    case strong = 1.0
}

public enum HapticSharpness: Float, CaseIterable {
    case soft = 0.2
    case medium = 0.5
    case sharp = 0.8
}
```

### 自定义 Pattern 设计
```swift
// 简单的 Pattern 构建
public struct HapticPattern {
    let events: [HapticEvent]
    
    public init(@HapticEventBuilder builder: () -> [HapticEvent]) {
        self.events = builder()
    }
}

public enum HapticEvent {
    case tap(intensity: HapticIntensity, sharpness: HapticSharpness, at: TimeInterval = 0)
    case buzz(duration: TimeInterval, intensity: HapticIntensity, at: TimeInterval = 0)
    case wait(TimeInterval)
}

// DSL 构建器
@resultBuilder
public struct HapticEventBuilder {
    public static func buildBlock(_ events: HapticEvent...) -> [HapticEvent] {
        return events
    }
}
```

### 使用示例
```swift
// 简单调用
Hapticx.play(.tap())
Hapticx.play(.buzz(duration: 1.0, intensity: .strong))
Hapticx.play(.success)

// 或快捷方法
Hapticx.tap(.strong, sharpness: .sharp)
Hapticx.success()

// 复杂 Pattern
let customPattern = HapticPattern {
    HapticEvent.tap(intensity: .light, sharpness: .soft)
    HapticEvent.wait(0.1)
    HapticEvent.tap(intensity: .strong, sharpness: .sharp)
}
Hapticx.play(.pattern(customPattern))
```

## Engine State 重命名

当前的 `HapticxEngineState` 确实命名不够准确，建议改为：

### 选择 1: 更准确的状态命名
```swift
enum HapticEngineState {
    case stopped    // 引擎已停止
    case ready      // 引擎已启动，准备播放
}
```

### 选择 2: 更语义化的命名
```swift
enum EngineStatus {
    case inactive   // 未激活
    case active     // 已激活
}
```

### 选择 3: 简化命名
```swift
enum State {
    case off        // 关闭
    case on         // 开启
}
```

你更喜欢哪种 State 命名？我个人倾向于选择 1，`stopped/ready` 比较直观。