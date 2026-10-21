# Shiny 应用原型

`app.R` 从用户项目同目录整理，原样保留。包含CSV上传、预览、模型选择、概率/类别预测以及结果CSV下载界面。

代码需要以下文件位于应用工作目录：

```text
model_decision_tree.rds
model_logistic_regression.rds
model_naive_bayes.rds
model_k-nearest_neighbors.rds
```
准备完整工件并验证预处理一致性后，可在项目根目录运行：

```r
shiny::runApp("app")
```

历史应用地址：https://myapp1234.shinyapps.io/myshiny/

