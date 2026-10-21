# 董珂鑫｜数据分析作品集

数据科学硕士在读，关注用户行为分析、经营分析与数据可视化。

## 项目导航

| 项目 | 分析主题 | 工具 | 项目说明 |
| --- | --- | --- | --- |
| 游戏 APP 用户活跃与留存分析 | 活跃指标、Cohort 留存、关键事件、用户分层 | BigQuery SQL、Tableau | [查看项目](01-game-user-analysis/README.md) |
| 零售企业销售与利润分析 | 经营指标、品类亏损、折扣与利润、区域退货 | MySQL、Python、Tableau | [查看项目](02-retail-profit-analysis/README.md) |
| 电商用户画像与价值分层（来源项目学习整理） | 用户画像、登录新近度分层、相关性探索 | Python、Pandas、Matplotlib | [查看项目](03-ecommerce-rfm-analysis/README.md) |
| 公共健康行为数据糖尿病风险预测 | 数据预处理、分类模型比较、交互展示 | R、Shiny | [查看项目](04-diabetes-risk-prediction/README.md) |

## 材料状态

游戏项目已提供七份 SQL、八份查询汇总 CSV、两张仪表板预览截图和 Tableau Public 链接；[查看游戏可视化](01-game-user-analysis/tableau/README.md)。零售项目已提供 12 份 SQL（含明细导出）、6 份查询结果、Python 分析脚本与测试、Tableau Public 链接和看板截图；[查看零售可视化](02-retail-profit-analysis/tableau/README.md)。电商项目已导入和鲸来源材料、署名说明与9个代码单元的整理 Notebook；原始数据与独立复现结果待补。建模项目材料将随整理补充。现有留存和事件覆盖查询的口径边界见游戏项目的数据与 SQL 说明，业务效果尚未验证。

## 文件组织

每个项目按实际材料补充以下目录，无相关材料时不创建空文件：

- `data/`：可公开的样例、汇总数据及来源说明。
- `sql/`：清洗与指标计算 SQL。
- `notebooks/` 或 `R/`：实际运行的分析代码。
- `docs/`：指标口径、方法说明与分析报告。
- `tableau/`、`figures/` 或 `app/`：实际完成的看板、图表或 Shiny 应用。

只提交有权公开的数据。原始大数据通过来源链接与获取说明提供；不上传账号凭证、个人敏感信息或未经检查的打包数据。
