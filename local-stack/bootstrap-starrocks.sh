#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_FILE="$SCRIPT_DIR/starrocks/init/00-bootstrap.sql"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker no está instalado o no está en PATH" >&2
  exit 1
fi

echo "Esperando a que StarRocks FE acepte conexiones en 9030..."
until docker compose exec -T starrocks-fe bash -lc \
  "mysql -h127.0.0.1 -P9030 -uroot -e 'SELECT 1' >/dev/null 2>&1"; do
  sleep 2
done

echo "Esperando a que StarRocks tenga al menos un backend vivo..."
until docker compose exec -T starrocks-fe bash -lc \
  "mysql -N -B -h127.0.0.1 -P9030 -uroot -e 'SHOW BACKENDS' 2>/dev/null | grep -q $'\ttrue\t'"; do
  sleep 2
done

echo "Aplicando bootstrap SQL..."
docker compose exec -T starrocks-fe bash -lc \
  "mysql -h127.0.0.1 -P9030 -uroot" < "$SQL_FILE"

echo "Bootstrap completo."
