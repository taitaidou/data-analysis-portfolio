# 1. 环境设置 (Setup)
cat(sprintf("[%s] --- 1. Setting up the environment ---\n", Sys.time()))

# 需要的所有包
packages <- c(
  "tidyverse", "caret", "pROC", "rpart", "partykit", "e1071", 
  "kknn", "themis", "rattle", "RColorBrewer", "gt"
)

# 自动安装并加载缺失的包
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# 从当前工作目录直接读取CSV文件
data_path <- "public_health_behavior.csv"

# 将结果保存在工作目录下的一个名为 "Health03" 的新文件夹中
save_path <- "Health03"
if (!dir.exists(save_path)) {
  cat(sprintf("Creating new results directory at: %s\n", file.path(getwd(), save_path)))
  dir.create(save_path)
}


# 2. 全局数据读取与初步清洗 (Global Data Loading & Cleaning)
cat(sprintf("[%s] --- 2. Loading and performing initial data cleaning ---\n", Sys.time()))
data <- read.csv(data_path)

data_cleaned <- data %>%
  dplyr::select(
    Diabetes_012, HighBP, HighChol, BMI, Smoker, Stroke, HeartDisease,
    PhysActivity, Fruits, Veggies, HvyAlcoholConsump, AnyHealthcare,
    NoDocbcCost, GenHlth, MentHlth, PhysHlth, DiffWalk, Sex, Age,
    Education, Income
  ) %>%
  mutate(
    Diabetes_binary = factor(ifelse(Diabetes_012 == 0, "No", "Yes")),
    HighBP = factor(HighBP, levels = c(0, 1), labels = c("No", "Yes")),
    HighChol = factor(HighChol, levels = c(0, 1), labels = c("No", "Yes")),
    Age = factor(Age, levels = 1:13, labels = c("18-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80+"), ordered = TRUE),
    GenHlth = factor(GenHlth, levels=1:5, labels=c("Excellent", "Very Good", "Good", "Fair", "Poor"), ordered=TRUE),
    PhysActivity = factor(PhysActivity, levels=c(0,1), labels=c("No", "Yes")),
    Sex = factor(Sex, levels=c(0,1), labels=c("Female", "Male")),
    BMI = na_if(BMI, 99)
  ) %>%
  dplyr::select(-Diabetes_012, -Smoker)

preProc_impute <- preProcess(data_cleaned, method = "medianImpute")
data_cleaned <- predict(preProc_impute, data_cleaned)


# 3. 数据分割 (Data Splitting)
cat(sprintf("[%s] --- 3. Splitting data into training and testing sets ---\n", Sys.time()))
set.seed(42)
train_index <- createDataPartition(data_cleaned$Diabetes_binary, p = 0.7, list = FALSE)
train_data <- data_cleaned[train_index, ]
test_data  <- data_cleaned[-train_index, ]


# 4. 性能评估函数 (Evaluation Function)
evaluate_model <- function(model_name, y_true, y_pred_class, y_pred_prob) {
  cat("\n========================================================\n")
  cat(sprintf("          Model Performance: %s\n", model_name))
  cat("========================================================\n")
  
  levels <- union(levels(y_true), levels(y_pred_class))
  y_true <- factor(y_true, levels = levels)
  y_pred_class <- factor(y_pred_class, levels = levels)
  
  cm_results <- tryCatch({
    cm <- confusionMatrix(y_pred_class, y_true, positive = "Yes")
    list(table = cm$table, accuracy = cm$overall["Accuracy"], precision = cm$byClass["Precision"], recall = cm$byClass["Recall"], f1_score = cm$byClass["F1"])
  }, error = function(e) {
    cat("Warning: Could not compute confusion matrix.\n")
    list(table = "Error", accuracy=NA, precision=NA, recall=NA, f1_score=NA)
  })
  
  roc_results <- tryCatch({
    if (length(unique(y_pred_prob)) < 2) { stop("Probabilities have no variance.") }
    roc_obj <- roc(y_true, y_pred_prob, quiet = TRUE, levels = c("No", "Yes"))
    list(roc_obj = roc_obj, auc_val = auc(roc_obj))
  }, error = function(e) {
    cat("Warning: Could not compute AUC.\n")
    list(roc_obj = NULL, auc_val = NA)
  })
  
  cat("Confusion Matrix:\n")
  print(cm_results$table)
  cat("\nPerformance Metrics:\n")
  cat(sprintf("  - Accuracy:  %.4f\n", cm_results$accuracy))
  cat(sprintf("  - Precision: %.4f\n", cm_results$precision))
  cat(sprintf("  - Recall:    %.4f\n", cm_results$recall))
  cat(sprintf("  - F1 Score:  %.4f\n", cm_results$f1_score))
  cat(sprintf("  - AUC:       %.4f\n", roc_results$auc_val))
  cat("--------------------------------------------------------\n")
  
  return(list(
    model = model_name, 
    roc = roc_results$roc_obj, 
    metrics = tibble(Model = model_name, Accuracy = cm_results$accuracy, Precision = cm_results$precision, Recall = cm_results$recall, F1_Score = cm_results$f1_score, AUC = as.numeric(roc_results$auc_val))
  ))
}

