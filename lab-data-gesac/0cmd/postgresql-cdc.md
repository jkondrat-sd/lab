## 设置 wal_level = logical

需要在配置文件中修改配置。
文件的位置一般默认为 C:\Program Files\PostgreSQL\16\data\postgresql.conf

如果不知道位置，可以执行 

SHOW config_file;

## 授权用户 cdc 权限

ALTER ROLE dj_read_only WITH REPLICATION;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO dj_read_only;

## 定义所有表变更需要通过逻辑复制输出

CREATE PUBLICATION paimon_cdc_publication FOR ALL TABLES;