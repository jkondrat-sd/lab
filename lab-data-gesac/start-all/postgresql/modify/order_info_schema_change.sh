#!/usr/bin/env bash
#
# 为 erp.order_info 增加一个可空字段，并更新一条订单数据。
# 请在 Flink CDC pipeline 已启动且完成初始快照后执行，以验证下游是否接收到
# AddColumnEvent 以及包含新字段的 UPDATE 事件。
#
# 用法：
#   ./start-all/postgresql/modify/order_info_schema_change.sh
#
# 可通过 COMPOSE_FILE 覆盖 compose 文件路径：
#   COMPOSE_FILE=/path/to/docker-compose.yml ./order_info_schema_change.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-${SCRIPT_DIR}/../../docker-compose.yml}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
    echo "找不到 docker compose 文件: ${COMPOSE_FILE}" >&2
    exit 1
fi

if ! docker compose -f "${COMPOSE_FILE}" ps --status running --services | grep -qx 'postgresql'; then
    echo "PostgreSQL 服务未运行，请先在 start-all 目录执行: docker compose up -d postgresql postgresql-init" >&2
    exit 1
fi

docker compose -f "${COMPOSE_FILE}" exec -T postgresql \
    psql -U app_user -d app_db -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

-- ADD COLUMN 会通过 pgoutput 的 Relation 消息传递给已运行的 Flink CDC 作业。
ALTER TABLE erp.order_info
    ADD COLUMN IF NOT EXISTS cdc_schema_change_note VARCHAR(100);

-- 触发一条包含新增字段的增量 UPDATE，供下游表和 CDC 日志校验。
UPDATE erp.order_info
SET cdc_schema_change_note = 'schema-change-verified'
WHERE id = (SELECT MIN(id) FROM erp.order_info);

COMMIT;

\echo 'Source schema after change:'
\d+ erp.order_info

\echo 'Changed record:'
SELECT id, cdc_schema_change_note
FROM erp.order_info
WHERE cdc_schema_change_note = 'schema-change-verified';
SQL

cat <<'EOF'

Schema change 已提交。
请等待一个 checkpoint 周期后，在 Paimon 目标表 erp.ods_order_info_cdc 中确认：
  1. 出现 cdc_schema_change_note VARCHAR(100) 列；
  2. 对应订单记录的该列值为 schema-change-verified。

若此脚本已执行过，ADD COLUMN IF NOT EXISTS 会保持幂等，UPDATE 会再次产生一条 CDC 事件。
EOF
