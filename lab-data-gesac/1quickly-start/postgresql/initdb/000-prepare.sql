DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hive') THEN
    CREATE ROLE hive LOGIN PASSWORD 'hive_password';
  ELSE
    ALTER ROLE hive LOGIN PASSWORD 'hive_password';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dolphinscheduler') THEN
    CREATE ROLE dolphinscheduler LOGIN PASSWORD 'dolphinscheduler_password';
  ELSE
    ALTER ROLE dolphinscheduler LOGIN PASSWORD 'dolphinscheduler_password';
  END IF;

  -- 查询 Flink CDC 专用 dsj_cdc 角色是否已存在。
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dsj_cdc') THEN
    -- 创建可登录且具有逻辑复制连接权限的 CDC 账户，并设置密码。
    CREATE ROLE dsj_cdc LOGIN REPLICATION PASSWORD 'dsj_cdc_password';
  ELSE
    -- 角色已存在时确保其保留登录和复制属性，并撤销不需要的角色管理权限。
    ALTER ROLE dsj_cdc LOGIN REPLICATION NOCREATEROLE PASSWORD 'dsj_cdc_password';
  END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS app_db;
CREATE SCHEMA IF NOT EXISTS hive_metastore AUTHORIZATION hive;
CREATE SCHEMA IF NOT EXISTS dolphinscheduler AUTHORIZATION dolphinscheduler;
CREATE SCHEMA IF NOT EXISTS erp;
CREATE SCHEMA IF NOT EXISTS dga;

GRANT USAGE ON SCHEMA hive_metastore TO hive;
GRANT ALL PRIVILEGES ON SCHEMA dolphinscheduler TO dolphinscheduler;

-- 授予 CDC 账户连接 app_db 数据库的权限，允许其建立逻辑复制连接。
GRANT CONNECT ON DATABASE app_db TO dsj_cdc;
-- publication 由表所有者预先创建，CDC 账户无需数据库级 CREATE 权限。
REVOKE CREATE ON DATABASE app_db FROM dsj_cdc;
-- 授予 CDC 账户访问 erp schema 中对象名称的权限。
GRANT USAGE ON SCHEMA erp TO dsj_cdc;
-- 授予 CDC 账户读取 erp 中现有所有表的权限，用于初始快照与增量校验。
GRANT SELECT ON ALL TABLES IN SCHEMA erp TO dsj_cdc;
-- 授予 CDC 账户读取 erp 中现有序列的权限，避免快照读取依赖序列时被拒绝。
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA erp TO dsj_cdc;

-- 为当前执行脚本的对象创建者设置默认权限：未来在 erp 中新建的表自动授予 CDC 账户读取权限。
ALTER DEFAULT PRIVILEGES IN SCHEMA erp GRANT SELECT ON TABLES TO dsj_cdc;
