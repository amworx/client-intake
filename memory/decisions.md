# Decisions

## DEC-20260718-0001
- **Date**: 2026-07-18
- **Context**: Architecture choice for client intake app
- **Decision**: Use Supabase (free tier) as backend instead of previous Google Apps Script + EmailJS + FormSubmit stack
- **Rationale**: Single backend for DB, auth, storage, real-time. Simpler setup, fewer services.
- **Status**: Active
