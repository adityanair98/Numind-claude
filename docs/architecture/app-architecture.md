# App Architecture

> **Last updated:** May 2026 (after M60 — Game Modes expansion, Practice drills, Celebration effects).

## Pattern
MVVM with lightweight services. No third-party dependencies in V1.

## Project Structure

```
Numind/
  App/
    NumindApp.swift              # @main entry point, ProgressStore injection
    RootView.swift               # Root container

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
      Lesson.swift               # Lesson struct
      QuizTemplate.swift         # Quiz template struct
      ContentRepository.swift    # Protocol for content access
      LocalContentRepository.swift  # JSON-backed implementation
    Progress/
      NumindScoreEngine.swift    # Composite Numind Score calculation + ScoreTier
      ProgressData.swift         # Codable progress state with computed helpers + best scores
      ProgressStore.swift        # ObservableObject wrapping ProgressData (UserDefaults)
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
      QuizEngine.swift           # Template -> QuizQuestion generator (40+ formulas)
      QuizQuestion.swift         # Generated question model
      ReviewMistakesEngine.swift # Review-mistakes session builder
      SeededRandomGenerator.swift # Deterministic RNG for reproducible tests
      SpacedRepetitionEngine.swift # Spaced repetition scheduling
    LessonEngine/
      LessonRecommendationEngine.swift  # Lesson recommendation logic
    Badges/
      Badge.swift                # Badge model + BadgeCatalog (27 badges)
      BadgeEvaluator.swift       # Pure badge evaluation from ProgressData

  Features/
    Home/
      HomeView.swift             # Home tab: greeting, modes, workout, resume
      HomeViewModel.swift        # Home data preparation
      BrandHeader.swift          # Numind brand header component
      DailyChallengeCard.swift   # Daily challenge card component
      DailyInsightView.swift     # Daily insight/tip display
      ModeCard.swift             # Game mode card (gradient, orbs, 6 convenience constructors)
      StreakStripCard.swift       # Streak calendar strip card
    Learn/
      LearnView.swift            # Quest-journey learning path (main Learn tab)
      LearnViewModel.swift       # Path node generation, mastery gating, review insertion
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
      QuizSessionViewModel.swift # Quiz state: questions, answers, XP, timer
      SessionSummaryView.swift   # Post-quiz summary with mastery, badges, personal best
      OptionCard.swift           # MCQ option button (5 visual states)
      LevelUpView.swift          # Full-screen level-up celebration
      ConfettiView.swift         # Particle animation for correct-answer celebrations
    Blitz/
      BlitzView.swift            # Blitz mode: 60s sprint container
      BlitzViewModel.swift       # Blitz state: countdown, auto-advance, score
      BlitzSummaryView.swift     # Blitz summary with personal best + confetti
      SpeedDrillView.swift       # Speed drill presentation
    Practice/
      PracticeView.swift         # Practice tab: module strip, hero card, 7 drill cards
      Streak/
        StreakView.swift          # Streak mode: consecutive correct answers
        StreakViewModel.swift     # Streak state: count, game over detection
      TrueFalse/
        TrueFalseView.swift      # True/False snap: 20 rapid-fire statements
        TrueFalseViewModel.swift # T/F state: items, flashing, score
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
    LocalContent/
      modules.json               # 8 module definitions
      lessons.json               # 37 lessons with template IDs
      quiz_templates.json        # 187 quiz templates
    Assets.xcassets              # App icons, colors, images
```

## Key Architectural Decisions

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
- Review nodes are inserted programmatically (not stored in content JSON)
- Path state is recomputed on every `progressStore` change via `.onChange`

### Quiz Flow
- `QuizSessionViewModel` owns the full quiz lifecycle
- Each `QuizEngine.generate()` call uses a fresh random seed
- Retries create a new ViewModel instance -> completely new random values
- `CheckpointQuizEngine` round-robins across multiple lessons' templates

### Presentation
- Lessons and reviews use `.fullScreenCover` from the Learn tab
- Level-up uses a nested `.fullScreenCover` from within the lesson/review view
- Session summary is a phase within the lesson/review view, not a separate screen

### Game Modes
- Each game mode has its own dedicated ViewModel + View pair (except Speed Drill which reuses `QuizSessionViewModel` with a timer)
- All mode ViewModels accept `previousBest: Int` at init and expose `isNewBest: Bool`
- `MasteredTemplatePool` is the shared gateway — all modes pull from mastered templates only
- `PracticeQuizContainer` wraps standard quiz sessions (Speed Drill, Recall) with score tracking and celebration support
- Celebration system: `ConfettiBurst` (Canvas particles) + `NewBestBadge` overlay on summary views when `isNewBest`
- Estimation mode uses `SliderRange.compute()` for adaptive slider bounds with anti-center positioning
