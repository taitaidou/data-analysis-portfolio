# 零售项目查询结果

本目录保存用户提供的六份 CSV 查询结果，保留原文件名和表内数据。本次仅整理上传，未重新连接 MySQL 执行查询。

## 文件索引

| 文件 | 数据行数 | 内容 |
| --- | ---: | --- |
| [month on month comparison.csv](processed/month%20on%20month%20comparison.csv) | 48 | 月度销售额及环比增长 |
| [sales.csv](processed/sales.csv) | 48 | 月度销售额、利润及利润率 |
| [state sales.csv](processed/state%20sales.csv) | 59 | 州省与区域销售及利润 |
| [sub return.csv](processed/sub%20return.csv) | 17 | 商品子类别退货订单率 |
| [sub_category.csv](processed/sub_category.csv) | 17 | 商品大类、子类别销售与盈利 |
| [月度季节性分析.csv](processed/%E6%9C%88%E5%BA%A6%E5%AD%A3%E8%8A%82%E6%80%A7%E5%88%86%E6%9E%90.csv) | 12 | 跨年度各自然月平均销售额与利润 |

## 字段与使用说明

- `month on month comparison.csv`：`order_year`、`order_month`、`total_sales`、`sales_mom_growth`。
- `sales.csv`：`order_year`、`order_month`、`total_sales`、`total_profit`、`profit_margin`。
- `state sales.csv`：`state_province`、`region`、`total_sales`、`total_profit`、`profit_margin`、`total_orders`。
- `sub return.csv`：`sub_category`、`total_orders`、`returned_orders`、`return_rate`。
- `sub_category.csv`：`category`、`sub_category`、`total_sales`、`total_profit`、`profit_margin`、`total_quantity`、`total_orders`。
- `月度季节性分析.csv`：`order_month`、`avg_sales`、`avg_profit`。

- 数据来源、币种、导出时间和数据库导入范围尚未提供，结果应与[SQL 及指标说明](../sql/README.md)结合使用。
- 月度数据由 `order_year` 与 `order_month` 共同确定月份；季节性表按自然月汇总，是跨年度月销售额和月利润的平均值，不应作为某个年度的月度明细。
- `profit_margin`、`sales_mom_growth`、`return_rate` 的对应 SQL 已乘以 100；在 Tableau 中设置为百分比前需先核对单位，避免再次放大。
- 子类别退货率以去重订单数为分母；同一订单可能涉及多个子类别，分组订单数不宜直接相加为整体订单数。
- 不同文件的数据粒度不同，不要直接关联所有汇总表；月度销售与环比表若需关联，应同时使用年份和月份。
