# R 建模代码

`health_analysis_original.R` 来自用户提供的 `Assigment2 501 Health03.R`，仅重命名，内容原样保留。本次未执行R脚本或安装R包，也未重新训练模型。

## 输入与输出

原脚本从当前工作目录读取 `public_health_behavior.csv`，输出目录为当前工作目录下的 `Health03/`。本地检查发现输入CSV为96,892行、25列；仓库仅上传聚合结构说明，不上传健康明细。数据来源、字段字典与使用许可仍需补齐。

在原脚本完成运行且没有中断时，其代码尝试输出：

- `final_model_metrics.csv`
- `final_performance_dashboard.html`
- `decision_tree_story.png`
- `roc_curves_comparison.png`
- `knn_decision_boundary.png`
- `naive_bayes_distributions.png`

这些是代码定义的预期输出，不代表本次已生成或找到对应历史文件。仓库 `data/reported/` 的指标CSV是从PPT转录，文件名明确区分。

## 准备环境

可先在R中执行 `source("R/install_dependencies.R")`。安装过程会从CRAN下载依赖；这不是已锁定的历史环境，请记录实际R版本和 `sessionInfo()`。

为避免把原始数据写入仓库根目录，可将有权使用的CSV放在项目 `data/raw/` 下，然后在项目根目录的R会话中运行：

```r
setwd("data/raw")
source("../../R/health_analysis_original.R")
```

脚本自身也会尝试安装缺失包，且执行完整模型训练和KNN调优。先阅读[评估说明](../docs/evaluation_notes.md)，不要将直接运行原脚本视为已经修复数据泄漏。
