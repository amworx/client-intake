# AM Worx Intake — Fresh Build with Supabase

A client survey / intake form + admin dashboard for a web design studio.

**Stack:** GitHub Pages (hosting) + Supabase (database, auth, storage, real-time)
**Cost:** $0 (all free tiers)
**Setup time for new user:** ~15 minutes, 1 account (Supabase)

---

## 1. Architecture

```
┌──────────────────────────────────────────────────┐
│                GitHub Pages (free)                │
│                                                   │
│  index.html                                       │
│    └─ Client intake form (7 sections)             │
│    └─ Price calculator (live)                     │
│    └─ File upload                                 │
│    └─ Email verification (OTP)                    │
│    └─ Submit → Supabase                           │
│                                                   │
│  admin/index.html                                 │
│    └─ Login via Supabase Auth (email/password)    │
│    └─ Dashboard (stats, charts)                   │
│    └─ Submissions table + detail panel            │
│    └─ Settings (prices, sections, general)         │
│    └─ Real-time updates                           │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│              Supabase (free tier)                  │
│                                                   │
│  PostgreSQL: submissions, settings                │
│  Storage: uploaded files (25MB limit)             │
│  Auth: admin login                                │
│  Realtime: new submissions push to dashboard      │
│  (Optional) Edge Function: email notification     │
└──────────────────────────────────────────────────┘
```

---

## 2. Supabase Schema

### 2.1 Tables

#### `submissions`

Stores every intake form submission.

| Column | Type | Notes |
|---|---|---|
| `id` | `BIGINT PK` | Auto-generated |
| `created_at` | `TIMESTAMPTZ` | `DEFAULT now()` |
| `status` | `TEXT` | `'New'` or `'Reviewed'`, default `'New'` |
| `full_name` | `TEXT NOT NULL` | Client name |
| `business_name` | `TEXT` | |
| `client_email` | `TEXT NOT NULL` | |
| `client_phone` | `TEXT` | |
| `domain` | `TEXT` | `'need'`, `'no-need'`, `'not-sure'` |
| `domain_idea` | `TEXT` | Custom domain name |
| `hosting` | `TEXT` | `'need'`, `'no-need'`, `'not-sure'` |
| `email` | `TEXT` | `'need'`, `'no-need'`, `'not-sure'` |
| `email_count` | `INT` | 1-5, default 1 |
| `setup_help` | `TEXT` | `'yes'`, `'no'` |
| `business_desc` | `TEXT` | |
| `website_type` | `TEXT` | `'simple'`, `'business'`, `'portfolio'`, `'blog'`, `'ecommerce-small'`, `'ecommerce-large'`, `'booking'`, `'membership'`, `'directory'` |
| `pages` | `JSONB` | Array of selected page values |
| `other_pages` | `TEXT` | Custom page names |
| `features` | `JSONB` | Array of selected feature values |
| `logo` | `TEXT` | `'yes'`, `'have'`, `'later'` |
| `content_text` | `TEXT` | `'self'`, `'need-help'`, `'ready'` |
| `content_photos` | `TEXT` | `'my-own'`, `'free-stock'`, `'not-sure'` |
| `brand_colors` | `TEXT` | |
| `inspiration_links` | `TEXT` | |
| `timeline` | `TEXT` | `'1-week'`, `'2-weeks'`, `'1-month'`, `'flexible'` |
| `maintenance` | `TEXT` | `'no'`, `'basic'`, `'standard'`, `'premium'` |
| `budget` | `TEXT` | `'100-300'`, `'300-500'`, `'500-1000'`, `'1000+'`, `'not-sure'` |
| `extra_notes` | `TEXT` | |
| `estimated_total` | `NUMERIC(10,2)` | Calculated price |
| `price_breakdown` | `JSONB` | Array of `{label, price, qty, lineTotal}` |
| `file_urls` | `JSONB` | Array of `{name, url}` after upload to storage |
| `request_time` | `TEXT` | Browser timestamp |

#### `settings`

Singleton row (id=1) for all admin-configurable settings.

