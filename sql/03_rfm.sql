-- 03_rfm.sql
-- RFM 分析示例（需在 MySQL 中有订单/购买表），这里假设 user_behavior 中 behavior_type=4 为购买，且 item_id、timestamp 可用

WITH orders AS (
  SELECT user_id, FROM_UNIXTIME(timestamp) AS order_dt
  FROM user_behavior
  WHERE behavior_type = 4
),
rfm AS (
  SELECT
    user_id,
    MAX(order_dt) AS last_order_dt,
    COUNT(*) AS frequency,
    DATEDIFF(CURDATE(), DATE(MAX(order_dt))) AS recency
  FROM orders
  GROUP BY user_id
)
SELECT *,
  NTILE(5) OVER (ORDER BY recency) AS r_rank,
  NTILE(5) OVER (ORDER BY frequency DESC) AS f_rank
FROM rfm;

-- 复购率与复购周期（基于行为为购买的记录）
WITH orders AS (
  SELECT user_id, DATE(FROM_UNIXTIME(timestamp)) AS order_date
  FROM user_behavior
  WHERE behavior_type IN ('4','buy')
), user_orders AS (
  SELECT user_id, COUNT(DISTINCT order_date) AS order_days, MIN(order_date) AS first_order, MAX(order_date) AS last_order
  FROM orders
  GROUP BY user_id
)
SELECT
  COUNT(*) AS users_total,
  SUM(order_days = 1) AS only_one_order,
  SUM(order_days >= 2) AS repurchase_users,
  ROUND(SUM(order_days >= 2)/COUNT(*),4) AS repurchase_rate
FROM user_orders;
