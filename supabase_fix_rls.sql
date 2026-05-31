-- ============================================================
-- RLS 再帰修正パッチ
-- 症状: trips の SELECT が10秒でタイムアウト（無限再帰）
-- 原因: trips のポリシーが can_view_trip()→is_trip_owner()→trips を
--       循環参照していた。
-- 対処: trips のポリシーから関数呼び出しを排除し、各テーブルが
--       「自分自身のポリシーを再評価しない」構成にする。
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

-- ── trips: オーナーのみ（関数を使わない＝再帰しない＝高速） ──
drop policy if exists "trips: owner select" on public.trips;
drop policy if exists "trips: owner insert" on public.trips;
drop policy if exists "trips: owner update" on public.trips;
drop policy if exists "trips: owner delete" on public.trips;
drop policy if exists "trips: shared view"  on public.trips;
drop policy if exists "trips_owner_all"     on public.trips;

create policy "trips_owner_all"
  on public.trips for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ── events: 親 trip のオーナーなら全操作可 ──
-- is_trip_owner は trips を参照するが、trips のポリシーは関数を使わない
-- ため events↔trips 間で再帰しない。
drop policy if exists "events: view"    on public.events;
drop policy if exists "events: insert"  on public.events;
drop policy if exists "events: update"  on public.events;
drop policy if exists "events: delete"  on public.events;
drop policy if exists "events_owner_all" on public.events;

create policy "events_owner_all"
  on public.events for all
  using (public.is_trip_owner(trip_id))
  with check (public.is_trip_owner(trip_id));

-- ── trip_shares: 親 trip のオーナーのみ管理可 ──
drop policy if exists "trip_shares: owner select" on public.trip_shares;
drop policy if exists "trip_shares: owner insert" on public.trip_shares;
drop policy if exists "trip_shares: owner update" on public.trip_shares;
drop policy if exists "trip_shares: owner delete" on public.trip_shares;
drop policy if exists "trip_shares_owner_all"     on public.trip_shares;

create policy "trip_shares_owner_all"
  on public.trip_shares for all
  using (public.is_trip_owner(trip_id))
  with check (public.is_trip_owner(trip_id));
