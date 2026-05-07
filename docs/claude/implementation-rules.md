# Implementation Rules

> **Last updated:** May 2026 (after mid-session motivator checkpoints, splash screen architecture).

Rules for building Numind. These supplement the top-level CLAUDE.md and apply to all implementation work.

## Architecture

- **MVVM.** Views observe ViewModels. ViewModels are `@StateObject` or `@ObservedObject`, never singletons.
- **ProgressStore** is the single source of truth for user state. Inject as `@EnvironmentObject` at the app root. Never create a second instance.
- **ContentRepository** protocol abstracts content access. Use `LocalContentRepository` (JSON-backed) in V1. Do not hardcode content in views.
- **Feature ViewModels** own their data preparation. Views should contain layout only, not business logic.
- **Keep files small.** One view or one ViewModel per file. Extract reusable components into `Core/DesignSystem/Primitives/`.

## Content

- **All quiz content lives in JSON** (`Resources/LocalContent/`). Never hardcode questions, answers, or explanations in Swift files.
- **Quiz templates are parametric.** Variables are randomized at generation time via `QuizEngine.generate()`. Do not create templates with fixed values.
- **Every lesson must have exactly 5 quiz template IDs.** The quiz engine cycles through them to produce 8 questions per session.
- **Answer formulas** live in `QuizEngine.swift` as a `[String: ([String: Double]) -> Double?]` dictionary. New templates should reuse existing formulas when possible. Only add a new formula if no existing one covers the calculation.
- **Template IDs** follow the pattern `{topic}_{concept}_{variant}_d{difficulty}` (e.g., `tip_percent_basic_d1`).
- **Module IDs** are lowercase snake_case: `tips`, `discounts`, `money_math`, `salary`, `investing`, `estimation`, `debt`, `travel`.

## Design System

- **Use design tokens** for all colors, spacing, radii, and typography. Never use raw hex values or magic numbers in views.
- **8 brand colors** only: primaryBlue, deepNavy, mindTeal, insightYellow, softBackground, cardBackground, mutedText, errorSoftRed. Plus their predefined tint tokens.
- **No new colors.** All tints derive from the 8 tokens via opacity overlays or the predefined tint tokens.
- **No gradients** except the softBg→transparent mask under sticky footers.
- **NumindCard** is the base card component. Use it instead of building custom card backgrounds.
- **IconTile** for all tinted icon displays. Pass `size:` parameter for different sizes (36, 48, 52).
- **PillButton** for primary CTAs. Use `.primary` variant by default.
- **ConfettiBurst** for celebration effects. Always pair with `NewBestBadge` in summary views.
- **EstimationSlider** for estimation mode. Custom slider with step snapping, floating callout, correct answer marker, error band, and haptic ticks.
- **NumindScoreRing** for displaying the composite Numind Score in summary views.
- **ModeCard** for game mode cards on the Home tab. Use the convenience constructors (`.speedDrill()`, `.blitz()`, `.streak()`, etc.).
- **HeroCard** for large hero cards (used in Practice tab hero quiz card).

## Quiz System

- **8 questions per session.** Both lesson quizzes and checkpoint reviews generate exactly 8 questions.
- **75% mastery threshold.** 6/8 correct = mastered. This is the gate for unlocking the next node.
- **Fresh random seeds on every generate call.** Retries produce different numbers automatically — do not cache or reuse question instances.
- **Checkpoint reviews** appear after every 3 lessons within a module. They round-robin across covered lessons' templates.
- **Review IDs** use the format `review_{moduleId}_{groupIndex}` (e.g., `review_tips_0`).

## Game Modes

- **MasteredTemplatePool** is the shared gateway for all game modes. Always call `MasteredTemplatePool.mcqTemplates(from:)` or `.templates(from:)` — never read all templates directly for mode content.
- **Game modes only show content from mastered lessons.** Users only get questions on concepts they've learned and passed (≥75%). This enforces the "unlock by learning" progression.
- **MCQ-only for timed modes** (Speed Drill, Blitz). Free-entry questions are excluded — typing under time pressure is frustrating. Filter via `.mcqTemplates(from:)`.
- **Modes are gated** until `MasteredTemplatePool.hasUnlockedModes(progressData:)` returns true. Show locked card UI with "Master a lesson to unlock" when false.
- **Session ID conventions for modes:**
  - Daily Challenge: `lessonId: "daily_challenge"`, `moduleId: "mixed"`
  - Speed Drill: `lessonId: "speed_drill"`, `moduleId: "mixed"`
  - Blitz: `lessonId: "blitz_session"`, `moduleId: "mixed"`
  - Streak: `lessonId: "streak_mode"`, `moduleId: "mixed"`
  - True/False: `lessonId: "true_false"`, `moduleId: "mixed"`
  - Estimation: `lessonId: "estimation"`, `moduleId: "mixed"`
  - Comparison: `lessonId: "comparison"`, `moduleId: "mixed"`
- **Daily Challenge** is 10 questions (bumped from 5). Pass `progressData:` to `DailyChallengeEngine.dailyQuestions(from:progressData:)` to filter to mastered templates.
- **Speed Drill** reuses `QuizSessionViewModel` and `QuizSessionView` with `questionTimeLimit: 15.0`. The view shows a circular countdown ring; timeout = automatic wrong answer.
  - Call `viewModel.startSession()` from `.onAppear` to begin the first question's timer.
- **Blitz** uses dedicated `BlitzViewModel` + `BlitzView` + `BlitzSummaryView`. The lifecycle (no feedback phase, auto-advance on tap, global 60s countdown) differs from the standard quiz. Do not try to adapt `QuizSessionViewModel` for Blitz.
  - Queue pre-generated with `BlitzEngine.generateQuestionQueue(from:)` (~45 questions).
  - Personal best stored in `ProgressData.blitzBestScore`; persist via `progressStore.updateBlitzBest(score:)`.
