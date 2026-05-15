-- 商品多图 + 子分类
-- 给 products 加两列：subcategory (text) 和 images (jsonb 数组)
-- 老数据的 image_url 会被回填进 images 数组的第一个元素

alter table public.products
add column if not exists subcategory text;

alter table public.products
add column if not exists images jsonb not null default '[]'::jsonb;

-- 回填：把现有 image_url 复制成 images = [image_url]
update public.products
set images = jsonb_build_array(image_url)
where (images is null or images = '[]'::jsonb)
  and image_url is not null
  and image_url <> '';
