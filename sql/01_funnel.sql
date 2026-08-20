-- 01_funnel.sql
-- 建表（示例）
-- CREATE TABLE user_behavior (
--   user_id BIGINT,
--   item_id BIGINT,
--   category_id INT,
--   behavior_type TINYINT,
--   timestamp BIGINT
-- );

-- 漏斗统计：PV、UV、收藏、加购、购买
SELECT
  SUM(CASE WHEN behavior_type = 1 THEN 1 ELSE 0 END) AS pv,
  COUNT(DISTINCT CASE WHEN behavior_type = 1 THEN user_id END) AS uv,
  SUM(CASE WHEN behavior_type = 2 THEN 1 ELSE 0 END) AS collect_cnt,
  SUM(CASE WHEN behavior_type = 3 THEN 1 ELSE 0 END) AS cart_cnt,
  SUM(CASE WHEN behavior_type = 4 THEN 1 ELSE 0 END) AS buy_cnt
FROM user_behavior;

-- 分时漏斗（按小时）
SELECT hour, 
  SUM(behavior_type = 1) AS pv,
  SUM(behavior_type = 2) AS collect_cnt,
  SUM(behavior_type = 3) AS cart_cnt,
  SUM(behavior_type = 4) AS buy_cnt
FROM (
  SELECT *, FROM_UNIXTIME(timestamp) AS dt, HOUR(FROM_UNIXTIME(timestamp)) AS hour
  FROM user_behavior
) t
GROUP BY hour
ORDER BY hour;
