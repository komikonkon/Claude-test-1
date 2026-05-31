-- ============================================================
-- events に「種類」カラムを追加（🍽食事 / 📍予定）
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

alter table public.events
  add column if not exists kind text not null default 'plan'
  check (kind in ('plan', 'meal'));
