# Operations Docs

This directory holds ops and process documentation for Numind — anything that's about *how we operate* rather than *what we build*.

## Index

| Doc | What it covers |
|---|---|
| [content-audit-cadence.md](content-audit-cadence.md) | Annual/quarterly cadence for keeping regulated lesson content (tax brackets, federal loan rates, FLSA thresholds, etc.) fresh. Source registry + pre-merge checklist. |
| [regulatory-constants.md](regulatory-constants.md) | Per-number registry: every year-bound dollar threshold, rate, and cap referenced in the curriculum, with current value, lesson IDs that reference it, source URL, and next-refresh date. Pair with content-audit-cadence.md. |
| [numind-score-baseline-2026-05.md](numind-score-baseline-2026-05.md) | Numind Score concept-vs-numerical spread snapshot. No recalibration needed; baseline retained as a tripwire. |

## Conventions

- Ops docs are author-facing, not user-facing.
- Every ops doc should state: who owns it, when it's reviewed, what triggers an update.
- If a doc describes a process, it should also describe the *first* time that process was followed, as a worked example.
- Date-stamp section headers when the content reflects state at a point in time (e.g. "## Sources as of 2026-05").

## Future ops docs (not yet written)

- `release-process.md` — App Store submission, TestFlight, version bumps.
- `incident-response.md` — production-issue triage.
- `analytics-event-registry.md` — every PostHog event the app fires, owner, what it's used for.
- `pricing-experiments.md` — paywall test cadence and decision criteria.
