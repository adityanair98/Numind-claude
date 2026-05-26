# App Architecture

> **Last updated:** May 2026 (after V1 refinement and Phase 1 audit fixes — Lesson.lastVerified field, realisticMinPayment formula, IDR concept reframe, Parent PLUS rate update).

Numind is a **financial education iOS app** — the architecture supports a content layer (modules + lessons + templates) that delivers financial literacy via mental-math-based practice. The engine layer (`QuizEngine`, `FormulaOperationMap`, `DifficultyScorer`) generates parametric numerical questions; concept templates (text MCQ) skip formula evaluation.

## Pattern
MVVM with lightweight services. No third-party dependencies in V1.

## Project Structure

```
Numind/
  App/
    NumindApp.swift              # @main entry, AppDelegate/SceneDelegate, appearance bootstrap
    RootView.swift               # Root container (splash overlay + onboarding gate)
    SplashView.swift             # Branded splash overlay (seamless handoff from storyboard)

  Core/
    DesignSystem/
      Theme.swift                # Namespace for all design tokens
      ModuleColorTheme.swift     # Per-module color resolution
      DesignSystemPreviewView.swift  # Preview helper for design tokens
      Tokens/
        Colors.swift             # 8 brand colors + tints
        Radius.swift             # card, pill, iconTile radii
        Spacing.swift            # screenHorizontal, cardPadding, sectionSpacing
        Typography.swift         # display, title, headline, body, caption, small
      Primitives/
        BeadRail.swift           # Dot/bar progress indicator
        ConfettiBurst.swift      # Canvas+TimelineView confetti particle burst + NewBestBadge
        EstimationSlider.swift   # Custom slider with step snapping, callout, haptics
        HeroCard.swift           # Large hero card component (navy/accent variants)
        IconTile.swift           # Tinted icon circles (sm/md/lg)
        ModuleBarsView.swift     # Module progress bars visualization
        NumindCard.swift         # Base card component
        NumindScoreRing.swift    # Circular score ring for Numind Score display
        NumpadView.swift         # Custom numeric keypad for free entry
        PillButton.swift         # Primary/secondary/ghost CTA buttons
        QuestionTheme.swift      # Quiz question styling helpers
        QuizGraphicBanner.swift  # Decorative quiz header
        RadarChartView.swift     # Radar/spider chart for skill visualization
    Navigation/
      RootTabView.swift          # 4-tab navigation (Home, Learn, Progress, Profile)
    Notifications/
      NotificationManager.swift  # Local notification scheduling

  Domain/
    Models/
      Module.swift               # Module struct (with mascot, glyph fields)
      ModuleColor.swift          # Module color pair (tintColor + tintBackground)
      Lesson.swift               # Lesson struct (+ optional lastVerified: String? — content audit stamp)
      QuizTemplate.swift         # Quiz template struct (concept fields: conceptChoices, correctConceptChoice)
      ContentRepository.swift    # Protocol for content access
      LocalContentRepository.swift  # JSON-backed implementation
    Progress/
      NumindScoreEngine.swift    # Composite Numind Score (accuracy 60, difficulty 25, speed 15)
      ProgressData.swift         # Codable progress state with computed helpers + best scores + streak freezes
      ProgressStore.swift        # ObservableObject wrapping ProgressData (UserDefaults) + autoApplyFreeze()
      SessionRecord.swift        # Per-session result record
    QuizEngine/
      AdaptiveDifficultyEngine.swift  # Adaptive difficulty selection
      BlitzEngine.swift          # Blitz mode question queue generator
      CheckpointQuizEngine.swift # Multi-lesson review quiz builder
      DailyChallengeEngine.swift # Daily challenge question selection
      DifficultyScorer.swift     # Question difficulty scoring
      FormulaOperationMap.swift  # Formula-to-operation mapping
      MasteredTemplatePool.swift # Shared gateway for game mode template access
      QuestionDifficulty.swift   # Difficulty level definitions
      QuizEngine.swift           # Template -> QuizQuestion generator (300+ formulas, proportional distractors, concept-template branch)
      QuizQuestion.swift         # Generated question model
      ReviewMistakesEngine.swift # Review-mistakes session builder
      SeededRandomGenerator.swift # Deterministic RNG for reproducible tests
      SpacedRepetitionEngine.swift # Spaced repetition scheduling
    LessonEngine/
      LessonRecommendationEngine.swift  # Lesson recommendation logic
    Badges/
      Badge.swift                # Badge model + BadgeCatalog (27 badges)
      BadgeEvaluator.swift       # Pure badge evaluation from ProgressData
    Motivator/
      MotivatorCheckpoint.swift  # Motivator data model + InlineEncouragement
      MotivatorCopy.swift        # Copy bank with randomized rotation (4-5 variants per type)
      MotivatorEngine.swift      # Pure evaluation logic: session state → optional motivator type

  Features/
    Home/
      HomeView.swift             # Home tab: greeting, modes, workout, resume, freeze count
      HomeViewModel.swift        # Home data preparation
      BrandHeader.swift          # Numind brand header component
      DailyChallengeCard.swift   # Daily challenge card component
      DailyInsightView.swift     # Daily insight/tip display
      ModeCard.swift             # Game mode card (gradient, orbs, 5 convenience constructors)
      StreakStripCard.swift       # Streak calendar strip card
    Learn/
      LearnView.swift            # Quest-journey learning path (main Learn tab)
      LearnViewModel.swift       # Path node generation, completion-based progression, review insertion
      LearnHeader.swift          # Learn tab header
      Lesson/
        LessonView.swift         # Lesson flow: content -> quiz -> summary
        LessonViewModel.swift    # Lesson state and presentation
      Checkpoint/
        CheckpointView.swift     # Module review quiz (no lesson content phase)
      ModuleDetail/
        ModuleDetailView.swift   # Module detail (legacy)
        ModuleDetailViewModel.swift
    Quiz/
      QuizSessionView.swift      # Quiz question presentation and progression
      QuizSessionViewModel.swift # Quiz state: questions, answers, XP, timer, motivators
      SessionSummaryView.swift   # Post-quiz summary with mastery, badges, personal best
      OptionCard.swift           # MCQ option button (5 visual states)
      LevelUpView.swift          # Full-screen level-up celebration
      ConfettiView.swift         # Particle animation for correct-answer celebrations
      MotivatorView.swift        # Full-screen mid-session checkpoint (momentum/coaching/progress/near-finish)
      InlineEncouragementView.swift  # Non-blocking overlay on feedback screen
    Blitz/
      BlitzView.swift            # Blitz mode: 60s sprint container
      BlitzViewModel.swift       # Blitz state: countdown, auto-advance, score
      BlitzSummaryView.swift     # Blitz summary with personal best + confetti
      SpeedDrillView.swift       # Speed drill presentation
    Practice/
      PracticeView.swift         # Practice tab: module strip, hero card, 6 drill cards
      Streak/
        StreakView.swift          # Streak mode: consecutive correct answers
        StreakViewModel.swift     # Streak state: count, game over detection
      Estimation/
        EstimationView.swift     # Estimation mode: slider + timer
        EstimationViewModel.swift # Estimation state: slider, grades, timer + SliderRange
      Comparison/
        ComparisonView.swift     # Comparison mode: side-by-side pairs
        ComparisonViewModel.swift # Comparison state: pairs, timer, score
    Progress/
      ProgressTabView.swift      # Progress tab: stats, weekly goal, XP chart, badges
      SkillDetailView.swift      # Per-module skill detail
    Profile/
      ProfileView.swift          # Profile tab: goals, reset, settings
    Onboarding/
      OnboardingView.swift       # Future onboarding flow (placeholder)

  Resources/
    Base.lproj/
      LaunchScreen.storyboard    # Native launch screen (logo + wordmark, Auto Layout)
    LocalContent/
      modules.json               # 10 module definitions
      lessons.json               # 96 lessons with template IDs (77 numerical + 19 concept)
      quiz_templates.json        # 479 quiz templates (384 numerical + 95 concept)
    Assets.xcassets              # App icons, colors, images
      LaunchLogo.imageset        # Background-removed symbol (light + dark variants)
      LaunchWordmark.imageset    # Cropped "Numind" wordmark (white text, both modes)
      LaunchBackground.colorset  # Brand blue (light) / dark navy (dark)
```

