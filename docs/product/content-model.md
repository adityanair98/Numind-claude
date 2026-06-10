# Content Model

> **Last updated:** May 2026 (after Phase 1 audit fixes — added `lastVerified` field to Lesson, IDR reframed to concept, `realisticMinPayment` formula added, Parent PLUS rate updated).

## Overview
All content is stored locally as JSON in `Resources/LocalContent/`. No backend required for V1.

The content layer is Numind's product: it encodes the **financial education** the app delivers (mental math is the teaching method). Numerical lessons exercise mental-math shortcuts; concept lessons cover financial literacy that isn't reducible to arithmetic.

| File | Purpose | Count (Phase 10, June 2026) |
|---|---|---|
| `modules.json` | Module definitions (id, title, icon, color) | 11 |
| `lessons.json` | Lesson content (concept, shortcut, example, template IDs) | 127 |
| `quiz_templates.json` | Quiz question templates (445 numerical + 304 concept; 124 `isApplication` decision items) | 749 |
| `packs.json` | Life-Event Packs (curated lesson sequences with 3–6-lesson cores) | 12 |

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
| `smart_shopping` | Smart Shopping | `cart.fill` | 9 |
| `money_math` | Budgets & Spending | `dollarsign.circle` | 7 |
| `salary` | Salary & Income | `briefcase` | 9 |
| `investing` | Investing Basics | `chart.line.uptrend.xyaxis` | 13 |
| `debt` | Debt & Loans | `creditcard` | 10 |
| `housing` | Housing & Rent | `house.fill` | 9 |
| `taxes` | Taxes & Paycheck | `doc.text.fill` | 9 |
| `insurance` | Insurance & Healthcare | `cross.case.fill` | 10 |
| `car` | Car & Big Purchases | `car.fill` | 10 |
| `student_loans` | Student Loans & Education | `graduationcap.fill` | 10 |

## Lesson
A short financial-education unit: one concept, one mental-math shortcut, one worked example, plus 5 quiz templates.

```swift
struct Lesson: Identifiable, Codable {
    let id: String
    let moduleId: String
    let title: String
    let concept: String           // one-paragraph financial concept + nuance
    let shortcut: String          // the mental math (or for concept lessons, the rule-of-thumb)
    let example: String           // worked example with numbers
    let quizTemplateIds: [String] // exactly 5 template IDs
    let lastVerified: String?     // ISO date (yyyy-mm-dd) — when content was last fact-checked
}
```

Every lesson has exactly **5 quiz templates** assigned. The quiz engine cycles through them to generate 5 questions (first attempt) or 8 questions (subsequent attempts) per session, ensuring variety while staying on-topic.

### `lastVerified` (optional)
ISO date string marking the last time the lesson's content (rates, thresholds, regulations, cited statistics) was fact-checked against primary sources. Optional — older lessons may not have it. The Phase 1 audit-fix pass stamped six lessons that touched regulated content (Parent PLUS, IDR, standard deduction, OOP max, minimum payment, overtime). Future audit cadence: stamp every lesson on annual or post-policy-change review; surface stale entries via tooling.

### Numerical vs concept lesson type (implicit)
A lesson is "numerical" if **any** of its 5 templates uses `answerFormula` (formula-driven math drill). It's "concept-only" if **all 5** of its templates use `conceptChoices`/`correctConceptChoice` (text MCQ). The distinction isn't a Swift field on `Lesson` — it's a property of the assigned templates. Current split: 77 numerical / 19 concept (post-Phase-1).

## QuizTemplate
Defines a question. Numerical templates use `answerFormula` for parametric generation. Concept templates use `conceptChoices`/`correctConceptChoice` for static text-MCQ.

```swift
struct QuizTemplate: Identifiable, Codable {
    let id: String
    let moduleId: String
    let difficulty: Int                   // 1, 2, or 3
    let inputMode: String?                // "freeEntry" or nil (= multiple choice)
    let scenarioTemplate: String?         // optional context sentence
    let promptTemplate: String            // question with {{variable}} placeholders (numerical only)
    let variableRules: [VariableRule]
    let answerFormula: String?            // formula key (numerical); nil for concept templates
    let answerFormat: String              // "currency", "percent", or "integer"
    let distractorStrategy: String        // "roundedNeighbor", "offByDecimal", "commonMistake"
    let explanationTemplate: String       // feedback with {{variable}} placeholders
    // Concept template fields (text-MCQ, no formula evaluation)
    let conceptChoices: [String]?         // 4 static text options
    let correctConceptChoice: String?     // must match one entry in conceptChoices
}
```

A template is either numerical (has `answerFormula`) or concept (has `conceptChoices` + `correctConceptChoice`). The QuizEngine branches on which fields are present. See `docs/product/quiz-engine.md` for the full formula reference and generation logic.

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
- ID format: `review_{moduleId}_{groupIndex}` (e.g., `review_smart_shopping_0`)
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
