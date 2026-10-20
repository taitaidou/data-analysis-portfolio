-- 2.7 核心数值字段范围检查
SELECT
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    MIN(profit) AS min_profit,
    MAX(profit) AS max_profit
FROM orders;




SELECT
    SUM(sales <= 0) AS invalid_sales,
    SUM(quantity <= 0) AS invalid_quantity,
    SUM(discount < 0 OR discount > 1) AS invalid_discount
FROM orders;



-- 2.9 检查发货日期是否早于下单日期
SELECT COUNT(*) AS invalid_ship_dates
FROM orders
WHERE ship_date < order_date;