## Key Architectural Decisions

### Launch & Splash Screen

The app uses a two-phase launch screen strategy:

1. **LaunchScreen.storyboard** — a UIKit storyboard that iOS displays instantly on cold start (before any SwiftUI code runs). Contains `LaunchLogo` (centered via Auto Layout centerX/centerY) and `LaunchWordmark` (centered horizontally, 36pt above safe area bottom) on `LaunchBackground`.

2. **SplashView** — a SwiftUI overlay in `RootView` that takes over seamlessly from the storyboard with an identical layout (ZStack with logo at exact center, wordmark at bottom). After 1.2s it fades out with a slight scale-up to reveal the app.

Both phases use the same asset catalog images and named color, so the transition is invisible to the user.

### Appearance Override (Dark Mode)

iOS caches a snapshot of the launch screen using the window's trait collection when the app backgrounds. To ensure the correct light/dark launch screen appears on next cold start, the app uses UIKit lifecycle hooks:

- **`AppDelegate`** registers a `SceneDelegate` via `UISceneConfiguration`.
- **`SceneDelegate.scene(_:willConnectTo:options:)`** sets `overrideUserInterfaceStyle` on every `UIWindow` BEFORE the launch screen is dismissed.
- **`SceneDelegate.sceneDidBecomeActive(_:)`** reapplies on every foreground (in case the user changed the appearance setting while backgrounded).
- **`RootView.onChange(of: appearanceRaw)`** handles live appearance changes within the app session.

