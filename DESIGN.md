# Hapticx 设计文档

## 项目定位

**Hapticx** 是一个现代、轻量、无历史包袱的 Core Haptics 封装库，专注于 iOS 16+ 平台。

## 核心理念

- **现代优先**：iOS 16+，Swift 5.9+，Swift Concurrency
- **生命周期为王**：把最难的 CHHapticEngine 管理做到极致稳定
- **简洁胜于复杂**：API 设计追求"少即是多"
- **无历史包袱**：不考虑向下兼容，专注做好一件事

## 技术规格

- **平台**：iOS 16+
- **语言**：Swift 5.9+
- **并发模型**：Swift Concurrency（actor 负责引擎状态）
- **核心依赖**：Core Haptics（无 UIKit 耦合）

## 架构设计

```
┌─────────────────────────────────────────┐
│              Hapticx API                │  <- 对外接口层
├─────────────────────────────────────────┤
│         HapticEngine (actor)            │  <- 引擎管理层 (核心)
├─────────────────────────────────────────┤
│      Pattern Builder & Player           │  <- 模式构建层
├─────────────────────────────────────────┤
│           CHHapticEngine               │  <- Core Haptics
└─────────────────────────────────────────┘
```

## 核心能力

### 1. 引擎生命周期管理（最高优先级）

- **单实例 + 线程安全**：使用 actor 管理 CHHapticEngine、启动状态、player 缓存
- **Lazy 启动**：第一次播放前自动 start()；App 前台时可选择预热
- **停止/恢复**：提供 appDidBecomeActive() / appWillResignActive() 入口；进入后台停止，回前台重启
- **中断/回收处理**：
  - 监听 stoppedHandler（如 audio session 中断、应用挂起）
  - 监听 resetHandler（系统回收资源后可重建）
  - 遵循"**下一次播放自动恢复**"原则，避免让业务处理引擎故障
- **能力检测**：初始化时读取 supportsHaptics；模拟器与不支持设备应**静默**（不抛错、不崩溃）
- **主线程约束**：Core Haptics 可在任意线程调用；但库应保证与 App 生命周期钩子互操作时的线程安全

### 2. 播放接口（语义化、少即是多）

简洁的函数式 API：
```swift
// 瞬态播放
Hapticx.tap(intensity: 0.7, sharpness: 0.5)

// 连续播放
Hapticx.buzz(duration: 2.0, intensity: 0.8, fadeOut: 0.5)

// 语义化预设  
Hapticx.success()
Hapticx.alignGuide() 
Hapticx.charging(progress: 0.7) // 可选的进度感知

// 停止控制
Hapticx.stopAll()
Hapticx.stopCurrent()
```

### 3. Pattern 构建（轻量 DSL）

现代化的 DSL 设计：
```swift
let pattern = HapticPattern {
    tap(.light)
    wait(0.1)
    tap(.heavy) 
    buzz(duration: 0.5, intensity: 0.6)
}
Hapticx.play(pattern)
```

- **事件类型**：transient / continuous
- **基础参数**：intensity、sharpness、relativeTime、duration
- **参数曲线**：最少支持 intensity 的控制曲线（如淡入/淡出、节拍点加强）
- **组合能力**：多个事件/曲线按时间线组合为一个 Pattern
- **人类语义预设**：tap, success, charging（重质不重量）

### 4. Player 策略

- **瞬态**：临时 player 即用即弃即可（开销小）
- **连续**：建议用 CHHapticAdvancedPatternPlayer，支持 loop、pause/resume、参数更新
- **池化（可选）**：连续型可复用 player，降低重复构建成本

### 5. 节流/去抖（默认关闭，但可配置）

- **为什么需要**：避免"糊成一片"、省电、规避高频触发被系统忽略
- **默认策略**：频率很低（≤ 3 次/秒），**默认不启用**节流
- **保留开关**：允许在某个调用点临时启用
- **推荐默认阈值（仅当启用时生效）**
  - selection：**≥ 40–50ms**
  - impact（瞬态击打）：**≥ 80–120ms**
  - notification（语义通知，如成功/错误）：**≥ 300–500ms**
- **策略形式**：按"事件类别"维护 minInterval；实现"**最小间隔 + 更新时间戳**"的轻量去抖

### 6. 配置与开关

- **全局开关**：isEnabled（默认开启）；提供 runtime 动态关闭入口
- **强度缩放**（可选）：全局 master gain（对 intensity 的线性缩放 0.0–1.0）
- **节流策略**：全局默认 + 自定点位覆盖
- **日志（可选）**：DEBUG 下简单统计（播放成功/跳过/中断原因）

### 7. 错误与健壮性

- **失败静默**：引擎不可用、播放失败、中断等情况不抛向业务层
- **自恢复**：下一次调用自动尝试 startIfNeeded()
- **可观测（可选）**：提供轻量的 hooks（调试 build 下）便于开发期定位问题

### 8. SwiftUI 适配（可选）

- **不强绑定** SwiftUI；提供一个小的 HapticxModifier 或函数型桥接
- **不内置 .sensoryFeedback**（保持与 Core Haptics 解耦）

### 9. 性能与功耗基线

- **首次播放延迟**：引擎冷启动后首次播放 ≤ 1 帧感知（建议前台时预热）
- **持续播放**：连续型模式 CPU 占用低、无 UI 卡顿
- **功耗**：避免每帧 prepare 或频繁建引擎；模式合理稀疏、曲线点数控制

## 与现有方案的差异化

| 方面 | Haptica | Hapticx |
|------|---------|---------|
| 版本支持 | iOS 13+ (兼容包袱) | iOS 16+ (现代化) |
| 并发模型 | 传统锁 + OperationQueue | Swift Actor |
| 引擎管理 | 简单全局变量 | 专门的 actor 生命周期管理 |
| 错误处理 | 静默 log | 自恢复 + 可观测性 |
| API 风格 | enum + generate() | 函数式 + 语义化 |
| UIKit 耦合 | 重度耦合 UIFeedback | 完全解耦，纯 Core Haptics |
| AHAP 支持 | iOS 16+ 支持 | 保留扩展接口位置（初版不实现） |

## 实现优先级

1. **HapticEngine Actor** - 引擎生命周期管理（核心基础）
2. **基础播放 API** - tap/buzz 等核心接口
3. **Pattern DSL** - 支持复杂序列构建
4. **语义化预设** - success/charging 等人性化接口
5. **配置与节流** - 可选的高级特性
6. **SwiftUI 集成** - modifier 支持

## 文档与示例

- **README**：一句话定位 + iOS 16+ + 使用三步（初始化/播放/可选生命周期）
- **示例 App**（最小）：3 个按钮（tap / success / charging）+ 一个可开关的"启用节流"
- **迁移指南**（可选）：若后续加 AHAP 支持，说明如何扩展使用

## 开发原则

- **不内置 UIKit 的 UIFeedback 回退**
- **不默认支持 AHAP 文件**（仅保留将来扩展位）
- **失败时静默处理**，不向业务层抛出异常
- **遵循 Swift 现代化最佳实践**