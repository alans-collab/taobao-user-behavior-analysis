import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import os

#解决中文乱码
plt.rcParams["font.sans-serif"] = ["SimHei"]
plt.rcParams["axes.unicode_minus"] = False

#读取data下面的csv，抽样100万行
csv_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'UserBehavior.csv')
csv_path = os.path.abspath(csv_path)

if not os.path.exists(csv_path):
    raise FileNotFoundError(f"找不到数据文件: {csv_path}")

print(f"读取数据：{csv_path}")

df = pd.read_csv(csv_path,
                 names=["user_id","item_id","category_id","behavior_type","timestamp"],
                 nrows=1000000)

print(f"读取数据行数：{len(df)}")
# 转换unix时间戳为日期时间
df["datetime"] = pd.to_datetime(df["timestamp"],unit="s")
df["date"] = df["datetime"].dt.date
df["hour"] = df["datetime"].dt.hour
df["weekday"] = df["datetime"].dt.dayofweek

# 去重
pre_len = len(df)
df = df.drop_duplicates()
print(f"去重前/后行数：{pre_len}/{len(df)}")
# 检查缺失值
print("缺失值统计：")
print(df.isnull().sum())

#行为类型映射
# 规范化 behavior_type（部分数据使用字符串如 pv/fav/cart/buy）
df["behavior_type"] = df["behavior_type"].astype(str).str.strip().str.lower()
behavior_map = {
    'pv': "浏览",
    'fav': "收藏",
    'cart': "加购",
    'buy': "购买",
    '1': "浏览",
    '2': "收藏",
    '3': "加购",
    '4': "购买"
}
df["behavior_name"] = df["behavior_type"].map(behavior_map)

# PV 总浏览量
pv = len(df[df["behavior_name"]=="浏览"]) 
# UV 独立用户
uv = df["user_id"].nunique()

collect_cnt = len(df[df["behavior_name"]=="收藏"]) # 收藏
cart_cnt = len(df[df["behavior_name"]=="加购"])    # 加购
buy_cnt = len(df[df["behavior_name"]=="购买"])     # 购买

print(f"PV浏览量：{pv}")
print(f"UV独立用户：{uv}")
print(f"收藏数：{collect_cnt}")
print(f"加购数：{cart_cnt}")
print(f"购买数：{buy_cnt}")

# 漏斗转化率（安全计算以避免除以0）
cart_collect_sum = cart_cnt + collect_cnt

def safe_div(n, d):
    return n / d if d else 0

def format_rate(n, d):
    return f"{n/d:.2%}" if d else "N/A"

view_to_cart_collect = safe_div(cart_collect_sum, pv)
cartcollect_to_buy = safe_div(buy_cnt, cart_collect_sum)
view_to_buy = safe_div(buy_cnt, pv)

print("\n转化率（若为 N/A 表示分母为 0）：")
print(f"- 浏览→收藏/加购：{format_rate(cart_collect_sum, pv)}")
print(f"- 收藏/加购→购买：{format_rate(buy_cnt, cart_collect_sum)}")
print(f"- 浏览→购买：{format_rate(buy_cnt, pv)}")

#绘制漏斗图
funnel_data = pd.DataFrame({
    "stage":["浏览","收藏+加购","购买"],
    "count":[pv, collect_cnt+cart_cnt, buy_cnt]
})

plt.figure(figsize=(8,5))
sns.barplot(data=funnel_data,x="stage",y="count")
plt.title("用户行为转化漏斗")
# 确保 charts 目录存在并保存图片到项目的 charts 文件夹
img_dir = os.path.join(os.path.dirname(__file__), '..', 'charts')
img_dir = os.path.abspath(img_dir)
os.makedirs(img_dir, exist_ok=True)
img_path = os.path.join(img_dir, "funnel.png")
plt.savefig(img_path, dpi=150, bbox_inches="tight")
print(f"已保存图表到: {img_path}")
plt.show()

# 生成日 PV 趋势图
daily = df.groupby('date').agg(pv_total=('behavior_name', lambda x: (x=='浏览').sum()), uv_daily=('user_id', 'nunique')).reset_index()
fig, ax = plt.subplots(figsize=(10,4))
ax.plot(pd.to_datetime(daily['date']), daily['pv_total'], marker='o')
ax.set_title('日 PV 趋势')
ax.set_ylabel('PV')
daily_path = os.path.join(img_dir, 'daily_pv.png')
fig.savefig(daily_path, dpi=150, bbox_inches='tight')
print(f"已保存图表到: {daily_path}")
plt.close(fig)

# 生成小时 PV 分布图
hourly = df.groupby('hour').agg(pv=('behavior_name', lambda x: (x=='浏览').sum())).reindex(range(24), fill_value=0)
fig, ax = plt.subplots(figsize=(10,3))
sns.barplot(x=hourly.index, y=hourly['pv'], ax=ax, color='skyblue')
ax.set_title('小时 PV 分布')
hourly_path = os.path.join(img_dir, 'hourly_pv.png')
fig.savefig(hourly_path, dpi=150, bbox_inches='tight')
print(f"已保存图表到: {hourly_path}")
plt.close(fig)

# 生成 Top 商品图
top_items = df[df['behavior_name']=='购买']['item_id'].value_counts().head(20)
fig = top_items.plot(kind='bar', figsize=(10,4)).get_figure()
top_items_path = os.path.join(img_dir, 'top_items.png')
fig.savefig(top_items_path, dpi=150, bbox_inches='tight')
print(f"已保存图表到: {top_items_path}")
plt.close(fig)
