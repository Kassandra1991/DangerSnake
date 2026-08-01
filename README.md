# DangerSnake

Native **SwiftUI** arcade (iPhone + iPad): **you are the apple**. An AI snake hunts you — grab **Shield**, **Bomb**, **Sword**, or **Boomerang** and fight back.

## Open & run (primary)

1. Install Xcode 16+ (iOS 17 SDK)
2. Open [`DangerSnake/DangerSnake.xcodeproj`](DangerSnake/DangerSnake.xcodeproj)
3. Select an iPhone or iPad simulator (or your device)
4. Set your **Team** under Signing if running on device
5. Press **Run**

Bundle ID: `com.dangersnake.game`  
Deployment: **iOS 17.0+**, universal (`TARGETED_DEVICE_FAMILY = 1,2`)

### Controls

Swipe the board or use on-screen arrows to move **the apple**.

### Layout

```
DangerSnake/                 # Xcode app
  DangerSnakeApp.swift
  App/RootView.swift
  Features/Menu|Game/        # SwiftUI screens + Canvas board
  Core/                      # grid + config
  Gameplay/                  # engine, player apple, snake AI, items
  Items/                     # effects + combat
  Input/                     # swipe gesture
  Resources/                 # Assets + Info.plist
Unity/                       # archived Unity WebGL/iOS prototype
```

## Gameplay

- You are the apple; the snake AI hunts you
- Pick up **Shield** (blocks one bite), **Bomb** / **Sword** / **Boomerang** to damage the snake
- Touch the snake while armed to strike; get eaten without a shield → Game Over

## Unity (archived)

The earlier Unity prototype lives under [`Unity/`](Unity/). See [`Unity/Docs/`](Unity/Docs/) for itch.io / TestFlight notes if you revive that path.
