# Onboarding Strategy

> **Last updated:** June 2026 — **funnel v2 (decision-first) is built as a
> testable baseline.** The as-built screen-by-screen spec lives in
> [`onboarding-funnel-v2.md`](onboarding-funnel-v2.md); this doc keeps the
> strategy + calibration mechanics.

The 26-screen funnel (anonymous end-to-end, CalAI-style hard paywall at the
end):
1. Problem framing (money-stress proof + moments frame + insecurity mirror)
2. Personalization (confidence, motivations, **life-moment picker** → focus pack, mirroring, real deadline)
3. Commitment (ring target, kaizen, ADHD tuning, name/age)
4. **Diagnostic-as-demo** (pack-weighted, shortcut reveal after every answer, live goal ring)
5. **Money Map** reveal + personalized plan (dated "Ready around…" timeline)
6. Priming (notifications, ROI, ring-streak goal, projection, trial-reminder transparency)
7. 7-day-trial hard paywall → welcome → first workout

## Purpose
Onboarding should prime the user to believe:
- Numind understands their current financial fluency (concepts they know vs. concepts they can actually apply)
- their gaps are practical, common, and fixable — not "you're bad at math"
- short daily reps will close those gaps in real money decisions, not just trivia
- the paid plan is personalized and useful — math is just the teaching method, the outcome is financial confidence

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