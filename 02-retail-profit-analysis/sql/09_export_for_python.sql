-- MySQL 8.0；只读查询，不创建/修改任何表。
-- 前提：orders 已导入且日期已转换；returns_view 已按 08_returns_analysis.sql 创建。
-- 先运行检查查询，再将最后一个 SELECT 单独导出为 orders_for_python.csv。

-- 1. 确认退货标记的实际取值。后面的正向取值白名单为 yes/y/true/1。
-- 若你的实际标记不同，先核对业务含义再调整白名单，不要把所有返回行都视作已退货。
SELECT returned, COUNT(*) AS record_count
FROM returns_view
GROUP BY returned;

-- 2. 检查订单区域是否一致（正常情况下无结果）。
SELECT order_id, COUNT(DISTINCT region) AS regions
FROM orders
GROUP BY order_id
HAVING COUNT(DISTINCT region) > 1;

-- 3. 一个退货源订单同时出现正向和其他标记时，先核对，不要直接继续。
SELECT order_id,
       COUNT(DISTINCT CASE
           WHEN LOWER(TRIM(CAST(returned AS CHAR))) IN ('yes', 'y', 'true', '1') THEN 1
           ELSE 0 END) AS flag_variants
FROM returns_view
GROUP BY order_id
HAVING flag_variants > 1;

-- 4. 导出明细。一行保留一条原始订单商品明细，不对商品明细去重。
-- EXISTS 防止退货表重复 order_id 放大订单明细行数。
-- 假设：退货表中没有匹配的正向记录意味着订单未标记退货。
SELECT
    o.order_id,
    o.order_date,
    o.region,
    o.category,
    o.sub_category,
    o.sales,
    o.profit,
    o.discount,
    o.quantity,
    CASE WHEN EXISTS (
        SELECT 1
        FROM returns_view AS r
        WHERE r.order_id = o.order_id
          AND LOWER(TRIM(CAST(r.returned AS CHAR))) IN ('yes', 'y', 'true', '1')
    ) THEN 1 ELSE 0 END AS is_returned
FROM orders AS o;
