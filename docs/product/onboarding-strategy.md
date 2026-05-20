# Onboarding Strategy

> **Last updated:** May 2026 (after V1 refinement — diagnostic calibration now wired into session difficulty and question count).

Numind will eventually use a long onboarding flow with:
1. Welcome/value proposition
2. Goal selection
3. Skill confidence question
4. 5–7 question diagnostic test
5. Preliminary evaluation
6. Personalized plan preview
7. 5-day trial hard paywall

## Purpose
Onboarding should prime the user to believe:
- Numind understands their current number sense
- their weaknesses are practical and fixable
- short daily reps will help
- the paid plan is personalized and useful

## Diagnostic → Session Calibration
The onboarding diagnostic collects per-module starting difficulties via `OnboardingSignals.startingDifficulties`. These now feed into the app experience:

**Starting difficulty per module** (`AdaptiveDifficultyEngine`):
- Beginner → starts at easy difficulty
- Foundation → starts at easy, faster ramp to medium
- Intermediate → starts at medium (skips easy entirely)

**Dynamic question count** (`QuizSessionViewModel.lessonQuestionCount`):
- Intermediate: 5 questions (strong — shorter first session)
- Foundation: 6 questions (decent — slightly shorter)
- Beginner: 8 questions (needs work — full session)
- No diagnostic data: 5 questions (gentle default)

## Future Inputs
The core app accepts from onboarding:
- selected goals
- baseline level (via OnboardingSignals)
- weak areas (per-module starting difficulties)
- recommended path
- entitlement status