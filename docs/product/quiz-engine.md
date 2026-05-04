# Quiz Engine

> **Last updated:** May 2026 (after M56).

## Principle
Questions are generated from templates, not hardcoded. Each quiz session produces different numbers, different answer choices, and different question order - even when replaying the same lesson.

## Session Parameters
- **Questions per session:** 8 (both lesson quizzes and checkpoint reviews)
- **Mastery threshold:** 75% (6/8 correct)
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
| `moduleId` | yes | Parent module (tips, discounts, money_math, salary, investing, estimation, debt, travel) |
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
2. Cycle through templates: `template[idx % count]` until 8 questions are built
3. Shuffle the question order
4. Each `generate` call uses a fresh random seed

## Checkpoint Review Generation (`CheckpointQuizEngine`)
For module review quizzes (every 3 lessons):
1. Gather templates for each covered lesson
2. Round-robin across lesson buckets to ensure even coverage
3. Generate 8 questions total
4. Shuffle the question order

This ensures every covered lesson is represented roughly equally in the review.

## Answer Formulas (40+)
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

### Money Math
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
- `hourlyFromAnnual` (/2000), `annualFromHourly` (x2000)

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

## Distractor Strategies
| Strategy | Logic |
|---|---|
| `roundedNeighbor` | Correct +/- small deltas (0.5, 1.0, 1.5, 2.0, etc.) |
| `offByDecimal` | Correct x10, /10, and similar decimal-shift errors |
| `commonMistake` | Context-specific mistakes (e.g., dividing tip before adding to bill) |

## Content Stats (as of M56)
- **8 modules**, **37 lessons**, **187 templates**
- Every lesson has exactly **5 templates**
- Templates per module: tips (22), discounts (19), money_math (23), salary (17), investing (17), estimation (17), debt (18), travel (17)
- Mix of difficulty levels 1-3 across all modules
