# Numind Claude Instructions

You are building Numind, an iOS-first SwiftUI app for practical number sense.

## Product Summary
Numind helps users build fast, useful mental math for everyday decisions through short lessons, quizzes, and progress tracking. The iOS app is a learning app — calculators belong to the future website, not the app.

## Brand
Numind should feel:
- friendly
- clean
- modern
- useful
- App Store-first
- not childish
- not academic-heavy
- not finance-dashboard-like

Brand motifs:
- brain + abacus
- beads and rails
- number sense
- daily reps
- blue / teal / yellow palette

## Build Strategy
Build the core product first:
Home → Module → Lesson → Quiz → Feedback → Progress.

Onboarding and hard paywall come later, but the app should be architected so they can wrap around the core app.

## Stack
- SwiftUI
- Swift 5.9+
- Deployment target: iOS 17.0
- MVVM
- UserDefaults for local persistence in V1 (SwiftData deferred until backend lands)
- No third-party packages in V1
- Supabase later
- RevenueCat later
- PostHog later
- Sentry later

## Rules
- Do not build backend before local product loop works.
- Do not integrate RevenueCat until core loop exists.
- Do not add AI-generated content in V1.
- Do not force auth in V1 prototype.
- Do not hardcode quiz questions inside SwiftUI views.
- Use template-driven quiz content.
- Centralize design tokens.
- Keep files small and modular.
- Prefer clear simple architecture over abstraction.
- Do not introduce dependencies without explaining why.

## Required Docs To Read
Before implementation, read:
- docs/product/product-brief.md
- docs/product/v1-scope.md
- docs/product/user-flows.md
- docs/product/quiz-engine.md
- docs/product/content-model.md
- docs/brand/brand-guidelines.md
- docs/brand/design-tokens.md
- docs/architecture/tech-stack.md
- docs/claude/implementation-rules.md
- docs/product/prd-summary.md

## First Build Milestone
Build local-first SwiftUI app shell:
- design tokens
- navigation shell with 4 tabs (Home, Learn, Progress, Profile)
- one Tips lesson
- one MCQ-only quiz flow
- local progress update (UserDefaults)

## Source Documents

Long-form DOCX files live in `docs/_source/`.

Important:
The compressed PRD context is in docs/product/prd-summary.md. Use that as active PRD guidance.

Long-form DOCX source files may exist in docs/_source/. Do not read them by default. Only inspect docs/_source/ if the markdown docs are missing, contradictory, or if I explicitly ask you to reference the full PRD.

Do not read these by default during normal implementation. Use the markdown docs in `docs/product`, `docs/brand`, and `docs/architecture` as the source of truth.

Only inspect `docs/_source/` if:
- there is a contradiction in the markdown docs
- product strategy needs clarification
- brand guidance is missing
- architecture decisions are unclear