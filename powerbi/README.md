# Power BI 面板

## 导入数据

先在项目根目录运行：

```powershell
python scripts\export_powerbi_sample.py
```

然后在 Power BI Desktop 中选择 `获取数据 -> 文本/CSV`，导入 `data/powerbi_sample.csv`。

该样本取原始数据前 1,000,000 行。原始 `data/UserBehavior.csv` 约 3.67 GB，不建议直接导入 Power BI，也不应提交到 GitHub。

## Power Query 清洗

CSV 已包含表头。将 `behavior_type` 设置为文本，将 `timestamp` 设置为整数，并添加以下自定义列：

```powerquery
datetime = #datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, [timestamp])
date = Date.From([datetime])
hour = Time.Hour(Time.From([datetime]))
behavior_name = if [behavior_type] = "pv" then "浏览" else if [behavior_type] = "fav" then "收藏" else if [behavior_type] = "cart" then "加购" else if [behavior_type] = "buy" then "购买" else "其他"
```

## 页面设计

### 1. 经营总览

- 卡片：PV、UV、购买数、浏览到购买转化率
- 折线图：`date` 作为横轴，PV 作为值
- 柱状图：`hour` 作为横轴，PV 作为值
- 环形图：`behavior_name` 和行为次数

### 2. 转化漏斗

- 漏斗阶段：浏览、收藏+加购、购买
- 卡片：浏览到收藏/加购、收藏/加购到购买、浏览到购买
- 切片器：日期、小时、category_id

### 3. 商品与用户

- 条形图：购买数 Top 20 商品
- 条形图：购买数 Top 20 品类
- 矩阵：日期与行为类型
- 折线图：每日活跃用户数

## DAX 指标

```DAX
PV = CALCULATE(COUNTROWS(UserBehavior), UserBehavior[behavior_type] = "pv")
UV = CALCULATE(DISTINCTCOUNT(UserBehavior[user_id]), UserBehavior[behavior_type] = "pv")
收藏数 = CALCULATE(COUNTROWS(UserBehavior), UserBehavior[behavior_type] = "fav")
加购数 = CALCULATE(COUNTROWS(UserBehavior), UserBehavior[behavior_type] = "cart")
购买数 = CALCULATE(COUNTROWS(UserBehavior), UserBehavior[behavior_type] = "buy")
浏览到购买转化率 = DIVIDE([购买数], [PV])
浏览到收藏加购转化率 = DIVIDE([收藏数] + [加购数], [PV])
收藏加购到购买转化率 = DIVIDE([购买数], [收藏数] + [加购数])
活跃用户数 = DISTINCTCOUNT(UserBehavior[user_id])
```

## 保存

完成后选择 `文件 -> 另存为`，将文件保存为项目根目录下的 `powerbi/taobao_user_behavior_dashboard.pbix`。