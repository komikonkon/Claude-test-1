-- ============================================================
-- events に開始/終了時刻カラムを追加（カテゴリ→実時刻への移行）
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run。
-- ============================================================

alter table public.events add column if not exists start_time text not null default '';
alter table public.events add column if not exists end_time   text not null default '';

-- 旧カテゴリ(time列: 午前/午後/夜)は今後使わない。残しておいても害はないが
-- 不要なら下記コメントを外して削除してよい。
-- alter table public.events drop column if exists time;
