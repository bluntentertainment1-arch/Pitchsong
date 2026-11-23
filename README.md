# Pitchsong by Blunt Entertainment (iPhone + iPad)

SwiftUI, iOS 16 or later, built with Xcode 26. One package (Firebase Analytics, via Swift Package Manager), no CocoaPods, no backend.
Bundle ID: `com.kidblunt.pitchsong`. Targeted devices: iPhone and iPad.

## Run it
1. On a Mac with Xcode 26 or later, open `Pitchsong.xcodeproj`.
2. Pitchsong target > Signing & Capabilities > choose your team.
3. Pick an iPhone or iPad simulator and press Run.

## Build with Codemagic
`codemagic.yaml` has two workflows and the shared scheme `Pitchsong` is committed
(`Pitchsong.xcodeproj/xcshareddata/xcschemes`).
- **ios-build-check**: compiles for the simulator with no signing. Run this first.
- **ios-release**: signs, numbers the build and sends it to TestFlight.
Signing and upload use the same variable group and App Store Connect integration as your StrikeScore app, plus a new `PITCHSONG_PROVISIONING_PROFILE_BASE64` variable.

## What is in the app
- Splash screen, then a 4-card onboarding on the first launch only.
- Home, Packages (all 29 from the website), Submit (order via WhatsApp), My Requests.
- **Menu** (round button, top right): Spotify promotions, TikTok promotions, Blog promotions,
  Settings, Contact us, About us, Privacy policy, Rate app, Share app.
- **Settings**: dark / light mode switch, Friday reminder switch, About us, Privacy policy, Terms, Contact.
- Local notification every **Friday 10:00**: "New Hot Playlists are Available, Submit your song for pitching".
  Permission is asked on the last onboarding card or when the Settings switch is turned on.
- iOS rating prompt once, 3 days after install. "Rate app" and "Share app" are in the Menu and Settings.

## Where to change things
| What | File |
|---|---|
| Packages and wording | `Pitchsong/Models/PromotionData.swift` |
| WhatsApp number, email, Instagram | `Pitchsong/Models/Contact.swift` |
| App Store ID, rating delay, share text | `Pitchsong/Models/AppConfig.swift` |
| Friday reminder time and text | `Pitchsong/Services/NotificationManager.swift` |
| Privacy Policy, Terms, About, Contact text | `Tools/generate_legal.py` (then run it) |
| Colors | `Pitchsong/Theme.swift` |

App Store Connect answers, store text and review notes: `AppStore/AppStoreConnect_Checklist.md`.
Website pages for your privacy policy and support URLs: `Website/`.