| Column | Type | Notes |
|---|---|---|
| `id` | `INT PK` | Always 1, enforced by CHECK |
| `studio_name` | `TEXT` | Default: `'AM Worx'` |
| `studio_email` | `TEXT` | For notifications |
| `form_url` | `TEXT` | GitHub Pages URL for sidebar link |
| `auto_refresh_sec` | `INT` | Default: 60 |
| `toast_duration_ms` | `INT` | Default: 3000 |
| `session_expiry_hours` | `INT` | Default: 24 |
| `date_style` | `TEXT` | `'short'`, `'medium'`, `'long'` |
| `prices` | `JSONB` | All price overrides as key-value pairs |
| `sections` | `JSONB` | All 7 section configs with custom options |
| `updated_at` | `TIMESTAMPTZ` | |

#### `section_groups`

Read-only reference mapping each section to available field groups for custom options.

| Column | Type | Notes |
|---|---|---|
| `section_key` | `TEXT PK` | e.g. `'hosting'`, `'website'` |
| `groups` | `JSONB` | Array of `{label, value}` |

#### `otp_codes` (if OTP is kept)

| Column | Type | Notes |
|---|---|---|
| `id` | `BIGINT PK` | |
| `email` | `TEXT NOT NULL` | Client email |
| `code` | `TEXT NOT NULL` | 6-digit code |
| `expires_at` | `TIMESTAMPTZ` | 5 minutes from creation |
| `used` | `BOOLEAN` | Default false |

### 2.2 Storage Bucket

| Property | Value |
|---|---|
| Name | `submissions` |
| Public | `true` (or false with signed URLs) |
| File limit | 25 MB |

### 2.3 RLS Policies

**submissions:**
- `INSERT` → anon (anyone can submit)
- `SELECT` → authenticated (admin only)
- `UPDATE` → authenticated (admin only)
- `DELETE` → authenticated (admin only)

**settings:**
- `SELECT` → anon (intake form needs prices + sections)
- `UPDATE` → authenticated (admin only)

**section_groups:**
- `SELECT` → anon

**storage.objects (bucket: submissions):**
- `INSERT` → anon (anyone can upload)
- `SELECT` → anon (anyone can read files)
- `DELETE` → authenticated (admin only)

### 2.4 Auth

Create 1 admin user in Supabase Auth dashboard (email/password). No client auth required.

---

## 3. Intake Form (`index.html`)

### 3.1 Stack

| Technology | Source |
|---|---|
| HTML + CSS | Single file, embedded |
| supabase-js | CDN `unpkg.com/@supabase/supabase-js@2` |
| jsPDF | CDN for PDF generation |
| Google Fonts (Inter) | CDN |

### 3.2 Features

| # | Feature | How it works |
|---|---|---|
| 1 | **7 survey sections** | Hardcoded HTML with radio/checkbox/text inputs |
| 2 | **Live price calculator** | `calculate()` on every change event, reads `data-price` attributes + Supabase overrides |
| 3 | **Price breakdown modal** | Renders line items from `window._priceItems` |
| 4 | **Progress tracker** | 7 clickable steps with IntersectionObserver, auto-highlights current section |
| 5 | **Dark mode** | localStorage toggle, `.dark` class on `<html>` |
| 6 | **Draft auto-save** | localStorage, 800ms debounce |
| 7 | **File upload** | Multiple files, drag area, 25MB limit, preview list with remove |
| 8 | **Email verification (OTP)** | Optional — Edge Function sends code, or remove entirely |
| 9 | **Form validation** | Name, email format, OTP verified, required fields |
| 10 | **PDF generation** | jsPDF creates multi-page summary PDF on submit |
| 11 | **Submission to Supabase** | Insert row + upload files to storage |
| 12 | **Dynamic overrides** | Load prices + sections from Supabase on page load |
| 13 | **Section visibility** | Hide disabled sections + their progress steps |
| 14 | **Custom options** | Inject admin-defined custom radio/checkbox choices |
| 15 | **Thank-you screen** | Green checkmark, delivery status |

### 3.3 Data Flow on Submit

