-- Migration: Add bundles JSONB column to settings table
-- This allows admins to edit bundle tier names, prices, colors, and features from the Settings page

alter table if exists public.settings
  add column if not exists bundles jsonb default '[]'::jsonb;

-- Seed default bundle tiers if column is empty or newly created
update public.settings
set bundles = '[
  {
    "id": "essential",
    "name": "Essential",
    "price": 19,
    "icon": "rocket",
    "color": "#22c55e",
    "features": [
      "Web hosting",
      "SSL certificate",
      "Weekly backups",
      "Security updates",
      "Email support",
      "1 hour/month minor edits"
    ]
  },
  {
    "id": "growth",
    "name": "Growth",
    "price": 49,
    "icon": "trending-up",
    "color": "#6366f1",
    "features": [
      "Everything in Essential",
      "Faster hosting",
      "Daily backups",
      "Priority support",
      "Up to 5 business emails",
      "3 hours/month content updates",
      "Performance monitoring",
      "Basic SEO monitoring"
    ]
  },
  {
    "id": "scale",
    "name": "Scale",
    "price": 89,
    "icon": "award",
    "color": "#ec4899",
    "features": [
      "Everything in Growth",
      "Premium hosting",
      "Unlimited business emails",
      "Advanced security monitoring",
      "Monthly SEO report",
      "Analytics report",
      "Up to 8 hours/month updates",
      "Emergency support",
      "Consultation calls"
    ]
  }
]'::jsonb
where id = 1 and (bundles is null or bundles = '[]'::jsonb);
