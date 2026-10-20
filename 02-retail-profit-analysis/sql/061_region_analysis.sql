SELECT DATABASE();

DESCRIBE retail_analysis.people;

SELECT *
FROM retail_analysis.people;




SELECT
    o.region,
    p.regional_manager,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS profit_margin
FROM retail_analysis.orders AS o
LEFT JOIN retail_analysis.people AS p
    ON o.region = p.region
GROUP BY
    o.region,
    p.regional_manager
ORDER BY total_sales DESC;