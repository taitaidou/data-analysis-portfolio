-- ============================================
-- 05. Product Analysis
-- ============================================

-- 5.1 商品大类销售与盈利表现
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY category
ORDER BY total_sales DESC;


-- 5.2 商品子类别销售与盈利表现
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    category,
    sub_category
ORDER BY total_sales DESC;


-- 5.3 亏损商品子类别
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY
    category,
    sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;



-- 5.4 Tables 不同折扣水平的盈利情况
SELECT
    discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(*) AS record_count
FROM orders
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;



-- 5.5 Tables 折扣区间盈利分析
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,

    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(*) AS record_count

FROM orders
WHERE sub_category = 'Tables'

GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY MIN(discount);



-- 5.6 Tables 各地区盈利表现
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(*) AS record_count
FROM orders
WHERE sub_category = 'Tables'
GROUP BY region
ORDER BY total_profit ASC;



-- 5.7 Tables 各地区不同折扣水平盈利表现
SELECT
    region,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,

    ROUND(AVG(discount) * 100, 2) AS avg_discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(*) AS record_count

FROM orders
WHERE sub_category = 'Tables'

GROUP BY
    region,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY
    region,
    MIN(discount);