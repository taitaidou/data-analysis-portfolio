-- ============================================
-- 06. Region Analysis
-- ============================================

-- 6.1 各地区整体销售与盈利表现
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        SUM(sales) / COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value
FROM orders
GROUP BY region
ORDER BY total_sales DESC;



-- 6.2 各地区销售贡献率
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) /
        SUM(SUM(sales)) OVER () * 100,
        2
    ) AS sales_share
FROM orders
GROUP BY region
ORDER BY total_sales DESC;




-- 6.3 各州/省销售与盈利表现
SELECT
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    state_province,
    region
ORDER BY total_profit ASC;



-- 6.4 亏损州/省
SELECT
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY
    state_province,
    region
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;



-- 6.5 各州/省利润排名
WITH state_profit AS (
    SELECT
        state_province,
        region,
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM orders
    GROUP BY
        state_province,
        region
)

SELECT
    state_province,
    region,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_profit, 2) AS total_profit,

    RANK() OVER (
        ORDER BY total_profit DESC
    ) AS profit_rank

FROM state_profit
ORDER BY profit_rank;