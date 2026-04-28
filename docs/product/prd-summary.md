# Numind PRD Summary

## Product Thesis
Numind is an iOS-first daily training app for practical number fluency.

It helps users get faster and more confident with real-world money math:
- tips
- tax
- bill split
- discounts
- percentage change
- everyday money math
- estimation

The product should feel like a short useful workout, not a textbook, calculator utility, or generic brain-training app.

## Core Promise
Get faster at everyday money math in 5 minutes a day.

## Positioning
Do position as:
- daily real-world number fluency
- everyday money math for adults
- short practical training workouts
- confidence and speed in daily life

Do not position as:
- a broad microlearning app
- a kids math app
- a calculator replacement
- a medical brain-health product

## Target User
Adults and young adults, roughly 22–40, who want to feel sharper, faster, and more confident with everyday math.

They may feel slow or rusty with:
- splitting bills
- calculating tips
- judging discounts
- estimating totals
- interpreting percentages

## V1 Modules
1. Tips, Tax, and Bill Split
2. Discounts and Shopping
3. Everyday Money Math
4. Estimation and Number Sense

## Core User Loop
Home / Today
→ start daily workout or module
→ short lesson
→ quiz/practice set
→ instant feedback
→ session summary
→ progress update

## Session Types
- Daily Workout: 8–12 questions, 2–4 minutes
- Quick Drill: 5 focused questions
- Speed Round: 10 questions, 45–60 seconds

## Lessons
Lessons should be micro-primers, not long content.

Each lesson should include:
- one concept
- one shortcut
- one real-world example
- immediate practice

Lesson types:
- Shortcut lesson
- Pattern lesson
- Estimation lesson
- Scenario lesson

## Question System
Questions must be generated from templates, not static hardcoded question banks.

Each template should define:
- template id
- module
- skill tags
- difficulty
- variables
- rendered prompt
- correct answer logic
- distractor generation
- answer format
- feedback explanation

V1 question types:
- multiple choice
- numeric input later
- comparison
- estimate range

Question generation rules:
- numbers vary within constraints
- options shuffle
- distractors reflect common mistakes
- explanations are short and practical
- difficulty depends on number neatness, operation count, time pressure, and scenario messiness

## Feedback
Feedback must be immediate, short, and useful.

Correct:
- reinforce shortcut
- keep tone encouraging

Incorrect:
- show correct answer
- explain the simplest shortcut
- avoid long textbook solutions

## Progress
V1 should track:
- current streak
- workouts completed
- average accuracy
- average response time
- category scores
- short improvement insight

Example:
“You’re fast at 10% and 20% tips, but slower on awkward bill splits.”

## Future Onboarding / Paywall
Later flow:
Welcome
→ motivation selection
→ self-rating
→ diagnostic
→ results
→ personalized plan
→ hard paywall with 7-day free trial

Do not build this before the core app loop exists.

## Website Layer
The website is not the product. It supports acquisition through:
- landing page
- SEO calculators
- privacy/terms/support
- App Store conversion

Calculator pages can include:
- tip calculator
- bill split calculator
- tax + tip calculator
- discount calculator
- percentage change calculator

## V1 Build Priority
First build:
- SwiftUI app shell
- design tokens
- local content model
- template-driven quiz engine
- one complete Tips lesson loop
- feedback and progress update

Do not build yet:
- backend
- RevenueCat
- PostHog
- Sentry
- Supabase
- AI
- social features
- full onboarding/paywall