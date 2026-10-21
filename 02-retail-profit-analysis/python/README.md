# Python 折扣分析与区域退货分析

两份脚本读取订单商品明细 CSV，生成汇总 CSV、统计 JSON 和 PNG 图表。

## 1. 从 MySQL 导出输入

运行 [09_export_for_python.sql](../sql/09_export_for_python.sql) 中的检查语句，核对退货标记、订单区域和表结构；然后把最后一个查询的结果单独导出，保存为：

```text
02-retail-profit-analysis/data/raw/orders_for_python.csv
```

保留列名；折扣使用 0~1 比例，例如 `0.2` 表示打八折。退货标记列为数值 `0` 或 `1`。`order_id` 可以重复，因为一个订单可能包含多条商品明细；不要将重复订单 ID 当成重复数据删除。

输入字段：

| 字段 | 含义 | 使用脚本 |
| --- | --- | --- |
| order_id | 订单 ID，按文本读取 | 两者 |
| region | 区域；同一订单应属于一个区域 | 两者 |
| category | 商品大类 | 折扣 |
| sub_category | 商品子类别 | 两者 |
| sales | 明细销售额，当前实现要求大于零 | 折扣 |
| profit | 明细利润，可为负 | 折扣 |
| discount | 折扣比例，0~1 | 折扣 |
| is_returned | 订单级退货标记，0/1 | 区域退货 |
| order_date、quantity | 导出时一并保留，不参与当前脚本计算 | 可选 |

## 2. 运行折扣分析

输出到 `outputs/discount/`：

- `discount_summary.csv`：无折扣、低折扣（0~0.2，排除0）、中折扣（大于0.2且不超过0.4）、高折扣（大于0.4）的销售、利润、加权利润率、亏损明细占比。
- `category_discount_summary.csv`、`subcategory_discount_summary.csv`：品类与折扣交叉汇总。
- `tables_region_discount_summary.csv`：Tables 品类按区域与折扣分组；无 Tables 数据时保留空表表头。
- `discount_correlation.json`：全部明细行折扣与明细利润率的 Pearson 相关系数；数据不足或变量恒定时不计算。
- `discount_profit_margin.png`：各折扣区间利润率条形图。
- `discount_margin_scatter.png`：折扣与明细利润率散点图，最多固定随机抽取5,000行用于展示，相关系数使用全部有效明细。

## 3. 运行区域退货分析

输出到 `outputs/returns/`：

- `overall_returns.json`：整体去重订单数、退货订单数及退货率。
- `region_returns.csv`：区域去重订单数、退货订单数、退货率，以及相对整体的百分点差异。
- `region_subcategory_returns.csv`：区域与子类别交叉分析。
- `west_subcategory_returns.csv`：West 子类别分析；无 West 时保留空表表头。
- `region_return_rate.png`：区域退货率条形图，显示样本量和整体参考线。

