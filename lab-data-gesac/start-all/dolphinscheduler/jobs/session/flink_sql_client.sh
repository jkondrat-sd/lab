#!/bin/bash
set -euo pipefail

sql-client.sh \
  -i /opt/flink/conf/sql-init/sql-client-init.sql \
  -s yarn-session \
  -Dyarn.application.id=application_1794124655586_0002
