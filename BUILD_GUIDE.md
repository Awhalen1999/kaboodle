# Build & Release Guide

Quick checklist for building and releasing to the app stores

Keep this file open while building so don't forget to switch back

## Before Building

**1. Switch to Production Config**

- [ ] **Backend URL** - `lib/services/api/endpoints.dart`

  - Comment out: `http://localhost:9000`
  - Uncomment: `https://kaboodle-api.vercel.app`

- [ ] **RevenueCat Keys** - `lib/services/subscription/revenue_cat/Initalize.dart`

  - Replace test keys with production keys (iOS & Android)

- [ ] **PostHog Debug** - `lib/main.dart`

  - Set `config.debug = false` for production

- [ ] **Bump Version** - `pubspec.yaml`
  - Update version: `1.0.0+1` → `1.0.1+2` (or whatever)
  - Remember: build number must always increase!

## Build Commands

**iOS (App Store):**

```bash
flutter build ipa
```

Output: `build/ios/ipa/kaboodle_app.ipa`

**Android (Play Store):**

```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## After Building

**Switch Back to Dev Config**

- [ ] **Backend URL** - `lib/services/api/endpoints.dart`

  - Comment out: `https://kaboodle-api.vercel.app`
  - Uncomment: `http://localhost:9000`

- [ ] **RevenueCat Keys** - `lib/services/subscription/revenue_cat/Initalize.dart`

  - Switch back to test keys

- [ ] **PostHog Debug** - `lib/main.dart`
  - Set `config.debug = true` for development

## Upload to Stores

**App Store Connect:**

- Upload `.ipa` file via Xcode or App Store Connect
- Fill out release notes
- Submit for review

**Google Play Console:**

- Upload `.aab` file
- Fill out release notes
- Submit for review
