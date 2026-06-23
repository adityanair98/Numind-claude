# Implementation Rules

> **Last updated:** May 2026 (after Phase 1 audit fixes — `lastVerified` field, IDR concept reframe, realisticMinPayment formula, Parent PLUS rate update, OOP max carve-outs, HoH standard deduction).

Rules for building Numind. These supplement the top-level CLAUDE.md and apply to all implementation work.

## Product Framing

- Numind is a **financial education app**. Math is the *teaching method*, not the product. When evaluating any change (UI, content, copy, feature), ask: "Does this help the user become more financially competent and confident?" — not "Does this make the math drill better?"
- The differentiator vs other financial-literacy apps: we teach the **math behind** every concept so users can *apply* the knowledge in real moments. Lessons that don't compress into a usable mental-math shortcut should be concept lessons (text MCQ), not forced into numerical drills.

## Business Model

- **Numind is a paid app with a free trial. There is no free version.**
- The onboarding flow is a conversion funnel — every screen should build toward the paywall.
- Onboarding signals (motivation, confidence, topic interest) feed into the app experience: starting difficulty, daily challenge tuning, recommendation priority.
- Streak protection (freeze/restore) is a subscription perk — available during trial, locked after trial expires without subscription.
- All features should be evaluated through retention (does this keep subscribers?) and conversion (does this justify paying?).

## Architecture

- **MVVM.** Views observe ViewModels. ViewModels are `@StateObject` or `@ObservedObject`, never singletons.
- **ProgressStore** is the single source of truth for user state. Inject as `@EnvironmentObject` at the app root. Never create a second instance.
- **ContentRepository** protocol abstracts content access. Use `LocalContentRepository` (JSON-backed) in V1. Do not hardcode content in views.
- **Feature ViewModels** own their data preparation. Views should contain layout only, not business logic.
- **Keep files small.** One view or one ViewModel per file. Extract reusable components into `Core/DesignSystem/Primitives/`.

## Content

- **All quiz content lives in JSON** (`Resources/LocalContent/`). Never hardcode questions, answers, or explanations in Swift files.
- **Quiz templates are parametric.** Variables are randomized at generation time via `QuizEngine.generate()`. Do not create templates with fixed values.
- **Every lesson must have exactly 5 quiz template IDs.** The quiz engine cycles through them to produce 5 questions on first attempt or 8 on subsequent attempts (diagnostic calibration may adjust).
- **Answer formulas** live in `QuizEngine.swift` as a `[String: ([String: Double]) -> Double?]` dictionary. New templates should reuse existing formulas when possible. Only add a new formula if no existing one covers the calculation.
- **Template IDs** follow the pattern `{topic}_{concept}_{variant}_d{difficulty}` (e.g., `tip_percent_basic_d1`).
- **Module IDs** are lowercase snake_case: `smart_shopping`, `money_math`, `salary`, `investing`, `debt`, `housing`, `taxes`, `insurance`, `car`, `student_loans`.
- **`lastVerified` date** is optional but should be set on any lesson whose content references regulated numbers (tax brackets, federal loan rates, FICA, IRS limits, FLSA thresholds, deductible standards) at the time of authoring or update. ISO date string (`"yyyy-mm-dd"`). Use it to find stale content for the next audit cycle.
- **When touching regulated content**, always update `lastVerified` to today's date in the same change. If you're updating a number sourced from a specific authority, mention the source in the relevant Swift comment or commit message (e.g. "Per Federal Student Aid, 2025-26 academic year").

## Design System

- **Use design tokens** for all colors, spacing, radii, and typography. Never use raw hex values or magic numbers in views.
- **8 brand colors** only: primaryBlue, deepNavy, mindTeal, insightYellow, softBackground, cardBackground, mutedText, errorSoftRed. Plus their predefined tint tokens.
- **No new colors.** All tints derive from the 8 tokens via opacity overlays or the predefined tint tokens.
- **No gradients** except the softBg→transparent mask under sticky footers.
- **NumindCard** is the base card component. Use it instead of building custom card backgrounds.
- **IconTile** for all tinted icon displays. Pass `size:` parameter for different sizes (36, 48, 52).
- **PillButton** for primary CTAs. Use `.primary` variant by default.
- **ConfettiBurst** for celebration effects. Always pair with `NewBestBadge` in summary views.
- **GoalRing** for the daily goal ring (Phase 10; replaced LevelRing — XP/Level are now hidden fuel, surfaced nowhere). **ReadinessBadge** / **PackReadinessBoard** for per-pack Readiness state.
- **HeroCard** for large hero cards.
- **CalculatorShell** is the base scaffold for every Tools-tab calculator (summary header, input area, collapsible methodology block, global disclaimer). New calculators wrap their inputs/results in it and register in `CalculatorRegistry`.

