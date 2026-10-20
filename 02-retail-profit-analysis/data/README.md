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
