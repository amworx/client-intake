# Decisions

## DEC-20260718-0001
- **Date**: 2026-07-18
- **Context**: Architecture choice for client intake app
- **Decision**: Use Supabase (free tier) as backend instead of previous Google Apps Script + EmailJS + FormSubmit stack
- **Rationale**: Single backend for DB, auth, storage, real-time. Simpler setup, fewer services.
- **Status**: Active

## DEC-20260722-0002
- **Date**: 2026-07-22
- **Context**: Project strategic direction after external expert review
- **Decision**: Shift product mindset from "survey form" to "intelligent sales, qualification, and proposal-generation system"
- **Rationale**: Existing technical architecture (Supabase, OTP, bundle pricing, admin dashboard) is strong enough to support this vision. The biggest ROI is in UX improvements that reduce abandonment and features that automate proposal generation — not in further infrastructure.
- **Status**: Pending — awaiting user prioritization
