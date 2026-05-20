# Quiz Engine

> **Last updated:** May 2026 (after V1 refinement — proportional distractors, adaptive difficulty, diagnostic calibration, new modules).

## Principle
Questions are generated from templates, not hardcoded. Each quiz session produces different numbers, different answer choices, and different question order - even when replaying the same lesson.

## Session Parameters
- **Questions per session:** 5 on first attempt at any lesson (gentle intro), 8 on subsequent attempts. Diagnostic calibration may adjust: strong users get 5 questions, weaker users get up to 8 on first attempt.
- **Mastery threshold:** 75% for gold star display (aspirational). Progression requires only completion (any attempt unlocks the next lesson).
- **Question types:** Multiple choice (4 options) and free entry (numeric keypad)
- **Timer:** Per-question timer; fast answers earn speed bonus XP

## Template Format
Each template is a JSON object in `Resources/LocalContent/quiz_templates.json`:

```json
{
  "id": "tip_percent_basic",
  "moduleId": "tips",
  "difficulty": 1,
  "inputMode": "freeEntry",
  "scenarioTemplate": "You're at a restaurant. Your bill comes to ${{billAmount}}.",
  "promptTemplate": "What is {{tipPercent}}% of ${{billAmount}}?",
  "variableRules": [
    { "name": "tipPercent", "options": [15, 18, 20] },
    { "name": "billAmount", "options": [20, 30, 40, 50, 60] }
  ],
  "answerFormula": "tipAmount",
  "answerFormat": "currency",
  "distractorStrategy": "roundedNeighbor",
  "explanationTemplate": "Find 10% first -- move the decimal left. Then build up: 10% + 5% + 3% = 18%, or 10% + 10% = 20%."
}
```

### Template Fields
| Field | Required | Description |
|---|---|---|
| `id` | yes | Unique template identifier |
| `moduleId` | yes | Parent module (tips, discounts, money_math, salary, investing, estimation, debt, travel, housing, taxes) |
| `difficulty` | yes | 1 (easy), 2 (medium), 3 (hard) |
| `inputMode` | no | `"freeEntry"` for numeric keypad; omit for multiple choice (default) |
| `scenarioTemplate` | no | Optional context sentence shown above the question |
| `promptTemplate` | yes | The question text with `{{variable}}` placeholders |
| `variableRules` | yes | Array of `{ name, options }` defining the random value pool per variable |
| `answerFormula` | yes | Name of the formula function in `QuizEngine.swift` |
| `answerFormat` | yes | `"currency"`, `"percent"`, or `"integer"` |
| `distractorStrategy` | yes | How wrong answers are generated (MCQ only) |
| `explanationTemplate` | yes | Feedback text with `{{variable}}` placeholders |

## Question Generation Flow (`QuizEngine.generate`)
1. Pick a random seed (`UInt64.random`)
2. For each variable in `variableRules`, randomly select one value from `options`
3. Render `promptTemplate` and `scenarioTemplate` by substituting variables
4. Compute the correct answer using `answerFormula`
5. Format the answer using `answerFormat`
6. Generate 3 distractors using `distractorStrategy`
7. Shuffle answer choices (MCQ) or set up free entry validation
8. Render `explanationTemplate` with the same variables

Because each call uses a fresh random seed, calling `generate` twice on the same template produces different variable values, different correct answers, and different distractors. This is what makes retries feel genuinely fresh.

## Lesson Quiz Generation (`QuizSessionViewModel`)
For a single lesson quiz:
1. Get the lesson's `quizTemplateIds` (5 templates per lesson)
2. Determine question count: 5 for first attempt (gentle intro), 8 for subsequent attempts. Diagnostic calibration adjusts: intermediate users get 5, foundation users get 6, beginner users get 8 on first attempt.
3. Cycle through templates: `template[idx % count]` until target question count is reached
4. Shuffle the question order
5. Each `generate` call uses a fresh random seed

