-- ============================================================
-- 食べ物マスタ & 食事割り当てテーブル
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

-- ── food_items: ユーザーごとの食べ物マスタ ──
create table if not exists public.food_items (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);

-- ── meal_assignments: 旅程の日付×食事スロットへの割り当て ──
create table if not exists public.meal_assignments (
  id           uuid primary key default gen_random_uuid(),
  trip_id      uuid not null references public.trips on delete cascade,
  date         date not null,
  meal_slot    text not null check (meal_slot in ('breakfast', 'lunch', 'dinner')),
  food_item_id uuid references public.food_items on delete set null,
  created_at   timestamptz not null default now(),
  unique (trip_id, date, meal_slot)
);

-- ── Enable Row Level Security ────────────────────────────────
alter table public.food_items       enable row level security;
alter table public.meal_assignments enable row level security;

-- ── RLS Policies ────────────────────────────────────────────

-- food_items: オーナーのみ全操作
create policy "food_items_owner_all"
  on public.food_items for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- meal_assignments: 旅程オーナーのみ全操作
create policy "meal_assignments_owner_all"
  on public.meal_assignments for all
  using (public.is_trip_owner(trip_id))
  with check (public.is_trip_owner(trip_id));
