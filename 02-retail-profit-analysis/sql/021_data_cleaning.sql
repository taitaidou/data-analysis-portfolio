ALTER TABLE orders
ADD COLUMN order_date_new DATE,
ADD COLUMN ship_date_new DATE;
UPDATE orders
SET
    order_date_new = STR_TO_DATE(order_date, '%Y/%c/%e'),
    ship_date_new = STR_TO_DATE(ship_date, '%Y/%c/%e');
SELECT
    order_date,
    order_date_new,
    ship_date,
    ship_date_new
FROM orders
LIMIT 10;



SELECT
    SUM(order_date_new IS NULL) AS invalid_order_dates,
    SUM(ship_date_new IS NULL) AS invalid_ship_dates
FROM orders;




ALTER TABLE orders
DROP COLUMN order_date,
DROP COLUMN ship_date;
ALTER TABLE orders
CHANGE COLUMN order_date_new order_date DATE,
CHANGE COLUMN ship_date_new ship_date DATE;
DESCRIBE orders;

