# Pitchsong: App Store Connect pack

Everything below is ready to copy into App Store Connect. Nobody can promise approval, but this
covers what Apple asks for and removes the usual reasons for rejection.

## 1. Build requirements
- Apple requires apps uploaded since 28 April 2026 to be built with **Xcode 26 or later** (iOS 26 SDK).
  Codemagic's `xcode: latest` does this. The project is set up for Xcode 26.
- The only package is **Firebase Analytics**, added with Swift Package Manager (no Podfile and no Podfile.lock). CocoaPods'
  Specs repo becomes read-only on 2 December 2026, which is another reason not to add it.
- Privacy manifest: included (`Pitchsong/PrivacyInfo.xcprivacy`). It declares no tracking, no collected
  data, and the one "required reason" API the app uses (UserDefaults, reason CA92.1).
- Encryption: `ITSAppUsesNonExemptEncryption = NO` is set (the app only uses the system's HTTPS).

## 2. App record
| Field | Value |
|---|---|
| Name | Pitchsong |
| Subtitle (max 30) | Music promotion packages |
| Bundle ID | com.kidblunt.pitchsong |
| SKU | pitchsong-ios-1 |
| Primary category | Music |
| Secondary category | Entertainment |
| Price | Free |
| Copyright | 2026 Blunt Entertainment |
| Content rights | No third-party content |

## 3. Required URLs
Host the four pages in the `Website/` folder on your website (for example in the `public/` folder
of the Findock site, so they open at `/privacy.html` etc.).

| App Store Connect field | Page |
|---|---|
| Privacy Policy URL (required) | https://YOUR-DOMAIN/privacy.html |
| Support URL (required) | https://YOUR-DOMAIN/support.html |
| Marketing URL (optional) | https://YOUR-DOMAIN/about.html |

Terms: `terms.html`. The app also shows the Privacy Policy, Terms, About Us and Contact Us inside
the Menu and Settings, which Apple expects.
To change any of this text, edit `Tools/generate_legal.py` and run `python3 Tools/generate_legal.py`.
Both the app and the web pages update together. **Have a lawyer read the Privacy Policy and Terms.**

## 4. Store text (paste in)
**Promotional text (max 170)**
Pick a promotion package, send your order on WhatsApp, and put your music in front of playlist curators, creators and music blogs.

**Description**
Pitchsong by Blunt Entertainment helps independent artists promote their music.

Choose from clear packages for:
• Spotify playlist promotion: your song pitched to playlist curators
• TikTok music marketing: creators using your sound
• Instagram music campaigns: Reels and posts that use your sound
• Blog and press campaigns: features on music and entertainment websites
• Full combo packages that bring them together

How it works
1. Add your song link, genre and the package you like.
2. Send your order to our team on WhatsApp.
3. We confirm the price and details, then run your campaign.

Also in the app
• My Requests: keep track of the orders you started
• Optional Friday reminder when new playlists are open for pitching
• Light and dark mode

Good to know: curators, creators and blogs always decide for themselves whether to feature a song.
We do not guarantee placements, streams or followers, and we never buy placements or sell fake streams.
Payment is arranged directly with Blunt Entertainment on WhatsApp, outside the app.

Pitchsong is not affiliated with, endorsed by or sponsored by Spotify, TikTok, Instagram, WhatsApp or Apple.

**Keywords (max 100, comma separated, no spaces after commas)**
`music promotion,artist,playlist,pitch,songs,independent,Afrobeats,release,marketing,blog,promo`
Do not put brand names (Spotify, TikTok, Instagram) in the app name, subtitle or keywords.

**What's New** is not needed for version 1.0.

## 5. Screenshots
The app runs on iPhone and iPad, so Apple needs both sets. Check App Store Connect for the exact pixel
sizes it currently asks for (a 6.9-inch iPhone set and a 13-inch iPad set). Take them in the Xcode
simulators. Good screens: Home, Packages, Submit, Menu, light mode, onboarding.

## 6. Age rating (questionnaire)
Answer "None" to all content questions (violence, sexual content, gambling, horror, drugs, medical,
mature themes, user-generated content, unrestricted web access). Expected rating: **4+**.
The app has no web browser; it only opens WhatsApp, email and Instagram links.

## 7. App Privacy ("nutrition label")
- Tracking: **No**.
- Data collected by the app: **Yes, for analytics only** (Firebase Analytics). Declare:
  - **Usage Data > Product Interaction**: Analytics purpose, linked to the user's device, not used for tracking.
  - **Identifiers > Device ID**: Analytics purpose, linked to the user's device, not used for tracking.
  The app does not use the advertising ID, so the Tracking answer stays **No** and no App Tracking
  Transparency prompt is needed. Do not tick Advertising or Marketing purposes.
  Order details stay on the device unless the user chooses to send them on WhatsApp.

## 8. App Review information
- Sign-in required: **No** (there are no accounts).
- Contact: your name, phone, and email (bluntentertainment1@gmail.com).
- **Notes for the reviewer (paste):**
  > Pitchsong is an order form and catalogue for music promotion services (playlist pitching, creator and
  > blog campaigns) that are delivered by Blunt Entertainment outside the app. The app sells no digital
  > content or features. Prices and payment are arranged directly with the business on WhatsApp, so no
  > in-app purchase is involved. No account is needed. Notifications are an optional, local weekly
  > reminder (Fridays 10:00) that the user turns on in onboarding or Settings. The Menu (top right) holds
  > Settings, Contact us, About us, Privacy policy, Rate app and Share app.

## 9. Other forms
- **Digital Services Act:** if the app is available in the EU you must state whether you are a "trader"
  (you are, as a business) and give an address, phone and email that Apple may show publicly.
- Export compliance: answered by the Info.plist key above.
- Availability: choose countries. Add South Korea only if you are registered there.

## 10. Wording and risk review
Changed from the website text, on purpose:
- "guaranteed placements", "real streams" and "viral" promises removed. Streams are "Est." and every
  package says results vary. (Apple rejects misleading claims, guideline 2.3.)
- Badges "BEST VALUE", "MOST POPULAR", "PREMIUM CHOICE" became "RECOMMENDED", "POPULAR", "TOP TIER".
- Package **names** were renamed to avoid hype words: SUPERSTAR > ADVANCED, A-LIST > ULTIMATE,
  TIKTOK TRENDING > TIKTOK RISING, INSTAGRAM VIRAL > INSTAGRAM BOOST, VIRAL COMBO > MOMENTUM COMBO,
  GATEKEEPERS COMBO > CURATOR COMBO. Keep your price list in step with these names.

Possible review questions:
- **Payment outside the app (3.1.1 / 3.1.3):** allowed for services consumed outside the app, which is
  why the app never sells anything digital and the review notes explain it. Reviewers decide case by case.
- **Minimum functionality (4.2):** the app is more than a web page (native order flow, saved requests,
  reminders, light/dark mode), but a thin app can still be questioned. Adding features helps.
- **Ratings prompt (5.6):** the app uses Apple's own prompt only, once, 3 days after install. The
  "Rate app" button opens the App Store review page once `AppConfig.appStoreID` is filled in.
- **Notifications (4.5.4):** opt-in, explained first, can be turned off in Settings, no advertising.

## 11. Before you press Submit
1. Create the app record, then paste the numeric Apple ID into `Pitchsong/Models/AppConfig.swift`
   (`appStoreID`).
2. Upload `Website/*.html`, and fill in the three URLs above.
3. Run the **ios-build-check** workflow in Codemagic first, then **ios-release** for TestFlight.
4. Test on a real iPhone and a real iPad: onboarding, menu, dark/light switch, notification permission,
   Friday reminder (Settings > toggle), WhatsApp order.
5. Add screenshots, answer the questionnaires, attach the build, submit.
