-- ============================================================
-- Supabase Schema for Travel Itinerary App
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- ── Tables ──────────────────────────────────────────────────

create table if not exists public.trips (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users on delete cascade,
  title          text not null default '',
  date_from      date,
  date_to        date,
  excluded_dates text[] not null default '{}',
  created_at     timestamptz not null default now()
);

create table if not exists public.events (
  id         uuid primary key default gen_random_uuid(),
  trip_id    uuid not null references public.trips on delete cascade,
  date       date not null,
  time       text not null default '',
  description text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.trip_shares (
  id                 uuid primary key default gen_random_uuid(),
  trip_id            uuid not null references public.trips on delete cascade,
  shared_with_email  text not null,
  permission         text not null default 'view'
                       check (permission in ('view', 'edit')),
  created_at         timestamptz not null default now(),
  unique (trip_id, shared_with_email)
);

-- ── Enable Row Level Security ────────────────────────────────

alter table public.trips       enable row level security;
alter table public.events      enable row level security;
alter table public.trip_shares enable row level security;

-- ── Helper: is the current user the owner of a trip? ────────

create or replace function public.is_trip_owner(p_trip_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.trips
    where id = p_trip_id
      and user_id = auth.uid()
  );
$$;

-- ── Helper: does the current user have (at least) view access? ──

create or replace function public.can_view_trip(p_trip_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select
    public.is_trip_owner(p_trip_id)
    or exists (
      select 1 from public.trip_shares ts
      join auth.users u on u.email = ts.shared_with_email
      where ts.trip_id = p_trip_id
        and u.id = auth.uid()
    );
$$;

-- ── Helper: does the current user have edit access? ─────────

create or replace function public.can_edit_trip(p_trip_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select
    public.is_trip_owner(p_trip_id)
    or exists (
      select 1 from public.trip_shares ts
      join auth.users u on u.email = ts.shared_with_email
      where ts.trip_id = p_trip_id
        and u.id = auth.uid()
        and ts.permission = 'edit'
    );
$$;

-- ── RLS Policies: trips ──────────────────────────────────────

-- Owner: full CRUD
create policy "trips: owner select"
  on public.trips for select
  using (user_id = auth.uid());

create policy "trips: owner insert"
  on public.trips for insert
  with check (user_id = auth.uid());

create policy "trips: owner update"
  on public.trips for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "trips: owner delete"
  on public.trips for delete
  using (user_id = auth.uid());

-- Shared users: select only
create policy "trips: shared view"
  on public.trips for select
  using (public.can_view_trip(id) and user_id <> auth.uid());

-- ── RLS Policies: events ─────────────────────────────────────

-- View: owner or shared user
create policy "events: view"
  on public.events for select
  using (public.can_view_trip(trip_id));

-- Insert / Update / Delete: owner or edit-permission shared user
create policy "events: insert"
  on public.events for insert
  with check (public.can_edit_trip(trip_id));

create policy "events: update"
  on public.events for update
  using (public.can_edit_trip(trip_id))
  with check (public.can_edit_trip(trip_id));

create policy "events: delete"
  on public.events for delete
  using (public.can_edit_trip(trip_id));

-- ── RLS Policies: trip_shares ────────────────────────────────

-- Only the trip owner can view, add, or remove shares
create policy "trip_shares: owner select"
  on public.trip_shares for select
  using (public.is_trip_owner(trip_id));

create policy "trip_shares: owner insert"
  on public.trip_shares for insert
  with check (public.is_trip_owner(trip_id));

create policy "trip_shares: owner update"
  on public.trip_shares for update
  using (public.is_trip_owner(trip_id))
  with check (public.is_trip_owner(trip_id));

create policy "trip_shares: owner delete"
  on public.trip_shares for delete
  using (public.is_trip_owner(trip_id));
