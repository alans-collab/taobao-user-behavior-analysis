-- 02_retention.sql
-- Cohort 次日 / 7日 / 30日 留存示例（MySQL 8+ 支持窗口函数）
WITH first_visit AS (
  SELECT user_id, MIN(FROM_UNIXTIME(timestamp)) AS first_dt
  FROM user_behavior
  GROUP BY user_id
), events AS (
  SELECT ub.user_id, FROM_UNIXTIME(ub.timestamp) AS evt_dt
  FROM user_behavior ub
)
SELECT
  DATE(fv.first_dt) AS cohort_date,
  DATEDIFF(DATE(e.evt_dt), DATE(fv.first_dt)) AS days_from_first,
  COUNT(DISTINCT e.user_id) AS users
FROM first_visit fv
JOIN events e ON e.user_id = fv.user_id
GROUP BY cohort_date, days_from_first
ORDER BY cohort_date, days_from_first;

-- 计算 cohort 留存率（转为百分比），次日/7日/30日
WITH first_visit AS (
  SELECT user_id, DATE(FROM_UNIXTIME(MIN(timestamp))) AS cohort_date
  FROM user_behavior
  GROUP BY user_id
), events AS (
  SELECT user_id, DATE(FROM_UNIXTIME(timestamp)) AS evt_date
  FROM user_behavior
)
SELECT fv.cohort_date,
  SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=0 THEN 1 ELSE 0 END) AS day0,
  SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=1 THEN 1 ELSE 0 END) AS day1,
  SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=7 THEN 1 ELSE 0 END) AS day7,
  SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=30 THEN 1 ELSE 0 END) AS day30,
  COUNT(DISTINCT fv.user_id) AS cohort_size,
  ROUND( SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=1 THEN 1 ELSE 0 END) / COUNT(DISTINCT fv.user_id), 4) AS retention_day1,
  ROUND( SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=7 THEN 1 ELSE 0 END) / COUNT(DISTINCT fv.user_id), 4) AS retention_day7,
  ROUND( SUM(CASE WHEN DATEDIFF(e.evt_date, fv.cohort_date)=30 THEN 1 ELSE 0 END) / COUNT(DISTINCT fv.user_id), 4) AS retention_day30
FROM first_visit fv
JOIN events e ON e.user_id = fv.user_id
GROUP BY fv.cohort_date
ORDER BY fv.cohort_date;
