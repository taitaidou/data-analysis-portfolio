
-- 3.1 核心经营指标
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders;



-- 3.2 平均客单价
SELECT
    ROUND(
        SUM(sales) / COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value
FROM orders;

-- 3.3 平均每单利润
SELECT
    ROUND(
        SUM(profit) / COUNT(DISTINCT order_id),
        2
    ) AS avg_profit_per_order
FROM orders;




-- 3.4 各年度销售与利润表现
SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;