- **No speed bonus XP for Blitz.** Everything is speed — XP is simply `score * 10`.
- **Streak** uses dedicated `StreakViewModel` + `StreakView`. Large MCQ pool (~40 questions) from `MasteredTemplatePool.mcqTemplates(from:)`. Game continues until one wrong answer. Personal best stored in `ProgressData.streakModeBestScore`; persist via `progressStore.updateStreakBest(score:)`.
  - Session ID: `lessonId: "streak_mode"`, `moduleId: "mixed"`.
- **True/False (Snap)** uses dedicated `TrueFalseViewModel` + `TrueFalseView`. 20 items generated from quiz templates — half show the correct answer, half show a distractor. Items generated via `TrueFalseViewModel.generateItems(from:count:)`.
  - Session ID: `lessonId: "true_false"`, `moduleId: "mixed"`.
  - Personal best stored in `ProgressData.trueFalseBestScore`; persist via `progressStore.updateTrueFalseBest(score:)`.
- **Estimation** uses dedicated `EstimationViewModel` + `EstimationView` + `EstimationSlider`. 10 slider-based questions with 10-second countdown. Graded on proximity: ≤5% = 3 stars (perfect), ≤15% = 2 stars (good), ≤30% = 1 star (okay), >30% = 0 stars (miss). Templates filtered to `difficulty >= 2` first (falls back to all if not enough). Slider range computed by `SliderRange.compute()` with anti-center positioning (correct answer placed in 18–38% OR 62–82% of slider range, never near center).
  - Session ID: `lessonId: "estimation"`, `moduleId: "mixed"`.
  - Personal best stored in `ProgressData.estimationBestScore`; persist via `progressStore.updateEstimationBest(score:)`.
- **Comparison** uses dedicated `ComparisonViewModel` + `ComparisonView`. 15 side-by-side pairs with 8s countdown per question. Pairs generated via `ComparisonViewModel.generatePairs(from:count:)`. Player taps the side with the larger answer.
  - Session ID: `lessonId: "comparison"`, `moduleId: "mixed"`.
  - Personal best stored in `ProgressData.comparisonBestScore`; persist via `progressStore.updateComparisonBest(score:)`.

## Celebration / Personal Best

- **`previousBest` pattern.** All game mode ViewModels accept a `previousBest: Int` parameter at init. The launch function captures the current best from `ProgressStore` before creating the ViewModel. The VM exposes `var isNewBest: Bool` (computed: `score > previousBest && score > 0`).
- **`PracticeQuizContainer`** (used for Speed Drill and Recall in PracticeView) accepts an optional `previousBest: Int?` parameter. It detects `isNewBest` before calling the `recordSession` closure.
- **`ConfettiBurst`** is a reusable Canvas + TimelineView confetti particle system in `Core/DesignSystem/Primitives/ConfettiBurst.swift`. 60 particles, 3-second duration, fires on appear. Use as a ZStack overlay on summary views: `if viewModel.isNewBest { ConfettiBurst() }`.
- **`NewBestBadge`** is a reusable golden trophy capsule badge (also in `ConfettiBurst.swift`). Spring bounce-in animation on appear. All summary views show it when `isNewBest` is true.
- **Practice tab drill cards** show personal best inside the decorative orb (70pt circle, bottom-right) when `bestScore > 0`. The subtitle always remains visible.

## Mid-Session Motivators

- **MotivatorEngine is pure.** No side effects, no state. The ViewModel owns `motivatorsShownAt` and passes it into each evaluation call.
- **Hard constraint:** Motivators NEVER fire after the last question. Enforce with `guard remainingAfter > 0` before any evaluation.
- **Max 2 per session.** Do not raise this — research shows >2 crosses from motivating to annoying.
- **2-question cooldown.** At least 2 questions between any two full-screen motivators.
- **Priority order:** Coaching > Momentum > Progress > Near Finish. Struggling users need help more than succeeding users need celebration.
- **Coaching tips** reuse `Lesson.shortcut` and `Lesson.example` — no new content fields. Look up via `ContentRepository.lesson(forTemplateId:)`.
- **Estimation coaching** uses generic tips from `MotivatorCopy.estimationTips` since estimation questions don't map cleanly to lesson shortcuts.
- **Speed Drill:** Max 1 motivator, no coaching (too slow for speed context).
- **Auto-advance modes get nothing.** Blitz, Streak, True/False, Comparison have no natural pause point. Do not add motivators to these modes.
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

- **UserDefaults** via `ProgressStore` wrapping `ProgressData` (Codable).
- **SessionRecord** per completed quiz. Includes `questionResults` array and `bonusXP`.
- **No backend in V1.** Do not add network calls, auth, or remote storage.
- **AppStorage** for user preferences (name, reminder settings, appearance).

## Testing

- **SeededRandomGenerator** enables deterministic quiz generation in tests.
- **Build command:** `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project apps/ios/Numind.xcodeproj -scheme Numind -destination 'platform=iOS Simulator,id=A00ED55E-04B9-451C-8D49-57E6BB17EF78' CODE_SIGNING_ALLOWED=NO build`
- **Regenerate project file** with `xcodegen` after adding/removing Swift files.

## Do Not

- Do not add third-party packages in V1.
- Do not build backend before local product loop works.
- Do not integrate RevenueCat until core loop exists.
- Do not add AI-generated content.
- Do not force auth in V1.
- Do not use SwiftData (deferred until backend lands).
- Do not introduce new hex colors — derive from existing tokens.
- Do not skip the design token layer with raw values.
