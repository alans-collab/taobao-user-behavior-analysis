此目录包含用于面试展示的 SQL 脚本。主要目标：展示如何用 SQL 做漏斗、cohort 留存和 RFM 分层。

使用说明：
1. 将 CSV 导入 MySQL：

```
CREATE DATABASE taobao;
USE taobao;
CREATE TABLE user_behavior (
  user_id BIGINT,
  item_id BIGINT,
  category_id INT,
  behavior_type TINYINT,
  timestamp BIGINT
);

-- 在 Linux 或 Windows 上使用 LOAD DATA INFILE 导入
LOAD DATA LOCAL INFILE 'path/to/UserBehavior.csv' INTO TABLE user_behavior
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
(@col1,@col2,@col3,@col4,@col5)
SET user_id=@col1,item_id=@col2,category_id=@col3,behavior_type=@col4,timestamp=@col5;
```

2. 运行 `01_funnel.sql`、`02_retention.sql`、`03_rfm.sql`。
