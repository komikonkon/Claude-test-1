-- ============================================================
-- 食事スロットを複数選択可能にする
-- これまで (trip_id, date, meal_slot) にユニーク制約があり1スロット
-- 1件しか登録できなかった。制約を外して複数件登録できるようにする。
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

alter table public.meal_assignments
  drop constraint if exists meal_assignments_trip_id_date_meal_slot_key;
