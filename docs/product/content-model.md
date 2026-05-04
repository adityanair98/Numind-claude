# Content Model

> **Last updated:** May 2026 (after M56).

## Overview
All content is stored locally as JSON in `Resources/LocalContent/`. No backend required for V1.

| File | Purpose | Count |
|---|---|---|
| `modules.json` | Module definitions (id, title, icon, color) | 8 |
| `lessons.json` | Lesson content (concept, shortcut, example, template IDs) | 37 |
| `quiz_templates.json` | Quiz question templates | 187 |

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
| `tips` | Tips | `percent` | 5 |
| `discounts` | Discounts | `tag` | 5 |
| `money_math` | Money Math | `dollarsign.circle` | 5 |
| `salary` | Salary | `briefcase` | 4 |
| `investing` | Investing | `chart.line.uptrend.xyaxis` | 3 |
| `estimation` | Estimation | `eye` | 6 |
| `debt` | Debt | `creditcard` | 5 |
| `travel` | Travel | `airplane` | 5 |

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

Every lesson has exactly **5 quiz templates** assigned. The quiz engine cycles through them to generate 8 questions per session, ensuring variety while staying on-topic.

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
    let questionId: String    // template ID
    let isCorrect: Bool
    let timeSpentSeconds: Double
}
```

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

### Mastery
A lesson is "mastered" when any session for that lesson has `correctCount / totalCount >= 0.75` (75%). This applies identically to both lesson quizzes and checkpoint reviews. Mastery is the gate for unlocking the next node on the learning path.

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
