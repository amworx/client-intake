# client_intake — Project Rules

Inherits global doctrine from `~/.config/opencode/AGENTS.md`.

## Project Type
Client survey / intake form + admin dashboard for **AM Worx** web design studio.

## Stack
- **Hosting**: GitHub Pages (free, static)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Intake form**: Single `index.html` (vanilla JS, embedded CSS)
- **Admin dashboard**: Single `admin/index.html` (Alpine.js + Tailwind CSS CDN)
- **CDN deps**: supabase-js, jsPDF, Google Fonts (Inter), Alpine.js, Font Awesome, Tailwind CSS

## Key Files
| File | Purpose |
|------|---------|
| `index.html` | Client intake form (7 sections, price calculator, file upload, OTP, PDF) |
| `admin/index.html` | Admin dashboard (auth, submissions table, settings, real-time) |
| `docs/schema.sql` | Complete Supabase SQL (tables, RLS, seed data) |
| `docs/setup.md` | Step-by-step setup guide for new users |
| `supabase/functions/send-notification/index.ts` | Optional Gmail SMTP Edge Function |
| `memory/credentials.md` | Stored Supabase keys and config |

## Supabase Config (embedded)
- URL: `https://jyqjkkcenuapssmstmze.supabase.co`
- Anon key stored in `memory/credentials.md`

## Conventions
- All Supabase client instances created with `supabase-js` v2 from CDN
- Intake form uses `data-price` attributes for pricing
- Admin uses Alpine.js for reactivity (no build step)
- Gmail SMTP app password still needed for email notifications
