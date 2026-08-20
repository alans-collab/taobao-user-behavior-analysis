# 淘宝用户行为分析与 Power BI 看板

一个基于淘宝用户行为数据的分析项目，覆盖流量、转化漏斗、留存、复购、RFM 分层和 Power BI 可视化看板。

## 一、项目背景与目标
- 数据来源：阿里天池公开用户行为数据。
- 样本量：本次演示以抽样 1,000,000 条记录为基础，既保留代表性又保证计算效率。
- 目标：完成流量与转化（PV/UV、小时/日活、漏斗）、用户留存与复购分析、RFM 分层与聚类验证、商品与品类分析，并输出可供 Power BI 使用的样本数据、可视化素材和 SQL 查询脚本。

## 项目结构

```text
charts/                  分析生成的 PNG 图表
data/UserBehavior.csv    本地原始数据，不上传 GitHub
data/powerbi_sample.csv  Power BI 使用的 100 万行样本
notebooks/analysis.ipynb 交互式分析 Notebook
powerbi/README.md        Power BI 建模、DAX 和页面说明
scripts/analysis.py      Python 分析脚本
scripts/export_powerbi_sample.py 生成 Power BI 样本
sql/                     漏斗、留存、RFM 和复购 SQL
```

## 二、核心发现
- PV（浏览）：896,106；UV（独立用户）：9,739。
- 转化漏斗：浏览→收藏/加购 转化约 9.32%；收藏/加购→购买 转化约 24.37%；浏览→购买 转化约 2.27%。
- 跳失率（近似）：通过统计当天仅发生一次行为的用户占比给出初步估计（具体数值见 Notebook 输出）。
- 复购：使用购买行为构建复购率与复购周期，用于识别高价值复购用户群体（详见 [sql/03_rfm.sql](sql/03_rfm.sql)、[sql/04_repurchase.sql](sql/04_repurchase.sql)）。

> 以上核心数字基于前 1,000,000 行样本，不能直接代表完整数据集的总体结果。

## 三、详细分析与业务建议

1) 流量与活跃
- 发现：日 PV 与小时分布显示峰值集中在若干时间窗（见 [charts/daily_pv.png](charts/daily_pv.png) 与 [charts/hourly_pv.png](charts/hourly_pv.png)）。
- 建议：在峰值时段（例如晚间高峰）投放更多曝光与优惠消息；在低谷时段尝试精准召回或邮箱推送以提高次日活跃。

2) 漏斗与跳失
- 发现：从浏览到收藏/加购的初始转化仍较低；从收藏/加购到购买的转化相对较高，说明对目标用户的后续激励有效。
- 建议：优化商品详情页与加入购物车流程，减少结算路径摩擦；对已收藏/已加购但未购买人群实施 48 小时内的提醒与限时券策略。

3) 留存与复购
- 发现：Cohort 分析与复购周期给出用户在首单后的留存趋势与常见复购间隔（详见 [notebooks/analysis.ipynb](notebooks/analysis.ipynb)、[sql/02_retention.sql](sql/02_retention.sql) 和 [sql/04_repurchase.sql](sql/04_repurchase.sql)）。
- 建议：对次日/7日/30日低留存的 cohort 施行差异化召回（短期内以优惠券+推送为主，长期以邮件+会员权益为主）。

4) RFM 分层与用户分群
- 发现：基于 Recency/Frequency 的聚类可划分出高价值、流失倾向与新客等用户簇。
- 建议：对高价值用户提供专属权益（积分、定向折扣）；对沉默用户用个性化内容尝试召回；对新客投入首单优惠与引导行为转化。

5) 商品与品类
- 发现：Top 商品列表（[charts/top_items.png](charts/top_items.png)）可用于品类与折扣策略制定；关联购买分析建议用购物篮数据或订单级数据进行 Market Basket 分析（Apriori）。
- 建议：在库存与促销策略中优先考虑高频复购与高客单价商品。

## 四、可视化素材
- 日 PV 趋势：charts/daily_pv.png
- 小时 PV 分布：charts/hourly_pv.png
- 用户行为转化漏斗：charts/funnel.png
- Top20 购买商品：charts/top_items.png

（截图已保存于 `charts/`，用于嵌入 Power BI 或直接放入报告。）

## 五、Power BI 看板构建说明

目标看板页面建议：
- 首页 KPI 概览：PV、UV、日活、转化率（浏览→购买）、复购率
- 流量趋势页：日/周/月 PV 曲线、小时分布热力图
- 漏斗与落差页：漏斗可视化 + 各环节转化率与跳失趋势
- 留存与复购页：Cohort 热力图（首日/7日/30日留存）、复购周期分布直方图
- 用户分层页：RFM 雷达/散点图、各簇指标对比（人均消费、复购率）

数据准备：
1. 推荐方式：运行 `python scripts/export_powerbi_sample.py` 生成 `data/powerbi_sample.csv`，再在 Power BI 中使用“获取数据 → 文本/CSV”导入该文件。
2. 完整数据约 3.67 GB，不建议直接加载到 Power BI，也不会上传到 GitHub。如需完整分析，建议先导入 MySQL 或其他数据库，再让 Power BI 连接聚合视图。
3. Power Query 中将 `timestamp` 转换为 `datetime`、`date` 和 `hour`，并将行为值 `pv/fav/cart/buy` 映射为“浏览/收藏/加购/购买”。详细步骤见 [powerbi/README.md](powerbi/README.md)。

关键 DAX / 可视化建议：
- 计算 PV/UV、漏斗转化率等度量时，直接使用 `powerbi/README.md` 中的 DAX；行为字段的原始值为 `pv`、`fav`、`cart`、`buy`。
- 留存热力图：将 cohort_date 作为行，days_from_first 作为列，显示 DISTINCTCOUNT(user_id) / cohort_size
- 漏斗：Power BI 的 Funnel 可视化直接使用分阶段计数

交互设计：
- 时间切片器（日期范围）、渠道/品类筛选器、RFM 聚类切片器
- 鼠标悬停展示增量数与环比

## 六、交付文件清单
- Notebook：[notebooks/analysis.ipynb](notebooks/analysis.ipynb)
- 可执行脚本：[scripts/analysis.py](scripts/analysis.py)
- Power BI 样本生成：[scripts/export_powerbi_sample.py](scripts/export_powerbi_sample.py)
- SQL：[sql/](sql/)
- 图表静态图片：[charts/](charts/)
- Power BI 说明：[powerbi/README.md](powerbi/README.md)

## 数据说明

原始数据文件 `data/UserBehavior.csv` 约 3.67 GB，已通过 `.gitignore` 排除，不上传至 GitHub。
运行 Python 分析或生成 Power BI 样本前，请将该文件放置到 `data/UserBehavior.csv`。

生成 Power BI 样本：

```powershell
python scripts\export_powerbi_sample.py
```