```js
async function submitForm() {
  // 1. Validate
  if (!validate()) return;

  // 2. Upload files to Supabase Storage
  const fileUrls = [];
  for (const file of selectedFiles) {
    const path = `submissions/${Date.now()}_${file.name}`;
    await supabase.storage.from('submissions').upload(path, file);
    const { data: { publicUrl } } = supabase.storage.from('submissions').getPublicUrl(path);
    fileUrls.push({ name: file.name, url: publicUrl });
  }

  // 3. Generate PDF and upload it too
  const pdf = await generateSubmissionPdf();
  const pdfPath = `submissions/${Date.now()}_Website-Request.pdf`;
  await supabase.storage.from('submissions').upload(pdfPath, pdf);
  fileUrls.push({ name: 'Website-Request.pdf', url: pdfPath });

  // 4. Insert submission
  const { error } = await supabase.from('submissions').insert({
    full_name: getValue('full_name'),
    business_name: getValue('business_name'),
    client_email: getValue('client_email'),
    // ... all form fields
    estimated_total: calculatedTotal,
    price_breakdown: window._priceItems,
    file_urls: fileUrls,
    request_time: new Date().toLocaleString()
  });

  // 5. Show thank-you
  showThankYou();
  clearDraft();
}
```

### 3.4 Dynamic Override Loading

```js
async function loadOverrides() {
  const { data } = await supabase
    .from('settings')
    .select('prices, sections')
    .eq('id', 1)
    .single();

  if (data?.prices) window.PRICES_OVERRIDE = data.prices;
  if (data?.sections) applySectionSettings(data.sections);
}
```

### 3.5 OTP Verification Flow (if kept)

```js
// Generate + send code via Edge Function
async function sendOtp(email) {
  const code = String(Math.floor(100000 + Math.random() * 900000));
  const { error } = await supabase
    .from('otp_codes')
    .insert({ email, code, expires_at: new Date(Date.now() + 5*60000).toISOString() });

  // Trigger Edge Function to email the code
  await fetch(`${EDGE_FUNCTION_URL}/send-otp`, {
    method: 'POST',
    body: JSON.stringify({ email, code, studio_name })
  });
}

// Verify
async function verifyOtp(email, code) {
  const { data } = await supabase
    .from('otp_codes')
    .select('*')
    .eq('email', email)
    .eq('code', code)
    .eq('used', false)
    .gte('expires_at', new Date().toISOString())
    .single();

  if (data) {
    await supabase.from('otp_codes').update({ used: true }).eq('id', data.id);
    return true;
  }
  return false;
}
```

---

## 4. Admin Dashboard (`admin/index.html`)

### 4.1 Stack

| Technology | Source |
|---|---|
| Alpine.js 3.x | CDN |
| Tailwind CSS 3 | CDN |
| Font Awesome 6 | CDN |
| supabase-js | CDN |
| All in one file | No build step |

### 4.2 Auth UI

Login page with:
- Email + password fields
- "Unlock Dashboard" button
- Error message on invalid credentials
- Monkey/Uiverse card design (or any clean design)

Uses Supabase Auth:
```js
const { data, error } = await supabase.auth.signInWithPassword({
  email: this.loginEmail,
  password: this.loginPassword
});
```

Session persists automatically via Supabase's built-in session management.

### 4.3 Layout

- **Sidebar:** Logo, nav (Dashboard, Submissions, Settings, View Form, Log Out), connection status
- **Header:** Page title, new submission count badge with pulse animation, dark mode toggle, refresh button
- **Main content:** Changes based on active view

### 4.4 Dashboard View

**Stats cards (4):**
| Card | Value | Description |
|---|---|---|
| Total | `submissions.length` | "All time submissions" |
| New | `submissions.filter(s => s.status === 'New').length` | "Awaiting review" |
| Reviewed | `submissions.filter(s => s.status === 'Reviewed').length` | "Completed reviews" |
| Est. Revenue | Sum of `estimated_total` | "Combined estimate" |

**Recent submissions table (5 rows):**
| Column | Source |
|---|---|
| Name | `full_name` |
| Business | `business_name` |
| Date | `created_at` formatted |
| Estimate | `estimated_total` formatted |
| Status | `status` badge (New/Reviewed) |

### 4.5 Submissions View

**Full table with columns:**
- Name (with avatar first-letter circle)
- Business
- Email (mailto link)
- Date
- Estimate
- Status badge (New = blue with pulse, Reviewed = green)
- Actions (View, Toggle Status, Delete)

**Features:**
- Search/filter by name, business, email (case-insensitive)
- "X of Y" filtered counter
- Row click opens detail panel
- Striped rows, hover highlight

**Submission detail panel (slide-in from right):**
- Header: avatar + name + business + date
- Status badge
- Field groups displayed as labeled sections (only non-empty shown)
- Action buttons: Mark Reviewed/New, Delete, Close
- Click-outside or close button to dismiss

