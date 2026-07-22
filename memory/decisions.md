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
- **Status**: Active — implemented Tier 1 (Welcome, Goal, Priority, Recommendation) + Tier 2 (Complexity Meter, Business Maturity, Timeline Urgency, Budget Confidence, Assets Checklist) + Tier 3 (Proposal Generator) in sequential order

## DEC-20260722-0003
- **Date**: 2026-07-22
- **Context**: Architecture for proposal PDF generation
- **Decision**: Use client-side jsPDF CDN — no server-side PDF rendering or build step
- **Rationale**: The admin dashboard is a single HTML file with Alpine.js. Adding a build dependency (node, vite, puppeteer, etc.) for PDF generation adds disproportionate complexity. jsPDF from CDN can produce clean A4 proposals matching AM Worx branding.
- **Status**: Active

## DEC-20260722-0004
- **Date**: 2026-07-22
- **Context**: Complexity scoring methodology for package recommendation
- **Decision**: Use additive scoring based on website type (0-8), page count (1 each), and feature complexity (1-3 each) — mapped to Essential (0-5), Growth (6-12), Scale (13+)
- **Rationale**: Simple, transparent, explainable to clients. No machine learning or statistical modeling needed at this stage. Weights can be adjusted as data accumulates.
- **Status**: Active

## DEC-20260722-0005
- **Date**: 2026-07-22
- **Context**: Feature priority toggle UX pattern
- **Decision**: Use click-to-toggle button with visual state change (blue "Required" ↔ amber "Nice-to-have") instead of separate columns or drag-and-drop
- **Rationale**: Lowest cognitive overhead for the client. Single click changes state. Color coding is intuitive. Hidden entirely in Bundle mode since features are bundled.
- **Status**: Active