## Quiz System

- **Dynamic question count.** First attempt at any lesson = 5 questions (gentle intro). Subsequent attempts = 8. Diagnostic calibration adjusts: intermediate users get 5, foundation users get 6, beginner users get 8 on first attempt. Checkpoint reviews always use 8.
- **Completion-based progression.** Any attempt at a lesson (regardless of score) unlocks the next node. Mastery (≥75%) earns a gold star but is NOT required to progress. The SRS handles remediation.
- **Fresh random seeds on every generate call.** Retries produce different numbers automatically — do not cache or reuse question instances.
- **Proportional distractors.** The `niceStep` algorithm generates wrong answers at ~5-8% of the correct answer, rounded to psychologically natural numbers. Never use fixed step sizes.
- **Checkpoint reviews** appear after every 3 lessons within a module. They round-robin across covered lessons' templates.
- **Review IDs** use the format `review_{moduleId}_{groupIndex}` (e.g., `review_smart_shopping_0`).

## Tools Tab (replaced the game-mode "Practice" tab in Phase 7a)

- **The Practice tab and all timed game modes — Speed Drill, Blitz, Streak, Estimation, Comparison — were retired in Phase 7a.** Their views, view models, and supporting engines (`BlitzEngine`, `MasteredTemplatePool`, `ModeCard`, `EstimationSlider`, `PracticeQuizContainer`) were deleted. The per-mode personal-best fields remain in `ProgressData` for snapshot back-compat, but no UI writes them anymore.
- **The Tools tab replaced Practice in `RootTabView`** (`NumindTab.tools`, SF Symbol `wrench.and.screwdriver.fill`). It hosts 12 in-app calculators built on `CalculatorShell` and dispatched through `CalculatorRegistry.view(for:)`. Lessons deep-link to a calculator via `Lesson.relatedCalculatorSlug`.
- **Recall was retired in Phase 10-A8** and folded into the one consolidated **Refresh**. Build the Refresh session with `RefreshSessionBuilder.build(masteredLessonIds:sessions:repository:)` — stale mastered skills (SRS-overdue) first, then unfixed mistakes (latest attempt wrong), max 8 questions with fresh values. No personal-best to persist (the Recall best + its celebration retired with the mode).
- **Daily Workout** is built by `DailyWorkoutEngine.plan(...)` (Phase 10): a date-seeded, deterministic 5–8 question plan in three labeled segments — Warm-up / Focus / Decision — pack-aware when a focus pack is set. Any recorded practice marks the day for the streak (`DailyRingEngine.markActiveDay`); closing the ring is the daily *goal*. The storage key `numind.dailyChallenge.lastCompleted` is kept for back-compat; user-facing strings say "Daily Workout."

## Celebration / Personal Best

- **Capability milestones (Phase 10).** Personal-best/volume ceremonies are retired. Full-screen celebrations fire on capability only — first skill mastered, first pack Ready, 3 packs Ready, first refresh-save, 7/14-day streak, accuracy jump (≥20-question sample), first freeze — via `MilestoneEngine`; pack/topic *completion* lives in the `Celebration` queue.
- **`ConfettiBurst`** is a reusable Canvas + TimelineView confetti particle system in `Core/DesignSystem/Primitives/ConfettiBurst.swift`. 60 particles, 3-second duration, fires on appear. Use as a ZStack overlay on summary views: `if viewModel.isNewBest { ConfettiBurst() }`.
- **`NewBestBadge`** is a reusable golden trophy capsule badge (also in `ConfettiBurst.swift`). Spring bounce-in animation on appear. Summary views show it when `isNewBest` is true.

## Mid-Session Motivators

