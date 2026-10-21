# 数据与报告指标

## 原始输入

本地存在 `public_health_behavior.csv`，结构核对为96,892行、25列，详见[聚合字段与标签计数](../docs/data_profile.json)。仓库不包含原始健康记录，也不包含同目录个人级预测CSV。

输入文件来源链接、字段字典、许可与统计周期尚未提供。需要复现时，应先取得有权使用的数据，放在 `data/raw/`（已由仓库忽略），按R目录说明运行。

## PPT 指标转录

[model_metrics_from_ppt.csv](reported/model_metrics_from_ppt.csv) 逐项转录自课程PPT第5页指标图片，包含决策树、逻辑回归和KNN。其数值为PPT保留的三位小数，不是本次训练输出，也不是由缺失的原始 `final_model_metrics.csv` 复制而来。

Accuracy、Precision、Recall、F1和AUC均以0~1数值保存。PPT没有给出朴素贝叶斯指标，当前不补造该行。
