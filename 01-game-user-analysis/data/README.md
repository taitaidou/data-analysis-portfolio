# 游戏分析查询结果

本目录保存用户提供的八份 CSV 汇总结果，表内数据未作修改。本次未连接 BigQuery 重新执行查询。

数据对应 SQL 使用的公开表：`firebase-public-project.analytics_153293282.events_*`。导出时间未提供，查询实际范围和口径以对应 SQL 及下述说明为准。

## 文件索引

| 文件 | 行数 | 内容 | 
| --- | ---: | --- | 
| [version_performance.csv](processed/version_performance.csv) | 34 | 版本表现 | 
| [daily_activity.csv](processed/daily_activity.csv) | 114 | 每日活跃与事件统计 | 
| [rolling_wau.csv](processed/rolling_wau.csv) | 114 | 滚动七日活跃 | 
| [cohort_retention.csv](processed/cohort_retention.csv) | 114 | 按 Cohort 的 D1/D7 留存 | 
| [event_coverage_summary.csv](processed/event_coverage_summary.csv) | 1 | 关键事件覆盖人数及人数比值 | 
| [device_segments.csv](processed/device_segments.csv) | 2 | 设备分群 | 
| [country_segments.csv](processed/country_segments.csv) | 20 | 国家分群 | 
| [activity_segments.csv](processed/activity_segments.csv) | 4 | 活跃频次分群 | 


