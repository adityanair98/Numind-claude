# Tech Stack

## iOS
- SwiftUI
- Swift 5.9+
- Deployment target: iOS 17.0
- MVVM
- UserDefaults for local persistence in V1 (SwiftData deferred until backend lands)
- Swift Package Manager (no third-party packages in V1)
- UIKit bootstrap layer: `AppDelegate` + `SceneDelegate` for early window appearance override; `LaunchScreen.storyboard` for native launch screen with Auto Layout (logo + wordmark)

## Backend Later
- Supabase Auth
- Supabase Postgres
- Supabase Edge Functions
- Supabase Storage

## Payments Later
- RevenueCat
- Apple In-App Purchases
- 7-day free trial

## Analytics Later
- PostHog

## Crash Reporting Later
- Sentry

## Website Later
- Next.js
- Vercel
- Tailwind
- Supabase