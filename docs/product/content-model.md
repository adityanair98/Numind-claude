# Content Model

> **Last updated:** May 2026 (after V1 refinement — new modules, template audit, distractor fix).

## Overview
All content is stored locally as JSON in `Resources/LocalContent/`. No backend required for V1.

| File | Purpose | Count |
|---|---|---|
| `modules.json` | Module definitions (id, title, icon, color) | 10 |
| `lessons.json` | Lesson content (concept, shortcut, example, template IDs) | 78 |
| `quiz_templates.json` | Quiz question templates | 389 |

## Module
A group of lessons covering a topic area.

```swift
struct Module: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String        // SF Symbol name
    let color: ModuleColor  // tintColor + tintBackground
}
```

### V1 Modules
| ID | Title | Icon | Lessons |
|---|---|---|---|
| `smart_shopping` | Smart Shopping | `cart.fill` | 8 |
| `money_math` | Budgets & Spending | `dollarsign.circle` | 6 |
| `salary` | Salary & Income | `briefcase` | 8 |
| `investing` | Investing Basics | `chart.line.uptrend.xyaxis` | 10 |
| `debt` | Debt & Loans | `creditcard` | 8 |
| `housing` | Housing & Rent | `house.fill` | 7 |
| `taxes` | Taxes & Paycheck | `doc.text.fill` | 7 |
| `insurance` | Insurance & Healthcare | `cross.case.fill` | 8 |
| `car` | Car & Big Purchases | `car.fill` | 8 |
| `student_loans` | Student Loans & Education | `graduationcap.fill` | 8 |

## Lesson
A short learning unit with one concept, one shortcut, and one worked example.

```swift
struct Lesson: Identifiable, Codable {
    let id: String
    let moduleId: String
    let title: String
    let concept: String          // one-paragraph explanation
    let shortcut: String         // the mental math trick
    let example: String          // worked example with numbers
    let quizTemplateIds: [String] // exactly 5 template IDs
}
```

Every lesson has exactly **5 quiz templates** assigned. The quiz engine cycles through them to generate 5 questions (first attempt) or 8 questions (subsequent attempts) per session, ensuring variety while staying on-topic.

## QuizTemplate
Defines a parametric question that produces different numbers each time.

```swift
struct QuizTemplate: Identifiable, Codable {
    let id: String
    let moduleId: String
    let difficulty: Int              // 1, 2, or 3
    let inputMode: String?           // "freeEntry" or nil (= multiple choice)
    let scenarioTemplate: String?    // optional context sentence
    let promptTemplate: String       // question with {{variable}} placeholders
    let variableRules: [VariableRule]
    let answerFormula: String        // maps to QuizEngine formula
    let answerFormat: String         // "currency", "percent", or "integer"
    let distractorStrategy: String   // "roundedNeighbor", "offByDecimal", "commonMistake"
    let explanationTemplate: String  // feedback with {{variable}} placeholders
}
```

See `docs/product/quiz-engine.md` for the full formula reference and generation logic.

## SessionRecord
Records the result of one completed quiz session.

```swift
struct SessionRecord: Identifiable, Codable {
    let id: UUID
    let lessonId: String     // lesson ID or "review_{moduleId}_{groupIndex}"
    let moduleId: String
    let date: Date
    let correctCount: Int
    let totalCount: Int
    var questionResults: [QuestionResult]
    var bonusXP: Int

    // Computed
    var isReviewSession: Bool  // true if lessonId starts with "review_"
    var totalXP: Int           // (correctCount * 10) + bonusXP
}
```

### QuestionResult
Per-question detail within a session.

```swift
struct QuestionResult: Codable {
    let templateId: String    // quiz template ID
    let isCorrect: Bool
    let timeSpentSeconds: Double
}
```