## Checkpoint Review Generation (`CheckpointQuizEngine`)
For module review quizzes (every 3 lessons):
1. Gather templates for each covered lesson
2. Round-robin across lesson buckets to ensure even coverage
3. Generate 8 questions total
4. Shuffle the question order

This ensures every covered lesson is represented roughly equally in the review.

## Answer Formulas (60+)
All formulas live in `QuizEngine.swift` as `[String: ([String: Double]) -> Double?]`:

### Tips
- `tipAmount` = bill x tipPercent / 100
- `billWithTip` = bill x (1 + tipPercent / 100)
- `tipPerPerson` = (bill x tipPercent / 100) / numPeople
- `tipOnTotal` = (bill x (1 + taxPercent / 100)) x tipPercent / 100
- `billWithTipPerPerson` = bill x (1 + tipPercent / 100) / numPeople

### Discounts
- `discountAmount` = price x discountPercent / 100
- `salePrice` = price x (1 - discountPercent / 100)
- `bogoPerItemPrice` = (2 x price) / 3
- `bogoSavings` = price (one free item)
- `stackedFinalPrice` = price x (1 - first/100) x (1 - second/100)
- `stackedTotalSaving` = price - stackedFinalPrice
- `unitPrice` = totalPrice / quantity

### Budgets & Spending (formerly Money Math)
- `taxAmount`, `priceWithTax`
- `totalCost` = price x quantity
- `budgetRemaining`, `budgetAfterPurchase`
- `monthlyToYearly`, `yearlyToMonthly`
- `costPerUse` = price / uses
- `estimateSumNearestTen` (rounds each to nearest 10, sums)

### Salary
- `grossToNet`, `annualToMonthly`, `monthlyToAnnual`
- `raiseAmount`, `raisedSalary`
- `overtimePay` = rate x 1.5 x hours
- `biweeklyToAnnual` (x26), `weeklyToAnnual` (x52)
- `hourlyFromAnnual` (/2080), `annualFromHourly` (x2080)

### Investing
- `simpleInterest` = principal x rate x years
- `totalWithInterest`
- `rule72` = 72 / rate
- `roiPercent` = (gain / cost) x 100
- `dollarReturn`, `monthlyInvestmentReturn`

### Estimation
- `doubleOf`, `halfOf`, `tripleOf`, `quarterOf`
- `multiplyBy5`, `splitFive`, `twentyPercentOf`
- `percentRaise`, `percentDrop`

### Debt
- `creditCardMonthlyInterest` = balance x APR / 12
- `creditCardAnnualInterest` = balance x APR
- `minimumPaymentTwoPercent` = balance x 0.02
- `loanTotalRepayment`, `loanTotalInterest`
- `debtToIncomeRatio` = debt / income x 100
- `extraPaymentAnnualSaving`, `balanceAfterMonthlyInterest`

### Travel
- `foreignToUSD`, `usdToForeign`
- `currencyMarkupCost`, `foreignTransactionFee`, `totalWithForeignFee`
- `splitTravelCost`, `daysOnBudget`
- `hotelCostPerNight`, `travelInsuranceCost`, `tripTotalWithInsurance`

### Housing & Rent
- `maxRent28` = monthlySalary x 0.28
- `maxAnnualRent28` = monthlySalary x 0.28 x 12
- `rentIncrease` = currentRent x increasePercent / 100
- `newRentAfterIncrease` = currentRent x (1 + increasePercent / 100)
- `moveInThreeMonths` = monthlyRent x 3 (first + last + security)
- `moveInWithBrokerFee` = monthlyRent x 3 + brokerFee
- `pricePerSqft` = monthlyRent / sqft
- `monthlyMortgage` = homePrice x (rate / 12) + homePrice / (years x 12)