- **MotivatorEngine is pure.** No side effects, no state. The ViewModel owns `motivatorsShownAt` and passes it into each evaluation call.
- **Hard constraint:** Motivators NEVER fire after the last question. Enforce with `guard remainingAfter > 0` before any evaluation.
- **Max 2 per session.** Do not raise this — research shows >2 crosses from motivating to annoying.
- **2-question cooldown.** At least 2 questions between any two full-screen motivators.
- **Priority order:** Coaching > Momentum > Progress > Near Finish. Struggling users need help more than succeeding users need celebration.
- **Coaching tips** reuse `Lesson.shortcut` and `Lesson.example` — no new content fields. Look up via `ContentRepository.lesson(forTemplateId:)`.
- **Inline encouragement** is non-blocking, does not count toward the 2-motivator cap, and has its own 3-question cooldown.
- **Copy rotation.** Always use `MotivatorCopy` static methods to pick copy — they randomize from 4-5 variants per type. Never hardcode motivator text in views.

## Navigation

- **4 tabs:** Home, Learn, Progress, Profile (via `RootTabView`).
- **Lessons and reviews** open as `.fullScreenCover` from the Learn tab.
- **Level-up** uses a nested `.fullScreenCover` from within the lesson/review view.
- **Session summary** is a phase within the lesson/review view (not a separate navigation destination).

## Launch Screen & Appearance

- **LaunchScreen.storyboard** is the native launch screen. Do not switch back to the `UILaunchScreen` Info.plist dictionary — the storyboard supports multiple Auto Layout views (logo + wordmark) which the dictionary cannot.
- **SplashView** must use a `ZStack` layout matching the storyboard exactly (logo at center, wordmark at bottom). Do not use a `VStack` — it shifts the logo above center.
- **Appearance override** is set via `SceneDelegate` (`UIWindow.overrideUserInterfaceStyle`), not via SwiftUI `.onAppear`. The SceneDelegate fires before the launch screen dismisses, which is required for iOS to cache the correct appearance snapshot.
- **Do not remove the dark variant** of `LaunchBackground.colorset`. Light and dark modes use different background colors (brand blue vs dark navy).
- **LaunchWordmark** uses the white text variant (`wordmark_dark`) for both light and dark modes. White has better contrast on both the blue and navy backgrounds.
- **When editing LaunchScreen.storyboard**, use `targetRuntime="iOS.CocoaTouch"` and `toolsVersion="13122.16"` (Xcode's own template format). Do not use `targetRuntime="AppleSDK"` — it causes Xcode to reject the file.

## Persistence

- **UserDefaults** via `ProgressStore` wrapping `ProgressData` (Codable). Will migrate to Supabase for cloud sync.
- **SessionRecord** per completed quiz. Includes `questionResults` array and `bonusXP`.
- **AppStorage** for user preferences (name, reminder settings, appearance).

## Auth & Subscriptions

- **Numind is a paid app with a free trial. There is no free version.**
- **Auth provider:** Supabase Auth. Support Sign in with Apple (required by App Store if any third-party login is offered) + email/password.
- **Onboarding runs anonymous.** No account creation until the user reaches the paywall. This maximizes sunk cost from the onboarding funnel (motivation → topics → mini-quiz → personalized plan → paywall).
- **Paywall provider:** RevenueCat. Hard paywall after free trial. Placed at end of onboarding funnel.
- **Subscription gates content.** After trial expiry without subscription: hard paywall blocks lessons/quizzes. Home screen visible in locked state.
- **Streak protection** (freeze/restore) is a subscription perk. Available during trial, locked after expiry.
- **Onboarding signals** (motivation, confidence, topic interest) feed into the app experience: starting difficulty, daily challenge tuning, recommendation priority.
- **Restore purchases** available in Profile for reinstall/device switch scenarios.

## Testing

- **SeededRandomGenerator** enables deterministic quiz generation in tests.
- **Build command:** `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project apps/ios/Numind.xcodeproj -scheme Numind -destination 'platform=iOS Simulator,id=A00ED55E-04B9-451C-8D49-57E6BB17EF78' CODE_SIGNING_ALLOWED=NO build`
- **Regenerate project file** with `xcodegen` after adding/removing Swift files.

## Do Not

- Do not add AI-generated content.
- Do not use SwiftData (deferred until backend lands).
- Do not introduce new hex colors — derive from existing tokens.
- Do not skip the design token layer with raw values.
- Do not assume a free tier or freemium model — Numind is paid with a free trial.