### Game Mode Session IDs
| Mode | lessonId | moduleId |
|---|---|---|
| Lesson quiz | `{lessonId}` | `{moduleId}` |
| Checkpoint review | `review_{moduleId}_{groupIndex}` | `{moduleId}` |
| Daily Challenge | `daily_challenge` | `mixed` |
| Speed Drill | `speed_drill` | `mixed` |
| Blitz | `blitz_session` | `mixed` |
| Streak | `streak_mode` | `mixed` |
| Estimation | `estimation` | `mixed` |
| Comparison | `comparison` | `mixed` |

## ProgressData
The user's entire local progress state, persisted via UserDefaults.

```swift
struct ProgressData: Codable {
    var sessions: [SessionRecord]

    // Computed helpers
    func computeStreak() -> Int
    func computeAccuracy() -> Double
    func computeTotalXP() -> Int
    func bestResult(for lessonId: String) -> SessionRecord?
    func hasMasteredLesson(_ lessonId: String) -> Bool  // >= 75% on any attempt
    func hasCompletedLesson(_ lessonId: String) -> Bool  // any attempt
    var completedLessonCount: Int  // excludes review sessions
    func weeklyXPHistory() -> [WeeklyXP]  // last 4 weeks
}
```

### Game Mode Best Scores
`ProgressData` also tracks personal bests for each game mode:

    var blitzBestScore: Int = 0
    var streakModeBestScore: Int = 0
    var speedDrillBestScore: Int = 0
    var recallBestScore: Int = 0
    var estimationBestScore: Int = 0
    var comparisonBestScore: Int = 0

Each has a corresponding mutator (`updateBlitzBest(score:)`, etc.) that only updates if the new score exceeds the current best. `ProgressStore` exposes matching accessor properties and persist methods.

### Streak Freezes
`ProgressData` tracks streak freeze state:

    var availableFreezes: Int = 0           // max 3 banked
    var freezeMilestonesAwarded: Int = 0    // tracks 7-day milestones

Users earn one freeze per 7-day streak milestone (max 3 banked). Freezes are auto-applied on missed days before showing a streak loss screen. `freezeMilestonesAwarded` resets when the streak resets to 0.

### Mastery & Progression
A lesson is "mastered" when any session for that lesson has `correctCount / totalCount >= 0.75` (75%). Mastery earns a gold star on the learning path. However, **progression only requires completion** — any attempt at a lesson (regardless of score) unlocks the next node. This prevents anxious users from being blocked while still rewarding high performance.

## Learning Path Model

### PathNode
Each node on the zigzag learning path:

```swift
struct PathNode: Identifiable {
    enum NodeKind {
        case lesson(Lesson)
        case review(lessonIds: [String])
    }
    enum NodeState {
        case mastered    // passed at >= 75%
        case attempted   // tried but < 75%
        case current     // first unlocked-unattempted (pulsing ring)
        case available   // unlocked but not next recommended
        case locked      // previous node not mastered
    }

    let id: String
    let kind: NodeKind
    let module: Module
    let state: NodeState
    let isLeft: Bool            // alternates for zigzag layout
    var hasTrailingLine: Bool   // connector to next node
    let lessonIndexInModule: Int
}
```

### Review Nodes
- Inserted after every 3 lessons within a module
- ID format: `review_{moduleId}_{groupIndex}` (e.g., `review_tips_0`)
- Unlock only when all 3 covered lessons are mastered
- Gate subsequent lessons until the review itself is mastered

## Badge System

### BadgeCatalog
Defines all 27 earnable badges with metadata (id, title, description, icon, tier, category).

### BadgeEvaluator
Pure function that computes earned badge IDs from a `ProgressData` snapshot. Evaluates criteria like session count, streak length, accuracy, XP total, unique lessons/modules completed. Review sessions are excluded from lesson/module uniqueness counts.

## Skill Levels
Module-level skill tiers based on completed sessions within each module. Level-up triggers a full-screen `LevelUpView` celebration.

## ContentRepository Protocol
```swift
protocol ContentRepository {
    func allModules() -> [Module]
    func lessons(for moduleId: String) -> [Lesson]
    func lesson(id: String) -> Lesson?
    func templates(for lessonId: String) -> [QuizTemplate]
}
```

`LocalContentRepository` implements this by loading from the bundled JSON files.
