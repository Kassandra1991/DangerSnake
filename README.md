# DangerSnake

Authorial snake arcade: you chase the apple — the apple picks up **Shield**, **Bomb**, **Sword**, or **Boomerang** and can strike back.

## Stack

- **Unity** (C#) — one project → **WebGL** + **iOS**
- Scenes: `Boot` → `Menu` → `Game`
- Core scripts under `Assets/Scripts/`

## Open in Unity

1. Install [Unity Hub](https://unity.com/download) + **Unity 6 LTS** (2D / built-in pipeline is enough)
2. Add modules: **WebGL Build Support**, **iOS Build Support** (Mac)
3. Hub → **Open** → this repository folder
4. Press Play on `Assets/Scenes/Boot.unity` (or Menu / Game)

Unity may refresh `ProjectSettings` and package versions on first open — that is expected.

## Controls

| Platform | Input |
|----------|--------|
| Web / desktop | Arrow keys or WASD |
| iPhone / iPad | Swipe |
| Editor | Both |

## Gameplay (v1)

- Snake eats an **unarmed** apple → grow + score
- Random items spawn on the field
- Apple AI: **flee** / **seek item** / **attack** when armed
- **Shield** (snake): blocks one bite
- **Bomb**: cuts ~half the body
- **Sword**: kill on contact
- **Boomerang**: ranged cut of one segment along a grid line

## Builds

Menu bar after scripts compile:

- **DangerSnake → Build → WebGL (itch.io)** → see [Docs/ITCH_IO.md](Docs/ITCH_IO.md)
- **DangerSnake → Build → iOS (Xcode / TestFlight)** → see [Docs/IOS_TESTFLIGHT.md](Docs/IOS_TESTFLIGHT.md)

## Project layout

```
Assets/
  Scenes/           Boot, Menu, Game
  Scripts/
    Bootstrap/      scene entry
    Core/           grid, config
    Gameplay/       snake, apple AI, items, session tick
    Items/          effects + combat
    Input/          IInput, keyboard, swipe, platform
    UI/             board view + HUD
  Editor/           build pipeline menu
  Resources/        GameConfig
Docs/               itch + TestFlight checklists
```