### 4.6 Settings View

Width: `w-full` (full width)

**General Settings:**
| Field | Type |
|---|---|
| Studio Name | Text |
| Studio Email | Email |
| Form URL | URL |
| Auto-refresh (seconds) | Number stepper (10-3600) |
| Toast Duration (ms) | Number stepper (500-10000) |
| Session Expiry (hours) | Number stepper (1-720) |
| Date Format | Select (short/medium/long) |

**Pricing Management (all use stepper UI):**
- 57 price fields grouped by category:
  - Domain (2)
  - Hosting (2)
  - Business Email (2)
  - Setup Help (1)
  - Website Type (9)
  - Pages (12)
  - Features (20)
  - Logo (1)
  - Text Content (1)
  - Photos (1)
  - Timeline (1)
  - Maintenance (4)

**Survey Sections CRUD (7 cards, each with):**
- Collapsible card
- Section title (text input)
- Description (textarea)
- Show/hide toggle (checkbox)
- Custom options list with add/edit/delete:
  - Label (text)
  - Value (text)
  - Group (dropdown from section_groups)
  - Price (number)

**Danger Zone:**
- "Reset to Defaults" button with confirm dialog

### 4.7 Data Loading & Real-time

**Initial load:**
```js
async loadSubmissions() {
  const { data, error } = await supabase
    .from('submissions')
    .select('*')
    .order('created_at', { ascending: false });
  this.submissions = data || [];
}
```

**Real-time subscription:**
```js
supabase
  .channel('submissions')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'submissions' },
    (payload) => {
      this.submissions.unshift(payload.new);
      this.showToast(`New: ${payload.new.full_name}`, 'ok');
    }
  )
  .subscribe();
```

### 4.8 CRUD Operations

**Toggle status:**
```js
supabase.from('submissions').update({ status: newStatus }).eq('id', id)
```

**Delete:**
```js
supabase.from('submissions').delete().eq('id', id)
```

**Save settings:**
```js
supabase.from('settings').update({
  studio_name, studio_email, form_url,
  auto_refresh_sec, toast_duration_ms, session_expiry_hours, date_style,
  prices: this.settingsForm.PRICES,
  sections: this.settingsForm.SECTIONS
}).eq('id', 1)
```

**Load settings:**
```js
const { data } = await supabase.from('settings').select('*').eq('id', 1).single();
```

### 4.9 HeroUI-Style Number Stepper

CSS component injected via JS on page load:
```html
<div class="number-stepper">
  <button class="stepper-btn stepper-dec">−</button>
  <input class="stepper-input" type="number" ...>
  <button class="stepper-btn stepper-inc">+</button>
</div>
```

- 28×28px buttons
- 44px wide input (64px for standalone)
- Hidden native spinners
- Dark mode support
- Respects min/max/step attributes
- Global click handler dispatches native `input` event

Transform is idempotent — runs once via `$nextTick` and `$watch` on loading state.

---

## 5. Email Notification (Optional)

Three options, choose one:

| Option | Setup time | Complexity | Cost |
|---|---|---|---|
| **A. Skip** — admin watches dashboard in real-time | 0 min | None | Free |
| **B. Edge Function + Gmail SMTP** | 5 min | Medium | Free (app password) |
| **C. Edge Function + Resend** | 5 min | Low | 100/mo free |

### Option A — Skip
New submissions appear instantly in the dashboard via Realtime subscription. No email configuration needed.

### Option B — Gmail SMTP
1. Enable 2FA on admin Gmail → generate App Password
2. Deploy Edge Function that sends via `smtp.gmail.com:465`
3. Create Database Webhook on `submissions` INSERT → trigger Edge Function

### Option C — Resend (simplest if they want email)
```js
// Edge Function
import { Resend } from 'npm:resend';
const resend = new Resend(Deno.env.get('RESEND_API_KEY'));

await resend.emails.send({
  from: 'studio@yourdomain.com',
  to: 'admin@gmail.com',
  subject: `New: ${record.full_name}`,
  html: buildEmailHtml(record)
});
```

---

## 6. New User Setup Instructions

### Step-by-step

