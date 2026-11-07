#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flink-cdc.sh \
    -t yarn-application \
    -Dexecution.attached=false \
    -Dclassloader.resolve-order=parent-first \
    -Dyarn.application.name=gesac_pg_erp_cdc_pipeline \
    -Dparallelism.default=2 \
    -Dexecution.checkpointing.interval=30s \
    -Dstate.checkpoints.dir=hdfs://namenode:9000/flink/checkpoints \
    -Djobmanager.memory.process.size=1gb \
    -Dtaskmanager.memory.process.size=2gb \
    -Dtaskmanager.numberOfTaskSlots=2 \
    "${SCRIPT_DIR}/flink_cdc_pipeline_db.yaml"
