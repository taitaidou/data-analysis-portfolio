# 零售经营分析 SQL

本目录保存用户提供的 11 份 MySQL SQL 文件，保留原文件名与查询内容；另新增 1 份用于 Python 输入准备的只读明细导出查询。本次仅整理上传，未连接数据库或执行任何 SQL，未验证结果数字。

## 文件索引

| 文件 | 内容 |
| --- | --- |
| `02_data_cleaning.sql` | 原始日期字段解析预览及无效日期检查 |
| `02_检查异常.sql` | 销售、数量、折扣、利润范围与发货日期检查 |
| `021_data_cleaning.sql` | 添加 DATE 列、转换日期、检查结果并替换原日期列 |
| `03_sales_overview.sql` | 销售额、利润、利润率、去重订单与客户数、客单价和年度表现 |
| `04_sales_trend_analysis.sql` | 年度销售额及同比增长率 |
| `041.sql` | 月度销售与利润、相邻观测月份环比、季节性汇总 |
| `05_product_analysis.sql` | 大类、子类别及亏损分析；Tables 折扣与地区交叉分析 |
| `06. Region Analysis.sql` | 区域、州省销售与利润、销售贡献及利润排名 |
| `061_region_analysis.sql` | 区域负责人信息与经营表现关联 |
| `07_discount_profit_analysis.sql` | 折扣区间盈利、亏损记录占比及品类交叉分析 |
| `08_returns_analysis.sql` | 退货表结构检查、视图创建、退货订单率和退货订单对应销售利润 |
| `09_export_for_python.sql` | 检查退货标记、订单区域及冲突记录，并导出带订单级 is_returned 的明细 |

## Python 分析输入

先核对 `returns_view.returned` 的实际取值，最后一个 SELECT 单独导出为 `orders_for_python.csv`。导出用 EXISTS 避免退货表重复键放大明细；未匹配到正向退货记录时标为0，需先确认退货源表覆盖范围。见 [Python 使用说明](../python/README.md)。新增查询不创建或修改数据库对象，依赖已存在的 `orders` 和 `returns_view`。
