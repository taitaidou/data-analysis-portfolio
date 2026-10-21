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

输入中的空值、非法数值、跨区域订单及不一致的订单退货标记会报错，需要先核对，脚本不会默默填补或删除记录。原始数据目录已在仓库 `.gitignore` 中排除。

## 2. 安装依赖

在项目根目录 `02-retail-profit-analysis` 打开终端：

```powershell
python -m pip install -r python/requirements.txt
```

## 3. 运行折扣分析

```powershell
python python/discount_analysis.py --input data/raw/orders_for_python.csv
```

默认输出到 `outputs/discount/`，也可以用 `--output` 指定目录：

- `discount_summary.csv`：无折扣、低折扣（0~0.2，排除0）、中折扣（大于0.2且不超过0.4）、高折扣（大于0.4）的销售、利润、加权利润率、亏损明细占比。
- `category_discount_summary.csv`、`subcategory_discount_summary.csv`：品类与折扣交叉汇总。
- `tables_region_discount_summary.csv`：Tables 品类按区域与折扣分组；无 Tables 数据时保留空表表头。
- `discount_correlation.json`：全部明细行折扣与明细利润率的 Pearson 相关系数；数据不足或变量恒定时不计算。
- `discount_profit_margin.png`：各折扣区间利润率条形图。
- `discount_margin_scatter.png`：折扣与明细利润率散点图，最多固定随机抽取5,000行用于展示，相关系数使用全部有效明细。

利润率为总利润除以总销售额；明细利润率用于散点和相关性，与加权整体利润率不是同一个指标。折扣和利润相关不代表因果，不将不同品类、地区或订单结构产生的差异解释为折扣效果。

## 4. 运行区域退货分析

```powershell
python python/regional_returns_analysis.py --input data/raw/orders_for_python.csv
```

默认输出到 `outputs/returns/`：

- `overall_returns.json`：整体去重订单数、退货订单数及退货率。
- `region_returns.csv`：区域去重订单数、退货订单数、退货率，以及相对整体的百分点差异。
- `region_subcategory_returns.csv`：区域与子类别交叉分析。
- `west_subcategory_returns.csv`：West 子类别分析；无 West 时保留空表表头。
- `region_return_rate.png`：区域退货率条形图，显示样本量和整体参考线。

同一订单多条明细只计一个订单。跨子类别订单可以分别计入多个子类别，因此子类别计数不可加总为整体订单数。退货标记是订单级，不能说明订单中的每个商品均已退货，也不计算净退款额或真实损失。

所有输出 `return_rate`、`profit_margin`、`loss_line_rate` 均为小数比例，例如 `0.1156` 表示11.56%；`difference_vs_overall_pp` 为百分点差异。与原 SQL 中乘以100的比例表示方式不同，导入 Tableau 前注意区分。

## 5. 验证代码

```powershell
python -m unittest discover -s python -p "test_*.py" -v
```

测试包含折扣边界、加权利润率、订单去重、前导零 ID、异常输入拦截、常量相关性和图表文件生成。测试订单不作为真实项目数据提交或分析结果引用。

## 待补材料

真实订单明细、退货源表覆盖范围及肯定标记含义、数据来源与币种。使用正向退货标记重跑后的结果可能与原先未筛选标记的 SQL 不同，应以口径核对后的实际运行结果更新简历和看板。
