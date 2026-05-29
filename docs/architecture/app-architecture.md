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
      Celebration.swift          # Pack/world completion celebrations queued post-session
      NumindScoreEngine.swift    # 7-axis Numind Score (per-question multipliers, weighting profiles, evidence levels, coverage-cap composite)
      ProgressData.swift         # Codable progress state with computed helpers + best scores + streak freezes + dailyWorkoutDates + focusPackId
      ProgressStore.swift        # ObservableObject wrapping ProgressData (UserDefaults v2) + autoApplyFreeze() + pendingCelebrations queue
      SessionRecord.swift        # Per-session result record
    Skills/
      SkillAxis.swift            # 7 SkillAxis cases + WeightingProfile + QuestionMultiplier + EvidenceLevel
    QuizEngine/
      AdaptiveDifficultyEngine.swift  # Adaptive difficulty selection
      CheckpointQuizEngine.swift # Multi-lesson review quiz builder
      DailyChallengeEngine.swift # Daily challenge question selection
      DifficultyScorer.swift     # Question difficulty scoring
      FormulaOperationMap.swift  # Formula-to-operation mapping
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
      StreakStripCard.swift       # Streak calendar strip card
    Learn/
      LearnView.swift            # Worlds carousel (TabView .page) + opened-world quest map + Paths sub-tab
      LearnViewModel.swift       # Path node generation, completion-based progression, review insertion
      LearnHeader.swift          # Learn tab header
      WorldHeroPage.swift        # Single hero page in the Worlds carousel (themed illustration, Continue card)
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
    Tools/
      ToolsView.swift            # Tools tab: grouped calculator list + first-launch welcome sheet
      CalculatorShell.swift      # Shared calculator scaffold + disclaimers + CalculatorRegistry
      Calculators/               # 12 calculators (tip+split, discount+tax, paycheck, CC payoff,
                                 #   rent, HYSA, salary, loan, 401k impact, mortgage, lease-vs-buy, student loan)
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
      lessons.json               # 118 lessons with template IDs (post-Phase-4 audit; lastVerified stamped on every entry)
      quiz_templates.json        # 590 quiz templates (433 numerical + 157 concept)
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
- Only available in modes with a manual "Continue" pause: lesson quiz, Daily Workout, checkpoint review, Recall

### Presentation
- Lessons and reviews use `.fullScreenCover` from the Learn tab
- Level-up uses a nested `.fullScreenCover` from within the lesson/review view
- Session summary is a phase within the lesson/review view, not a separate screen

### Tools tab + Recall (Practice + game modes retired in Phase 7a)
- The Practice tab and the timed game modes (Speed Drill, Blitz, Streak, Estimation, Comparison) were retired in Phase 7a. Their views/view-models and the `BlitzEngine`, `MasteredTemplatePool`, `ModeCard`, and `EstimationSlider` helpers were deleted; per-mode personal-best fields stay in `ProgressData` for snapshot back-compat.
- The Tools tab replaced Practice in `RootTabView`: 12 calculators on `CalculatorShell`, dispatched via `CalculatorRegistry`, deep-linked from lessons through `Lesson.relatedCalculatorSlug`.
- Recall ("review your weak spots") survives on Home — built from missed questions via `ReviewMistakesEngine`, with a bonus-round fallback. Celebration system: `ConfettiBurst` (Canvas particles) + `NewBestBadge` overlay when a new Recall best is set.