```
 1. Fork this repo on GitHub
 2. Enable GitHub Pages (Settings → Pages → / → Save)
 3. Go to https://supabase.com → New project (free, no credit card)
 4. Run the SQL from docs/schema.sql in the SQL Editor
 5. Create an admin user (Auth → Users → Add User)
 6. Copy SUPABASE_URL + SUPABASE_ANON_KEY from Settings → API
 7. Edit index.html:
      - Paste SUPABASE_URL and SUPABASE_ANON_KEY
      - Change STUDIO_NAME and STUDIO_EMAIL
 8. Edit admin/index.html:
      - Paste SUPABASE_URL and SUPABASE_ANON_KEY
      - Change APP_NAME and FORM_URL
 9. Push to GitHub → site is live on GitHub Pages
10. (Optional) Set up email notification
```

**Total time: ~15 minutes**
**Accounts needed: GitHub + Supabase (2)**
**Previously: GitHub + Google + EmailJS + FormSubmit (4)**

---

## 7. File Structure

```
project/
├── AGENTS.md
├── index.html                ← Intake form (all features)
├── admin/
│   └── index.html            ← Admin dashboard
├── docs/
│   ├── schema.sql            ← Complete SQL (tables, RLS, seed)
│   └── setup.md              ← Step-by-step guide for new users
├── supabase/
│   └── functions/
│       └── send-notification/ ← (Optional) Email Edge Function
│           └── index.ts
└── memory/
    └── (events, lessons, patterns, decisions, playbooks)
```

---

## 8. Complete Feature Checklist

### Intake Form
- [ ] 7 survey sections with all original fields
- [ ] Live price calculator with breakdown modal
- [ ] Progress tracker with IntersectionObserver
- [ ] Dark mode toggle
- [ ] Draft auto-save (localStorage)
- [ ] File upload with preview and remove
- [ ] Email verification (OTP) — optional
- [ ] Form validation (name, email, OTP)
- [ ] PDF generation
- [ ] Dynamic prices from Supabase
- [ ] Dynamic section overrides (title, desc, show/hide, custom options)
- [ ] Submit → Supabase (insert + file upload)
- [ ] Thank-you screen

### Admin Dashboard
- [ ] Supabase Auth login (email/password)
- [ ] 4 stat cards (Total, New, Reviewed, Revenue)
- [ ] Recent submissions (5 rows)
- [ ] Full submissions table with search/filter
- [ ] Submission detail slide-in panel
- [ ] Status toggle (New ↔ Reviewed)
- [ ] Delete with confirmation modal
- [ ] Real-time new submission notification
- [ ] Settings: general fields
- [ ] Settings: 57 price steppers
- [ ] Settings: 7 section cards with CRUD custom options
- [ ] Settings: Reset to defaults
- [ ] HeroUI-style number stepper UI
- [ ] Dark mode toggle
- [ ] Loading skeleton + error state
- [ ] Toast notifications
- [ ] Auto-refresh / real-time updates

### Backend (Supabase)
- [ ] submissions table with RLS
- [ ] settings table with RLS
- [ ] section_groups reference table
- [ ] otp_codes table (if OTP kept)
- [ ] Storage bucket for files
- [ ] Edge Function for email (optional)
- [ ] Database Webhook (optional)

---

## 9. Implementation Order

### Phase 1 — Foundation
1. Create Supabase project
2. Run `docs/schema.sql`
3. Create admin user in Auth
4. Set up Storage bucket

### Phase 2 — Intake Form
1. Build HTML structure (all 7 sections, progress tracker, price bar)
2. Build CSS (light + dark mode)
3. Build `calculate()` function
4. Build Supabase integration (load overrides, submit, upload files)
5. Build file upload UI
6. Build OTP verification (or remove)
7. Build PDF generation
8. Build form validation + thank-you screen
9. Test end-to-end

### Phase 3 — Admin Dashboard
1. Build HTML layout (sidebar, header, views)
2. Build Auth UI + Supabase Auth integration
3. Build submissions table + detail panel
4. Build CRUD (toggle status, delete)
5. Build settings panel (general)
6. Build pricing management (57 steppers)
7. Build survey sections CRUD
8. Build real-time subscription
9. Test end-to-end

### Phase 4 — Polish
1. Loading/error/empty states
2. Dark mode refinement
3. Responsive design
4. Documentation (`docs/setup.md`)
5. Push to GitHub Pages
6. Test live deployment

### Phase 5 — Email (Optional)
1. Create Edge Function
2. Set up Database Webhook
3. Test email delivery
