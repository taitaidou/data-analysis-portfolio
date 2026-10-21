# 加载必要的包
library(shiny)
library(shinydashboard)
library(tidyverse)
library(caret)
library(rpart)
library(partykit)
library(e1071)
library(kknn)
library(themis)
library(RColorBrewer)
library(gt)

# 定义UI
ui <- dashboardPage(
  dashboardHeader(title = "Diabetes Prediction System"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Upload", tabName = "upload", icon = icon("upload")),
      menuItem("Prediction Results", tabName = "results", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    tabItems(
      # 数据上传标签页 (Data Upload Tab)
      tabItem(tabName = "upload",
              fluidRow(
                box(width = 12, title = "Upload Data", status = "primary", solidHeader = TRUE,
                    fileInput("file1", "Select CSV File",
                              accept = c(
                                "text/csv",
                                "text/comma-separated-values,text/plain",
                                ".csv")
                    ),
                    tags$hr(),
                    checkboxInput("header", "File Contains Header Row", TRUE),
                    radioButtons("sep", "Separator",
                                 choices = c(Comma = ",",
                                             Semicolon = ";",
                                             Tab = "\t"),
                                 selected = ","),
                    actionButton("upload", "Upload & Preprocess Data", class = "btn-primary")
                ),
                box(width = 12, title = "Data Preview", status = "info", solidHeader = TRUE,
                    tableOutput("preview")
                )
              )
      ),
      # 预测结果标签页 (Prediction Results Tab - 移除了 Metrics 和 ROC Curve)
      tabItem(tabName = "results",
              fluidRow(
                box(width = 12, title = "Select Prediction Model", status = "warning", solidHeader = TRUE,
                    selectInput("model", "Select Model:",
                                choices = c("Decision Tree", "Logistic Regression", 
                                            "Naive Bayes", "K-Nearest Neighbors"),
                                selected = "Decision Tree"),
                    actionButton("predict", "Run Prediction", class = "btn-info")
                ),
                box(width = 12, title = "Prediction Results", status = "success", solidHeader = TRUE,
                    downloadButton("downloadResults", "Download Prediction Results"),
                    tags$hr(),
                    DT::dataTableOutput("predictions")
                )
              )
      )
    )
  )
)

# 定义服务器逻辑 (Server Logic - 保持不变，但移除了 Metrics 和 ROC 相关计算)
server <- function(input, output, session) {
  # 反应值存储数据
  raw_data <- reactiveVal(NULL)
  preprocessed_data <- reactiveVal(NULL)
  predictions <- reactiveVal(NULL)
  
  # 加载预训练模型
  models <- reactiveValues(
    `Decision Tree` = NULL,
    `Logistic Regression` = NULL,
    `Naive Bayes` = NULL,
    `K-Nearest Neighbors` = NULL
  )
  
  # 模型特征定义
  model_features <- reactiveValues(
    `Decision Tree` = c("HighBP", "HighChol", "Age"),
    `Logistic Regression` = c("HighBP", "BMI", "Age", "GenHlth"),
    `Naive Bayes` = c("PhysActivity", "Sex", "GenHlth", "HighBP"),
    `K-Nearest Neighbors` = c("GenHlth", "BMI")
  )
  
  # 在应用启动时加载模型
  observe({
    tryCatch({
      models$`Decision Tree` <- readRDS("model_decision_tree.rds")
      models$`Logistic Regression` <- readRDS("model_logistic_regression.rds")
      models$`Naive Bayes` <- readRDS("model_naive_bayes.rds")
      models$`K-Nearest Neighbors` <- readRDS("model_k-nearest_neighbors.rds")
    }, error = function(e) {
      showNotification("Failed to load pre-trained models. Please ensure model files exist.", type = "error")
    })
  })
  
  # 文件上传和处理
  observeEvent(input$upload, {
    req(input$file1)
    
    tryCatch({
      # 读取数据
      df <- read.csv(input$file1$datapath,
                     header = input$header,
                     sep = input$sep)
      raw_data(df)
      
      # 预处理数据（使用与训练时相同的步骤）
      preprocessed <- df %>%
        dplyr::select(
          HighBP, HighChol, BMI, HeartDisease, PhysActivity, 
          GenHlth, MentHlth, PhysHlth, DiffWalk, Sex, Age,
          Education, Income
        ) %>%
        mutate(
          HighBP = factor(HighBP, levels = c(0, 1), labels = c("No", "Yes")),
          HighChol = factor(HighChol, levels = c(0, 1), labels = c("No", "Yes")),
          Age = factor(Age, levels = 1:13, 
                       labels = c("18-24", "25-29", "30-34", "35-39", "40-44", 
                                  "45-49", "50-54", "55-59", "60-64", "65-69", 
                                  "70-74", "75-79", "80+"), ordered = TRUE),
          GenHlth = factor(GenHlth, levels=1:5, 
                           labels=c("Excellent", "Very Good", "Good", "Fair", "Poor"), 
                           ordered=TRUE),
          PhysActivity = factor(PhysActivity, levels=c(0,1), labels=c("No", "Yes")),
          Sex = factor(Sex, levels=c(0,1), labels=c("Female", "Male")),
          BMI = na_if(BMI, 99)
        )
      
      # 处理缺失值
      preProc_impute <- preProcess(preprocessed, method = "medianImpute")
      preprocessed <- predict(preProc_impute, preprocessed)
      
      preprocessed_data(preprocessed)
      
      showNotification("Data preprocessing completed", type = "message")
    }, error = function(e) {
      showNotification(paste("Data processing error:", e$message), type = "error")
    })
  })
  
  # 数据预览
  output$preview <- renderTable({
    req(raw_data())
    head(raw_data())
  })
  
  # 运行预测
  observeEvent(input$predict, {
    req(preprocessed_data(), models[[input$model]])
    
    data <- preprocessed_data()
    model <- models[[input$model]]
    model_name <- input$model
    features <- model_features[[model_name]]
    
    tryCatch({
      # 根据模型类型进行预测
      if (model_name == "Decision Tree") {
        # 决策树需要特定的特征
        features <- c("HighBP", "HighChol", "Age")
        test_data <- data %>% dplyr::select(all_of(features))
        
        # 预测概率和类别
        pred_prob <- predict(model, newdata = test_data, type = "prob")[, "Yes"]
        best_thresh <- 0.5 # 使用默认阈值，因为无法访问原始训练数据的最佳阈值
        pred_class <- as.factor(ifelse(pred_prob >= best_thresh, "Yes", "No"))
        
      } else if (model_name == "Logistic Regression") {
        # 逻辑回归需要特定的特征和预处理
        features <- c("HighBP", "BMI", "Age", "GenHlth")
        test_data <- data %>% dplyr::select(all_of(features))
        
        # 创建配方（简化版，不包含SMOTE）
        recipe_lr <- recipe(~ ., data = test_data) %>% 
          step_dummy(all_nominal_predictors()) %>% 
          step_normalize(all_numeric_predictors())
        
        prepped_recipe <- prep(recipe_lr)
        test_processed <- bake(prepped_recipe, new_data = test_data)
        
        # 预测
        pred_prob <- predict(model, newdata = test_processed, type = "response")
        best_thresh <- 0.5 # 使用默认阈值
        pred_class <- as.factor(ifelse(pred_prob >= best_thresh, "Yes", "No"))
        
      } else if (model_name == "Naive Bayes") {
        # 朴素贝叶斯需要特定的特征
        features <- c("PhysActivity", "Sex", "GenHlth", "HighBP")
        test_data <- data %>% dplyr::select(all_of(features))
        
        # 预测
        pred_prob <- predict(model, newdata = test_data, type = "raw")[, "Yes"]
        best_thresh <- 0.5 # 使用默认阈值
        pred_class <- as.factor(ifelse(pred_prob >= best_thresh, "Yes", "No"))
        
      }
      else if (model_name == "K-Nearest Neighbors") {
        # 定义特征（必须与训练时完全一致）
        features <- c("GenHlth", "BMI")  # GenHlth 是分类变量，BMI 是数值变量
        
        # 提取测试数据
        test_data <- data %>% dplyr::select(all_of(features))
        
        # 创建预处理配方（仅标准化数值变量，不转换分类变量）
        recipe_knn <- recipe(~ ., data = test_data) %>% 
          step_normalize(all_numeric_predictors())  # 仅标准化 BMI
        
        
        prepped_recipe <- prep(recipe_knn)
        test_processed <- bake(prepped_recipe, new_data = test_data)
        
        # 预测
        pred_prob <- predict(model, newdata = test_processed, type = "prob")[, "Yes"]
        best_thresh <- 0.5 # 使用默认阈值
        pred_class <- as.factor(ifelse(pred_prob >= best_thresh, "Yes", "No"))
        
      }
      
      # 创建结果数据框
      results <- data %>%
        mutate(
          Diabetes_Prediction_Probability = pred_prob,
          Diabetes_Prediction = pred_class,
          Diabetes_Prediction = factor(Diabetes_Prediction, levels = c("No", "Yes"))
        )
      
      # 保存结果
      predictions(results)
      
      showNotification("Prediction completed", type = "message")
    }, error = function(e) {
      showNotification(paste("Prediction error:", e$message), type = "error")
    })
  })
  
  # 显示预测结果
  output$predictions <- DT::renderDataTable({
    req(predictions())
    predictions() %>% 
      select(Diabetes_Prediction, Diabetes_Prediction_Probability, everything())
  }, options = list(scrollX = TRUE))
  
  # 下载预测结果
  output$downloadResults <- downloadHandler(
    filename = function() {
      paste("diabetes_predictions_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(predictions(), file, row.names = FALSE)
    }
  )
}

# 运行应用
shinyApp(ui, server)