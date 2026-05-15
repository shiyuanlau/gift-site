# Supabase SQL

按执行顺序（首次部署）：

1. `schema.sql` — 建 products 表、product-images bucket、宽松 quick-start 策略
2. `hardening.sql` — 建 admin_users 表，把写权限收紧到管理员白名单
3. `cards-needed-migration.sql` — 给老库加 cards_needed 字段（如果是从老版本升上来）
4. `migrate-categories.sql` — 老分类 → 新分类映射（一次性）
5. `product-extras.sql` — 给 products 加 subcategory + images（多图）
6. `product-views.sql` — 给 products 加 view_count + 累计函数
7. `banks-earn-table.sql` — 建 banks_earn 表 + RLS
8. `grants.sql` — 显式 GRANT，所有现有表都补一遍（详见下）

## 关于 Data API 显式 GRANT（2026-05 邮件）

Supabase 从 **2026-05-30** 起新项目建的 public 表默认不暴露给 Data API（supabase-js / REST / GraphQL）。**2026-10-30** 起旧项目（包括这个）也按同规则跑，但**现有表的现有权限不会被收回** — 只影响以后新建的表。

实践要点：
- 以后在 SQL Editor 里建新表时，把 `grants.sql` 里的「模板」部分照抄
- 漏了的话前端会收到 PostgREST 报错 `42501`，错误信息里会直接给出该跑的 GRANT 语句
- RLS = 行可见性；GRANT = 表可访问性。两者都要配，缺一不可
