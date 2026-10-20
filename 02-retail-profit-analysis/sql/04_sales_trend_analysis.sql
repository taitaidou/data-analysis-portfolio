-- ============================================
-- 04. Sales Trend Analysis
-- ============================================

-- 4.1 年度销售额及同比增长率

WITH yearly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY YEAR(order_date)
)

SELECT
    order_year,
    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY order_year))
        / LAG(total_sales) OVER (ORDER BY order_year) * 100,
        2
    ) AS sales_yoy_growth
FROM yearly_sales
ORDER BY order_year;