# 显式安装依赖；本文件不会读取健康数据或训练模型。
# 未固定历史版本，请同时保存 sessionInfo()。
packages <- c(
  "tidyverse", "caret", "pROC", "rpart", "partykit", "e1071",
  "kknn", "recipes", "themis", "rattle", "RColorBrewer", "gt",
  "shiny", "shinydashboard", "DT"
)
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}
print(sessionInfo())
