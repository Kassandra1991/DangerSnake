# DangerSnake — iOS / TestFlight

## Requirements

- Unity 6 LTS (or 2022.3+) with **iOS Build Support**
- macOS + Xcode (current App Store version)
- Apple Developer Program membership (~$99/year)

## Build

1. Unity: **DangerSnake → Build → iOS (Xcode / TestFlight)**
2. Open `Builds/iOS/Unity-iPhone.xcodeproj` (or `.xcworkspace` if CocoaPods appears)
3. Select your **Team** under Signing & Capabilities (Automatic signing)
4. Bundle ID default: `com.dangersnake.game` — change if taken
5. Product → **Archive**
6. Organizer → **Distribute App** → App Store Connect → Upload
7. In [App Store Connect](https://appstoreconnect.apple.com): enable **TestFlight**, add internal/external testers

## Device notes

- Orientation: portrait + landscape allowed
- Input: **swipe** to steer (keyboard still works in Editor)
- Minimum iOS: **13.0**

## First App Store listing (later)

- Privacy policy URL if you add analytics/ads
- Screenshots for iPhone 6.7" and iPad 12.9"
- Age rating questionnaire (likely 9+ for mild fantasy violence)
