-- ============================================================
-- 予定候補マスタテーブル
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

create table if not exists public.plan_items (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);

alter table public.plan_items enable row level security;

create policy "plan_items_owner_all"
  on public.plan_items for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
