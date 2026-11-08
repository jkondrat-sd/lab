-- 为 erp schema 中已创建的普通表输出完整的 UPDATE/DELETE 旧行镜像。
-- 此脚本必须在业务表导入 PostgreSQL 后执行。
DO $$
DECLARE
  table_record RECORD;
BEGIN
  FOR table_record IN
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE schemaname = 'erp'
  LOOP
    EXECUTE format(
      'ALTER TABLE %I.%I REPLICA IDENTITY FULL',
      table_record.schemaname,
      table_record.tablename
    );
  END LOOP;
END
$$;