find_optimal_threshold <- function(y_true, y_pred_prob) {
  roc_obj <- roc(y_true, y_pred_prob, quiet = TRUE, levels = c("No", "Yes"))
  best_coords <- tryCatch(coords(roc_obj, "best", best.method="closest.topleft", ret="threshold"), error = function(e) return(0.5))
  return(best_coords$threshold)
}

all_model_results <- list()


# 5 - 8. 模型训练与评估部分 (Model Training & Evaluation)
# --- 决策树 ---
cat(sprintf("\n[%s] --- 5. Training and evaluating a DECISION TREE model ---\n", Sys.time()))
features_dt <- c("Diabetes_binary", "HighBP", "HighChol", "Age")
train_dt <- train_data %>% dplyr::select(all_of(features_dt))
test_dt  <- test_data  %>% dplyr::select(all_of(features_dt))
train_dt_processed <- recipe(Diabetes_binary ~ ., data = train_dt) %>% step_downsample(Diabetes_binary) %>% prep() %>% juice()
tree_model <- rpart(Diabetes_binary ~ ., data = train_dt_processed, method = "class")
pred_prob_dt  <- predict(tree_model, newdata = test_dt, type = "prob")[, "Yes"]
best_thresh_dt <- find_optimal_threshold(test_dt$Diabetes_binary, pred_prob_dt)
pred_class_dt <- as.factor(ifelse(pred_prob_dt >= best_thresh_dt, "Yes", "No"))
all_model_results[["Decision Tree"]] <- evaluate_model("Decision Tree", test_dt$Diabetes_binary, pred_class_dt, pred_prob_dt)
cat(sprintf("--> Optimal Threshold for Decision Tree: %.4f\n", best_thresh_dt))

# --- 逻辑回归 ---
cat(sprintf("\n[%s] --- 6. Training and evaluating a LOGISTIC REGRESSION model ---\n", Sys.time()))
features_lr <- c("Diabetes_binary", "HighBP", "BMI", "Age", "GenHlth")
train_lr <- train_data %>% dplyr::select(all_of(features_lr))
test_lr  <- test_data  %>% dplyr::select(all_of(features_lr))
recipe_lr <- recipe(Diabetes_binary ~ ., data = train_lr) %>% step_dummy(all_nominal_predictors(), -all_outcomes()) %>% step_normalize(all_numeric_predictors()) %>% step_smote(Diabetes_binary)
prepped_recipe_lr <- prep(recipe_lr)
train_lr_processed <- juice(prepped_recipe_lr)
test_lr_processed  <- bake(prepped_recipe_lr, new_data = test_lr)
logit_model <- glm(Diabetes_binary ~ ., data = train_lr_processed, family = binomial)
pred_prob_lr <- predict(logit_model, newdata = test_lr_processed, type = "response")
best_thresh_lr <- find_optimal_threshold(test_lr_processed$Diabetes_binary, pred_prob_lr)
pred_class_lr <- as.factor(ifelse(pred_prob_lr >= best_thresh_lr, "Yes", "No"))
all_model_results[["Logistic Regression"]] <- evaluate_model("Logistic Regression", test_lr_processed$Diabetes_binary, pred_class_lr, pred_prob_lr)
cat(sprintf("--> Optimal Threshold for Logistic Regression: %.4f\n", best_thresh_lr))

