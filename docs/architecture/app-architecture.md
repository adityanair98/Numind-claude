# App Architecture

> **Last updated:** May 2026 (after M56).

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
      Tokens/
        Colors.swift             # 8 brand colors + tints
        Radius.swift             # card, pill, iconTile radii
        Spacing.swift            # screenHorizontal, cardPadding, sectionSpacing
        Typography.swift         # display, title, headline, body, caption, small
      Primitives/
        BeadRail.swift           # Dot/bar progress indicator
        IconTile.swift           # Tinted icon circles (sm/md/lg)
        NumindCard.swift         # Base card component
        NumpadView.swift         # Custom numeric keypad for free entry
        PillButton.swift         # Primary/secondary/ghost CTA buttons
        QuestionTheme.swift      # Quiz question styling helpers
        QuizGraphicBanner.swift  # Decorative quiz header
    Navigation/
      RootTabView.swift          # 4-tab navigation (Home, Learn, Progress, Profile)
    Notifications/
      NotificationManager.swift  # Local notification scheduling

  Domain/
    Models/
      Module.swift               # Module struct
      ModuleColor.swift          # Module color pair (tintColor + tintBackground)
      Lesson.swift               # Lesson struct
      QuizTemplate.swift         # Quiz template struct
      ContentRepository.swift    # Protocol for content access
      LocalContentRepository.swift  # JSON-backed implementation
    Progress/
      ProgressData.swift         # Codable progress state with computed helpers
      ProgressStore.swift        # ObservableObject wrapping ProgressData (UserDefaults)
      SessionRecord.swift        # Per-session result record
    QuizEngine/
      QuizEngine.swift           # Template -> QuizQuestion generator (40+ formulas)
      QuizQuestion.swift         # Generated question model
      CheckpointQuizEngine.swift # Multi-lesson review quiz builder
      SeededRandomGenerator.swift # Deterministic RNG for reproducible tests
      DailyChallengeEngine.swift # Daily challenge question selection
      ReviewMistakesEngine.swift # Review-mistakes session builder
      SpacedRepetitionEngine.swift # Spaced repetition scheduling
    Badges/
      Badge.swift                # Badge model + BadgeCatalog (27 badges)
      BadgeEvaluator.swift       # Pure badge evaluation from ProgressData

  Features/
    Home/
      HomeView.swift             # Home tab: greeting, workout card, resume card
      HomeViewModel.swift        # Home data preparation
    Learn/
      LearnView.swift            # Zigzag learning path (main Learn tab)
      LearnViewModel.swift       # Path node generation, mastery gating, review insertion
      Lesson/
        LessonView.swift         # Lesson flow: content -> quiz -> summary
        LessonViewModel.swift    # Lesson state and presentation
      Checkpoint/
        CheckpointView.swift     # Module review quiz (no lesson content phase)
      ModuleDetail/
        ModuleDetailView.swift   # Module detail (legacy, may be removed)
        ModuleDetailViewModel.swift
    Quiz/
      QuizSessionView.swift      # Quiz question presentation and progression
      QuizSessionViewModel.swift # Quiz state: questions, answers, XP, timer
      SessionSummaryView.swift   # Post-quiz summary with mastery, badges, personal best
      OptionCard.swift           # MCQ option button (5 visual states)
      LevelUpView.swift          # Full-screen level-up celebration
      ConfettiView.swift         # Particle animation for celebrations
    Progress/
      ProgressTabView.swift      # Progress tab: stats, weekly goal, XP chart, badges
      SkillDetailView.swift      # Per-module skill detail
    Profile/
      ProfileView.swift          # Profile tab: goals, reset, settings
    Onboarding/
      OnboardingView.swift       # Future onboarding flow (placeholder)
    Practice/
      PracticeView.swift         # Future practice mode (placeholder)

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
