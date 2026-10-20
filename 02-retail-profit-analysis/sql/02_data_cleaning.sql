SELECT
    order_date,
    STR_TO_DATE(order_date, '%Y/%c/%e') AS cleaned_order_date,
    ship_date,
    STR_TO_DATE(ship_date, '%Y/%c/%e') AS cleaned_ship_date
FROM orders
LIMIT 10;


SELECT COUNT(*) AS invalid_order_dates
FROM orders
WHERE STR_TO_DATE(order_date, '%Y/%c/%e') IS NULL;


SELECT COUNT(*) AS invalid_ship_dates
FROM orders
WHERE STR_TO_DATE(ship_date, '%Y/%c/%e') IS NULL;