### Taxes & Paycheck
- `marginalTax` = bracket1 x rate1 + (income - bracket1Top) x rate2
- `paycheckNet` = grossPay x (1 - deductionPct / 100)
- `grossToNet` = grossPay x (1 - deductionPct / 100)
- `annualToMonthlyNet` = annualSalary x (1 - effectiveRate / 100) / 12
- `taxRefund` = totalWithheld - totalOwed
- `selfEmploymentTax` = freelanceIncome x 0.153

## Distractor Generation

### Proportional Step Algorithm (`niceStep`)
Distractors use a proportional step size that targets ~5-8% of the correct answer, rounded to a psychologically natural number (multiples of 1, 2.5, 5, or 10 at the appropriate order of magnitude). This ensures wrong answers look like real mistakes regardless of answer magnitude.

Examples:
- $78,000 answer → $5,000 step → distractors: $73K, $83K, $68K
- $2,083 answer → $100 step → distractors: $1,983, $2,183
- $45 answer → $2.50 step → distractors: $42.50, $47.50
- $0.67 answer → $0.05 step → distractors: $0.62, $0.72

### Distractor Strategies
| Strategy | Logic |
|---|---|
| `roundedNeighbor` | Correct ± proportional steps (±1, ±2, ±3 steps) |
| `offByDecimal` | Correct x10, /10 (decimal-shift errors) + proportional neighbors |
| `commonMistake` | Context-specific mistakes (tip confusion, flat-rate-vs-marginal tax, 30%-vs-28% rent rule, additive-vs-sequential discounts, etc.) + proportional neighbors as fallback |

## Estimation Mode

Estimation questions use a slider instead of MCQ options. The system generates adaptive slider ranges and grades by proximity.

### Slider Range Computation (`SliderRange.compute`)
1. Spread factor: `1.6 × correctValue` defines the total slider range width.
2. Anti-center positioning: the correct answer is placed in either the lower band (18–38%) or upper band (62–82%) of the slider — never near the center. This prevents gaming the midpoint.
3. Nice-number snapping: min/max are snapped to "nice" boundaries based on magnitude and format.
4. Step size: computed to yield ~40–80 discrete stops. A validation loop caps stops at ≤120.
5. Minimum range width enforced: $5 for currency, 10 for percent, 5 for integer.

### Grading (`EstimationGrade`)
| Grade | Error threshold | Stars | Label |
|---|---|---|---|
| Perfect | ≤ 5% | 3 | "Nailed it!" |
| Good | ≤ 15% | 2 | "Good estimate" |
| Okay | ≤ 30% | 1 | "Close enough" |
| Miss | > 30% | 0 | "Off the mark" |

Error = `|estimate - correct| / |correct|`. A question with ≥2 stars is considered "correct" for session recording.

### Difficulty Filter
`EstimationViewModel.generateItems()` filters templates to `difficulty >= 2` first. Falls back to all templates if fewer than `count` medium-hard templates are available.

### Timer
10-second countdown per question. Timer expiry auto-submits the current slider position (or scores as miss if slider was never dragged).

## Comparison Generation

`ComparisonViewModel.generatePairs(from:count:)` builds comparison pairs:

1. Shuffle template pool.
2. Pick pairs of different templates, generate a question from each.
3. Each pair shows two prompts side-by-side — the player taps the one with the larger answer.
4. 15 pairs per session, 8-second countdown per question.

## Adaptive Difficulty

`AdaptiveDifficultyEngine` selects the starting difficulty for each template:
1. If the user has session history for this template, adaptive logic adjusts based on recent results.
2. If no history exists, the onboarding diagnostic calibration determines starting difficulty per module (beginner → easy, foundation → easy, intermediate → medium).
3. Ultimate fallback: easy.

## Content Stats
- **10 modules**, **47 lessons**, **237 templates**
- Every lesson has exactly **5 templates**
- Templates per module: tips (22), discounts (24), money_math (25), salary (22), investing (20), estimation (24), debt (25), travel (25), housing (25), taxes (25)
- Mix of difficulty levels 1-3 across all modules