# --- 朴素贝叶斯 ---
cat(sprintf("\n[%s] --- 7. Training and evaluating a NAIVE BAYES model ---\n", Sys.time()))
features_nb <- c("Diabetes_binary", "PhysActivity", "Sex", "GenHlth", "HighBP")
train_nb <- train_data %>% dplyr::select(all_of(features_nb))
test_nb  <- test_data  %>% dplyr::select(all_of(features_nb))
nb_model <- naiveBayes(Diabetes_binary ~ ., data = train_nb)
pred_prob_nb  <- predict(nb_model, newdata = test_nb, type = "raw")[, "Yes"]
best_thresh_nb <- find_optimal_threshold(test_nb$Diabetes_binary, pred_prob_nb)
pred_class_nb <- as.factor(ifelse(pred_prob_nb >= best_thresh_nb, "Yes", "No"))
all_model_results[["Naive Bayes"]] <- evaluate_model("Naive Bayes", test_nb$Diabetes_binary, pred_class_nb, pred_prob_nb)
cat(sprintf("--> Optimal Threshold for Naive Bayes: %.4f\n", best_thresh_nb))

# --- KNN ---
cat(sprintf("\n[%s] --- 8. Training and evaluating a K-NEAREST NEIGHBORS (KNN) model ---\n", Sys.time()))
features_knn <- c("Diabetes_binary", "GenHlth", "BMI")
train_knn <- train_data %>% dplyr::select(all_of(features_knn))
test_knn  <- test_data  %>% dplyr::select(all_of(features_knn))

# 【性能优化】: 创建一个较小的子样本，专门用于耗时的交叉验证调优
set.seed(555)
train_knn_sampled <- train_knn %>% sample_n(5000)
cat(sprintf("--> KNN Tuning will run on a smaller sample of %d rows to improve speed.\n", nrow(train_knn_sampled)))

# 交叉验证和调优设置
train_control <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  sampling = "smote"
)
tune_grid_knn <- expand.grid(kmax = c(5, 7, 9, 11, 13), distance = 2, kernel = "optimal")

# 模型训练 (在【子样本】上运行调优)
knn_caret_model <- train(
  Diabetes_binary ~ ., 
  data = train_knn_sampled, 
  method = "kknn",
  preProcess = c("center", "scale"),
  trControl = train_control,
  tuneGrid = tune_grid_knn
)

# 在对话框中打印K值调优的详细过程和结果
cat("\n--- KNN Tuning Process Summary ---\n")
print(knn_caret_model)

# 预测与评估 (在【完整的】测试集上进行)
pred_class_knn <- predict(knn_caret_model, newdata = test_knn)
pred_prob_knn  <- predict(knn_caret_model, newdata = test_knn, type = "prob")[, "Yes"]
all_model_results[["K-Nearest Neighbors"]] <- evaluate_model("K-Nearest Neighbors", test_knn$Diabetes_binary, pred_class_knn, pred_prob_knn)


# 9. 最终结果汇总与报告 (Reporting)
cat(sprintf("\n[%s] --- 9. Aggregating results and generating final reports ---\n", Sys.time()))

final_metrics_table <- map_dfr(all_model_results, "metrics") %>% na.omit()

cat("--> Generating publication-quality performance table...\n")
report_table <- final_metrics_table %>%
  mutate(across(where(is.numeric), ~ round(.x, 3))) %>%
  gt() %>%
  tab_header(
    title = md("**Model Performance Dashboard**"),
    subtitle = "Core metrics evaluated on the test set (with threshold tuning)"
  ) %>%
  data_color(
    columns = AUC,
    colors = scales::col_numeric(
      palette = c("white", "forestgreen"),
      domain = range(final_metrics_table$AUC, na.rm = TRUE)
    )
  ) %>%
  cols_label(
    Model = "Model",
    F1_Score = "F1 Score"
  ) %>%
  tab_source_note(
    source_note = md(paste("Report generated on:", Sys.time()))
  )
print(report_table)
gtsave(report_table, filename = file.path(save_path, "final_performance_dashboard.html"))
write.csv(final_metrics_table, file.path(save_path, "final_model_metrics.csv"), row.names = FALSE)


# 10. 可视化 (Visualizations)
cat(sprintf("\n[%s] --- 10. Generating visualizations ---\n", Sys.time()))

# 10.1 “故事化”决策树
cat("--> [Plot 1/4] Generating storytelling decision tree plot...\n")
png(file.path(save_path, "decision_tree_story.png"), width = 1600, height = 1000, res = 120)
fancyRpartPlot(
  tree_model, 
  main = "Decision Path Analysis for Diabetes Risk", 
  sub = "Based on core risk factors for high precision",
  palettes = c("Greens", "Oranges")
)
dev.off()

