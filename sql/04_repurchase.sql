-- 04_repurchase.sql
-- 计算用户复购周期分布：统计两次相邻购买间隔分布
WITH orders AS (
  SELECT user_id, FROM_UNIXTIME(timestamp) AS order_dt
  FROM user_behavior
  WHERE behavior_type IN ('4','buy')
), numbered AS (
  SELECT user_id, order_dt,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_dt) AS rn
  FROM orders
), pairs AS (
  SELECT a.user_id, a.order_dt AS order_dt1, b.order_dt AS order_dt2,
    DATEDIFF(DATE(b.order_dt), DATE(a.order_dt)) AS days_between
  FROM numbered a
  JOIN numbered b ON a.user_id = b.user_id AND a.rn + 1 = b.rn
)
SELECT
  ROUND(AVG(days_between),1) AS avg_repurchase_days,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_between) AS median_days,
  COUNT(*) AS intervals_count
FROM pairs;