This mirrors how apps like WhatsApp and Facebook handle appearance-aware launch screens. The key insight is that `UIWindow.overrideUserInterfaceStyle` must be set early in the UIKit lifecycle — SwiftUI's `.preferredColorScheme` alone is too late because iOS has already cached the launch screen snapshot.

### State Management
- `ProgressStore` is an `ObservableObject` injected as `@EnvironmentObject` at the app root
- All session data persisted to `UserDefaults` via `Codable` `ProgressData`
- Feature ViewModels are `@StateObject` or `@ObservedObject`, never singletons

### Content Pipeline
- `ContentRepository` protocol abstracts content access
- `LocalContentRepository` loads from bundled JSON (replaceable with remote source later)
- Quiz templates reference answer formulas by string name, resolved at runtime in `QuizEngine`

### Learning Path
- `LearnViewModel.refresh(using:)` builds the full path from modules + lessons + progress
- Completion-based progression: `hasCompletedLesson` (any attempt) unlocks next node; `hasMasteredLesson` (≥75%) shown as gold star
- Review nodes are inserted programmatically (not stored in content JSON)
- Path state is recomputed on every `progressStore` change via `.onChange`

### Quiz Flow
- `QuizSessionViewModel` owns the full quiz lifecycle
- Dynamic question count: 5 on first attempt (gentle intro), 8 on subsequent, diagnostic-adjusted
- Each `QuizEngine.generate()` call uses a fresh random seed
- Retries create a new ViewModel instance -> completely new random values
- `CheckpointQuizEngine` round-robins across multiple lessons' templates
- `AdaptiveDifficultyEngine` uses onboarding diagnostic signals to set starting difficulty per module
- Distractor generation uses proportional `niceStep` algorithm (~5-8% of answer, rounded to natural numbers)

### Mid-Session Motivators
- `MotivatorEngine` is a pure, stateless evaluator — takes session state, returns optional `MotivatorType`
- `SessionState` includes a `.motivator(MotivatorCheckpoint)` case between `.feedback` and `.question`
- Hard constraint: motivators NEVER appear after the last question (`guard remainingAfter > 0`)
- Maximum 2 full-screen motivators per session, minimum 2-question cooldown between them
- Four types: momentum (3+ correct streak), coaching (2+ wrong in last 3), progress (halfway), near finish (2 remaining + 60%+ accuracy)
- Priority: coaching > momentum > progress > near finish (struggling users get help first)
- Inline encouragement is a separate non-blocking overlay on the feedback screen (fast answer, used hint, streak)
- Coaching tips reuse the existing `Lesson.shortcut` field via `ContentRepository.lesson(forTemplateId:)`
- Only available in modes with manual "Continue" pause: lesson quiz, daily challenge, checkpoint, speed drill, estimation
- Auto-advance modes (blitz, streak, true/false, comparison) have no motivators

### Presentation
- Lessons and reviews use `.fullScreenCover` from the Learn tab
- Level-up uses a nested `.fullScreenCover` from within the lesson/review view
- Session summary is a phase within the lesson/review view, not a separate screen

### Game Modes
- 6 game modes (Speed Drill, Blitz, Recall, Streak, Estimation, Comparison). True/False was removed during V1 refinement.
- Each game mode has its own dedicated ViewModel + View pair (except Speed Drill which reuses `QuizSessionViewModel` with a timer)
- All mode ViewModels accept `previousBest: Int` at init and expose `isNewBest: Bool`
- `MasteredTemplatePool` is the shared gateway — all modes pull from mastered templates only
- `PracticeQuizContainer` wraps standard quiz sessions (Speed Drill, Recall) with score tracking and celebration support
- Celebration system: `ConfettiBurst` (Canvas particles) + `NewBestBadge` overlay on summary views when `isNewBest`
- Estimation mode uses `SliderRange.compute()` for adaptive slider bounds with anti-center positioning
