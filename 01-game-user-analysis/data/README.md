# 游戏分析查询结果

本目录保存用户提供的八份 CSV 汇总结果，按内容重命名，表内数据未作修改。本次未连接 BigQuery 重新执行查询。

数据对应 SQL 使用的公开表：`firebase-public-project.analytics_153293282.events_*`。导出时间未提供，查询实际范围和口径以对应 SQL 及下述说明为准。

## 文件索引

| 文件 | 行数 | 内容 | 原始文件名 |
| --- | ---: | --- | --- |
| [version_performance.csv](processed/version_performance.csv) | 34 | 版本表现 | `job_A6_MWxXdlcc6tkwSDZUm53bxQvrT.csv` |
| [daily_activity.csv](processed/daily_activity.csv) | 114 | 每日活跃与事件统计 | `job_JKyI1f5ATVQBQLNuBqvIia2bEVMo.csv` |
| [rolling_wau.csv](processed/rolling_wau.csv) | 114 | 滚动七日活跃 | `job_sXk-UM7lAGVoKVHdaCPXT1pgZHCk.csv` |
| [cohort_retention.csv](processed/cohort_retention.csv) | 114 | 按 Cohort 的 D1/D7 留存 | `job_J6MlY41r84d6umQrDa-ubca7nrs5.csv` |
| [event_coverage_summary.csv](processed/event_coverage_summary.csv) | 1 | 关键事件覆盖人数及人数比值 | `job_6bdsBLGmDBdQUXAwF4hVuTyQlPCs.csv` |
| [device_segments.csv](processed/device_segments.csv) | 2 | 设备分群 | `script_job_c8dccbe23586ca4939889e7eea7d9c2a_0.csv` |
| [country_segments.csv](processed/country_segments.csv) | 20 | 国家分群 | `script_job_b853b5237fd8d07a696aa9ce2e6e4a6a_1.csv` |
| [activity_segments.csv](processed/activity_segments.csv) | 4 | 活跃频次分群 | `script_job_57c4e5f9b5fcb3c21de2686b8b696fa3_2.csv` |

## 指标与使用说明

- `cohort_retention.csv` 的 `d1_retention`、`d7_retention` 为小数比例；Tableau 可直接设置为百分比显示。当前对应 SQL 未排除观察期不足的 Cohort，且新用户按数据范围内首次出现日期定义，完善口径后应重新导出。
- `event_coverage_summary.csv` 中三个 `*_rate` 字段使用百分数数值，例如 `34.61` 代表 `34.61%`，不是 `0.3461`。如在 Tableau 使用百分比格式，应先除以 100。已上传 SQL 输出的是小数比例，这与该 CSV 表示方式不同；转换过程尚未提供。
- 当前已上传漏斗 SQL 分别统计各事件覆盖的去重用户，未验证事件先后顺序或同一批用户逐步转化，因此该结果命名为事件覆盖汇总，不作为严格时序漏斗。
- 设备分群有已提供 SQL；国家和活跃频次结果表已提供，但对应查询及活跃分层阈值尚未提供，后续补齐以便复现。
- 版本、设备、国家的去重用户数可能存在跨组重复，不应直接加总为项目总用户数。
- 各结果表粒度不同。在 Tableau 中建议分别使用；若关联 DAU 和 WAU，可按日期建立关系。不要将不同维度汇总表直接拼接后重复汇总。

## 文件完整性

SHA-256 用于与用户提供文件核对，重命名不改变本地复制文件的字节内容。

| 文件 | SHA-256 |
| --- | --- |
| `version_performance.csv` | `ee6308403620e71ad0685e82b003b07235113d613215da15a11b47cc5f32de0e` |
| `daily_activity.csv` | `c3c6e859ef1e47c45ac36df5ed26c74142cf34eb68f18ea736c4fb98a6e1a7c5` |
| `rolling_wau.csv` | `871d816d8f587ee631119ad846ed21f15cdde4b99cad3fd7a423f98b3d62aba8` |
| `cohort_retention.csv` | `8a7c7ad427395e1004a973c3adcfc5b8ef1aaa03aa1a474c397f61585a449174` |
| `event_coverage_summary.csv` | `5f183215061321de5bf25ccc5ae9433ad65e7bfa1b3fd81cad204cece02ce2d7` |
| `device_segments.csv` | `1d295df49e53c9dbc06e2e5680ceed9f1215dcc396dd965d73141b064ae4913f` |
| `country_segments.csv` | `32a86ee4457382d1b17d189eede0ca5c9662bafbea54e0be4bc7c94de2f35fe7` |
| `activity_segments.csv` | `8deff1dc1761b38971b3f051bc63de8c7dcd1547e2a575c87f2f8871b0f31393` |
