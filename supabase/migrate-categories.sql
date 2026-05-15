-- 分类迁移脚本
-- 旧分类 → 新分类映射（2026-05 改版）
--
-- 新分类合法值：
--   referral / stroller / playpen / carseat / carrier / earlyedu /
--   toy / chairtable / ride / pet / camping / digital / appliance
--
-- 用法：
--   1) 先跑「步骤 0」看看库里到底有哪些旧分类，按需要调整下面的映射
--   2) 步骤 1～2 都是 idempotent（重复跑不会出错）
--   3) 不会删任何数据，最多把没法映射的商品 is_active 置 false 等你手工分类

-- =============================================================
-- 步骤 0：先看库里现有分类分布
-- =============================================================
-- select category, count(*) as n
-- from public.products
-- group by category
-- order by n desc;


-- =============================================================
-- 步骤 1：把语义接近的老分类直接重命名到新分类
-- =============================================================
update public.products set category = 'earlyedu'
where category in ('study');                  -- 学习工具 → 早教点读

update public.products set category = 'camping'
where category in ('outdoor');                -- 户外产品 → 户外露营

update public.products set category = 'appliance'
where category in ('kitchen');                -- 厨房家居 → 家用电器

update public.products set category = 'stroller'
where category = 'baby';                      -- 母婴用品 → 婴儿推车（最常用子类，错了再改）

-- toy / pet / digital / appliance 老值就在新列表里，无需改


-- =============================================================
-- 步骤 2：剩下没法直接映射的旧分类商品先下架（不删数据）
--          后台登录后重新选个新分类、再上架即可
-- =============================================================
update public.products
set is_active = false
where category not in (
  'referral', 'stroller', 'playpen', 'carseat', 'carrier', 'earlyedu',
  'toy', 'chairtable', 'ride', 'pet', 'camping', 'digital', 'appliance'
);


-- =============================================================
-- 验证
-- =============================================================
-- select category, is_active, count(*) as n
-- from public.products
-- group by category, is_active
-- order by category, is_active;
