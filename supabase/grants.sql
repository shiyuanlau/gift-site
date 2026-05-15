-- 显式授权（Data API / supabase-js / PostgREST 用得到的所有表都要 GRANT）
--
-- 背景：Supabase 从 2026-05-30 起新项目建的 public 表默认 *不* 暴露给 Data API，
-- 旧项目从 2026-10-30 起也按这条规则跑。RLS 决定「哪些行能看」，GRANT 决定「能不能调到表」。
-- 现有表的现有权限不会被收回；只有以后新建的表会受影响。这文件是防御性补的，
-- 重跑 schema 时也能直接跑通，建新表时照下方模板写。
--
-- 跑法：Supabase → SQL Editor → 粘贴整个文件 → Run。Idempotent，反复跑没问题。

-- ---------------- products ----------------
grant select on public.products to anon;
grant select, insert, update, delete on public.products to authenticated;
grant all on public.products to service_role;

-- ---------------- admin_users -------------
-- 不给 anon 任何权限（白名单不该被未登录用户看到）
grant select on public.admin_users to authenticated;
grant all on public.admin_users to service_role;

-- ---------------- banks_earn --------------
grant select on public.banks_earn to anon;
grant select, insert, update, delete on public.banks_earn to authenticated;
grant all on public.banks_earn to service_role;


-- ============================================================
-- 模板：以后新建 public.xxx 表时，把下面整段抄到 create table 后
-- ============================================================
-- grant select on public.your_table to anon;                          -- 只读（公开页面用）
-- grant select, insert, update, delete on public.your_table to authenticated;
-- grant all on public.your_table to service_role;
-- alter table public.your_table enable row level security;
-- -- 然后按业务写 RLS policy
