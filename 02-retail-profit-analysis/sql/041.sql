-- 4.2 月度销售额与利润趋势
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;
    
    
-- 4.3 月度销售额及环比增长率
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)

SELECT
    order_year,
    order_month,
    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        (
            total_sales
            - LAG(total_sales) OVER (
                ORDER BY order_year, order_month
            )
        )
        /
        LAG(total_sales) OVER (
            ORDER BY order_year, order_month
        )
        * 100,
        2
    ) AS sales_mom_growth

FROM monthly_sales
ORDER BY
    order_year,
    order_month;
    
-- 4.4 月度季节性分析
SELECT
    order_month,
    ROUND(AVG(sales), 2) AS avg_sales,
    ROUND(AVG(profit), 2) AS avg_profit
FROM (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales) AS sales,
        SUM(profit) AS profit
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
) AS monthly_data
GROUP BY order_month
ORDER BY order_month;