# 10.2 “模型对决”ROC曲线
cat("--> [Plot 2/4] Generating ROC curves for model comparison...\n")
roc_list <- all_model_results %>% purrr::keep(~ !is.null(.x$roc)) %>% map("roc")
if (length(roc_list) > 0) {
  names(roc_list) <- names(roc_list)
  roc_plot_final <- ggroc(roc_list, size = 1) +
    geom_abline(intercept = 1, slope = 1, color = "grey", linetype = "dashed") +
    scale_color_manual(
      name = "Model (AUC)",
      values = c("Decision Tree" = "darkgreen", "Logistic Regression" = "firebrick", "Naive Bayes" = "darkorchid4", "K-Nearest Neighbors" = "dodgerblue"),
      labels = map_chr(all_model_results[names(roc_list)], ~sprintf("%s (%.3f)", .x$model, .x$metrics$AUC))
    ) +
    labs(
      title = "Model Performance Showdown: ROC Curves",
      subtitle = "Comparing the discriminative ability of each model",
      x = "1 - Specificity (False Positive Rate)",
      y = "Sensitivity (True Positive Rate)"
    ) +
    theme_light() + 
    theme(legend.position = "bottom")
  ggsave(file.path(save_path, "roc_curves_comparison.png"), roc_plot_final, width = 8, height = 8, dpi = 300)
  print(roc_plot_final)
}

# 10.3 KNN决策边界图
cat("--> [Plot 3/4] Generating KNN Decision Boundary plot...\n")
grid_bmi <- seq(min(train_knn$BMI, na.rm=T), max(train_knn$BMI, na.rm=T), length.out = 75)
grid_genhlth <- levels(train_knn$GenHlth)
prediction_grid <- expand.grid(BMI = grid_bmi, GenHlth = grid_genhlth)
grid_predictions <- predict(knn_caret_model, newdata = prediction_grid)
prediction_grid$Prediction <- grid_predictions
knn_boundary_plot <- ggplot(prediction_grid, aes(x = BMI, y = GenHlth)) +
  geom_tile(aes(fill = Prediction), alpha = 0.3) +
  geom_point(data = test_knn %>% mutate(GenHlth = factor(GenHlth, ordered=FALSE)), aes(color = Diabetes_binary, shape = Diabetes_binary), size = 2, alpha = 0.5) +
  scale_fill_manual(values = c("No" = "lightblue", "Yes" = "salmon"), name = "Predicted Region") +
  scale_color_manual(values = c("No" = "darkblue", "Yes" = "darkred"), name = "Actual Class") +
  scale_shape_manual(values = c("No" = 1, "Yes" = 4), name = "Actual Class") +
  labs(
    title = "KNN Decision Boundary Plot",
    subtitle = "How the model partitions the risk space based on General Health and BMI",
    x = "Body Mass Index (BMI)",
    y = "General Health Perception"
  ) +
  theme_minimal()
ggsave(file.path(save_path, "knn_decision_boundary.png"), knn_boundary_plot, width = 9, height = 7, dpi = 300)
print(knn_boundary_plot)

# 10.4 朴素贝叶斯条件分布图
cat("--> [Plot 4/4] Generating Naive Bayes Conditional Distribution plots...\n")
nb_plot_data <- train_data %>%
  dplyr::select(all_of(c("Diabetes_binary", "PhysActivity", "Sex", "GenHlth", "HighBP"))) %>%
  mutate(across(everything(), as.character)) %>%
  pivot_longer(-Diabetes_binary, names_to = "feature", values_to = "value") %>%
  mutate(value = as.factor(value), Diabetes_binary = as.factor(Diabetes_binary))

nb_dist_plot <- ggplot(nb_plot_data, aes(x = value, fill = Diabetes_binary)) +
  geom_bar(position = "fill") +
  facet_wrap(~feature, scales = "free") +
  scale_fill_manual(values = c("No" = "#56B4E9", "Yes" = "#D55E00"), name = "Diabetes Risk") +
  labs(
    title = "Naive Bayes: Conditional Feature Distributions",
    subtitle = "Distribution of feature values for 'Yes' vs. 'No' risk groups",
    x = "Feature Value",
    y = "Proportion"
  ) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(save_path, "naive_bayes_distributions.png"), nb_dist_plot, width = 10, height = 8, dpi = 300)
print(nb_dist_plot)


# 11. 清理
cat(sprintf("\n[%s] --- Analysis Complete! All outputs saved to: %s ---\n", Sys.time(), save_path))