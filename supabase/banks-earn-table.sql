-- 银行积分对照表
-- 后台维护每家银行的"卡数"积分（0-10），earn.html 按积分从高到低展示

create table if not exists public.banks_earn (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  points integer not null default 0 check (points >= 0 and points <= 10),
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Data API 显式授权（参见 grants.sql）
grant select on public.banks_earn to anon;
grant select, insert, update, delete on public.banks_earn to authenticated;
grant all on public.banks_earn to service_role;

create or replace function public.set_banks_earn_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_banks_earn_set_updated_at on public.banks_earn;
create trigger trg_banks_earn_set_updated_at
before update on public.banks_earn
for each row
execute function public.set_banks_earn_updated_at();

alter table public.banks_earn enable row level security;

drop policy if exists "Public read banks earn" on public.banks_earn;
create policy "Public read banks earn"
on public.banks_earn
for select
to anon, authenticated
using (true);

drop policy if exists "Admins manage banks earn" on public.banks_earn;
create policy "Admins manage banks earn"
on public.banks_earn
for all
to authenticated
using (
  exists (
    select 1 from public.admin_users au
    where lower(au.email) = lower(coalesce((select auth.jwt() ->> 'email'), ''))
  )
)
with check (
  exists (
    select 1 from public.admin_users au
    where lower(au.email) = lower(coalesce((select auth.jwt() ->> 'email'), ''))
  )
);

-- 种 6 个常用银行；积分都先给 0，后台填进去
insert into public.banks_earn (name, points, sort_order) values
  ('招商银行', 0, 1),
  ('浦发银行', 0, 2),
  ('中信银行', 0, 3),
  ('兴业银行', 0, 4),
  ('平安银行', 0, 5),
  ('交通银行', 0, 6)
on conflict (name) do nothing;
