# Hapticx 中文简介

Hapticx 是一个面向 iOS 16+ 的轻量 Swift Core Haptics 库，用更简单的 API 使用 `CHHapticEngine`、可复用 haptic patterns、haptic sequence builder 和生命周期安全的播放管理。

## 解决什么问题

直接使用 Core Haptics 时，业务代码经常需要重复处理这些细节：

- 创建和启动 `CHHapticEngine`
- 检查设备是否支持 haptics
- 组装 `CHHapticPattern` 和事件时间线
- 处理 engine reset、stop 和 App 生命周期
- 避免模拟器或不支持 haptics 的设备崩溃

Hapticx 把这些重复逻辑收进一个小库里，让 App 代码只关心要播放什么触感反馈。

## 为什么不是简单 UIImpactFeedbackGenerator 封装

`UIImpactFeedbackGenerator` 很适合基础点击反馈，但它不能表达更复杂的 Core Haptics 事件组合。Hapticx 底层围绕 Core Haptics 和 `CHHapticEngine` 设计，支持 transient tap、continuous feedback、intensity、sharpness、duration 和带时间间隔的 sequence builder。

因此它既能保留简单调用：

```swift
Hapticx.success()
Hapticx.selection()
```

也能组合更明确的触感节奏：

```swift
Hapticx.playSequence { builder in
    builder
        .tap(.light)
        .wait(.short)
        .continuous(.medium, intensity: .heavy)
        .wait(.short)
        .tap(.heavy, sharpness: .sharp)
}
```

## 适合哪些场景

- App 中的成功、失败、警告、选择等语义反馈
- SwiftUI 或 UIKit 交互反馈
- 游戏、节奏、健身、倒计时、训练提示等需要触感节奏的场景
- 自定义控件、滑块、拖拽、确认操作等需要更细反馈的界面
- 希望使用 Swift Package Manager 引入的轻量 haptics 依赖

如果你只需要一两个最基础的 UIKit 反馈，直接使用系统 generator 可能就够了。Hapticx 更适合需要 Core Haptics 能力，但又不想在业务代码里维护 engine 生命周期的项目。

## 快速示例

```swift
import Hapticx

Hapticx.tap()
Hapticx.tap(.heavy, sharpness: .sharp)
Hapticx.buzz(duration: .medium, intensity: .heavy)

Hapticx.success()
Hapticx.error()
Hapticx.warning()
Hapticx.selection()
```

SwiftUI 示例：

```swift
import SwiftUI
import Hapticx

struct ConfirmButton: View {
    var body: some View {
        Button("Confirm") {
            Hapticx.success()
        }
    }
}
```

安装地址：

```swift
.package(url: "https://github.com/Weixi779/Hapticx.git", from: "0.1.0")
```

更多英文说明和完整示例见 [README.md](README.md)。
