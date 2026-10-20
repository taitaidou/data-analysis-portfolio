DESCRIBE returns;

SELECT *
FROM returns
LIMIT 10;


SELECT
    COLUMN_NAME,
    HEX(COLUMN_NAME)
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'retail_analysis'
  AND TABLE_NAME = 'returns';
  
  
  
  CREATE TABLE returns_clean AS
SELECT *
FROM returns;
SHOW CREATE TABLE returns;


CREATE VIEW returns_view AS
SELECT
    `﻿Order ID` AS order_id,
    Returned AS returned
FROM returns;



-- 8.1 整体退货订单率
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate
FROM orders AS o
LEFT JOIN returns_view AS r
    ON o.order_id = r.order_id;
    
    
    
    -- 8.2 各商品大类退货率
SELECT
    o.category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate

FROM orders AS o

LEFT JOIN returns_view AS r
    ON o.order_id = r.order_id

GROUP BY o.category

ORDER BY return_rate DESC;


-- 8.3 各商品子类别退货订单占比
SELECT
    o.sub_category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate

FROM orders AS o

LEFT JOIN returns_view AS r
    ON o.order_id = r.order_id

GROUP BY o.sub_category

ORDER BY return_rate DESC;



-- 8.4 各地区退货订单占比
SELECT
    o.region,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate

FROM orders AS o

LEFT JOIN returns_view AS r
    ON o.order_id = r.order_id

GROUP BY o.region

ORDER BY return_rate DESC;


-- 8.5 退货订单对应的销售额与利润
SELECT
    ROUND(SUM(o.sales), 2) AS returned_sales,
    ROUND(SUM(o.profit), 2) AS returned_profit,
    ROUND(
        SUM(o.profit) / SUM(o.sales) * 100,
        2
    ) AS returned_profit_margin
FROM orders AS o
INNER JOIN returns_view AS r
    ON o.order_id = r.order_id;
    
    
    
    
    
    -- 8.6 West 地区各商品子类别退货订单占比
SELECT
    o.sub_category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate

FROM orders AS o

LEFT JOIN returns_view AS r
    ON o.order_id = r.order_id

WHERE o.region = 'West'

GROUP BY o.sub_category

ORDER BY return_rate DESC;