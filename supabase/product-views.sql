-- 商品浏览次数
-- 给 products 加 view_count 字段 + 一个 SECURITY DEFINER 函数让 anon 用户也能 +1
-- 这样既能从前台累计，又不用给 anon 开 update 权限

alter table public.products
add column if not exists view_count integer not null default 0;

create or replace function public.increment_product_views(p_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  update public.products
  set view_count = coalesce(view_count, 0) + 1
  where id = p_id
  returning view_count into new_count;

  return coalesce(new_count, 0);
end;
$$;

revoke all on function public.increment_product_views(uuid) from public;
grant execute on function public.increment_product_views(uuid) to anon, authenticated;
