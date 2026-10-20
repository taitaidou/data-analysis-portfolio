-- ============================================
-- 07. Discount & Profit Analysis
-- ============================================

-- 7.1 不同折扣水平的销售与盈利表现
SELECT
    discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin,
    COUNT(*) AS record_count
FROM orders
GROUP BY discount
ORDER BY discount;



-- 7.2 不同折扣区间的盈利表现
SELECT
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

GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY MIN(discount);




-- 7.3 各折扣区间亏损记录占比
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,

    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN profit < 0 THEN 1
            ELSE 0
        END
    ) AS loss_records,

    ROUND(
        SUM(
            CASE
                WHEN profit < 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS loss_rate

FROM orders

GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY MIN(discount);




-- 7.4 各商品大类 × 折扣区间盈利表现
SELECT
    category,

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

GROUP BY
    category,
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY
    category,
    MIN(discount);