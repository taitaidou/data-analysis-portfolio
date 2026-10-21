# 电商用户画像与价值分层 
**工具：** Python、Pandas、NumPy、Matplotlib、Seaborn、SciPy

## 项目目标

围绕用户属性、登录活跃、购买频次及消费金额开展画像分析与用户价值分层，展示描述性统计和相关性探索，并为后续运营验证形成候选方向。

## 数据与方法
代码分为以下部分：

1. 数据读取、缺失与重复检查，以及年龄、购买频次和消费金额筛选。
2. 性别、年龄、地域、兴趣和品类偏好画像。
3. 登录间隔直方图、KDE 曲线及邮件订阅群体停留时长对比。
4. 采用登录间隔、购买频次、总消费额完成五分评分与八类用户分层。
5. 对数值字段计算相关性矩阵并绘制热力图。

### 分层指标定义

| 指标 | 实际字段 | 评分规则 |
| --- | --- | --- |
| R 替代指标：登录新近度 | `Last_Login_Days_Ago` | 值越小得分越高，5至1分 |
| F：购买频次 | `Purchase_Frequency` | 值越大得分越高，1至5分 |
| M：总消费额 | `Total_Spending` | 值越大得分越高，1至5分 |

## 结果

| 分层标签 | R分高低 | F分高低 | M分高低 | 原文输出人数 |
| --- | --- | --- | --- | ---: |
| 高价值用户 | 高 | 高 | 高 | 62 |
| 潜力用户 | 高 | 高 | 低 | 93 |
| 深耕用户 | 高 | 低 | 高 | 93 |
| 新用户 | 高 | 低 | 低 | 152 |
| 流失预警用户 | 低 | 高 | 高 | 100 |
| 需召回用户 | 低 | 高 | 低 | 145 |
| 流失高价值用户 | 低 | 低 | 高 | 145 |
| 低价值用户 | 低 | 低 | 低 | 210 |
| 合计 | — | — | — | 1,000 |

## 结果图展示

已上传十张用户提供的结果图，包含用户画像、登录行为、品类偏好、消费对比、RFM 分层与相关性热力图。[查看全部结果图](figures/README.md)。

### RFM 用户价值分层

![RFM 用户价值分层](figures/09_rfm_segments.png)

### 指标相关性热力图

![指标相关性热力图](figures/10_correlation_heatmap.png)

<details>
<summary>展开其他八张画像与行为图</summary>

### 用户性别分布

![用户性别分布](figures/01_gender_distribution.png)

### 用户年龄分布

![用户年龄分布](figures/02_age_distribution.png)

### 用户地域分布

![用户地域分布](figures/03_location_distribution.png)

### 用户兴趣分布

![用户兴趣分布](figures/04_interest_distribution.png)

### 登录间隔分布

![登录间隔分布](figures/05_login_recency_distribution.png)

### 邮件订阅与停留时长对比

![邮件订阅与停留时长对比](figures/06_newsletter_engagement.png)

### 产品品类偏好

![产品品类偏好](figures/07_category_preference.png)

### 不同年龄层平均总消费

![不同年龄层平均总消费](figures/08_age_spending.png)

</details>

图片按原样保存，部分中文显示为方框，详见[图表说明](figures/README.md)；本次仅上传现有图片，没有重新执行 Notebook 或独立复核原始数据。

## 文件与交付

| 文件 | 用途 |
| --- | --- |
| [报告](source/provided_project.txt) | 流程和结果 |
| [代码](notebooks/ecommerce_rfm_source.ipynb) | 9个代码单元 |
| [依赖清单](notebooks/requirements.txt) | 本地准备运行环境 |
| [十张结果图](figures/README.md) | 用户提供的图表原图与分类预览 |

