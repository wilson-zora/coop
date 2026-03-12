#!/bin/bash
set -e

echo "Copying lua files to transpiled output..."
cd /workspace/server
mkdir -p transpiled/lib/cache/stores/RedisStore/lua
cp lib/cache/stores/RedisStore/lua/*.lua transpiled/lib/cache/stores/RedisStore/lua/

echo "Running database migrations..."
cd /workspace/.devops/migrator && npm install
cd /workspace

# Run PG and ClickHouse migrations
DATABASE_HOST=postgres API_SERVER_DATABASE_HOST=postgres \
DATABASE_PORT=5432 API_SERVER_DATABASE_PORT=5432 \
DATABASE_NAME=postgres API_SERVER_DATABASE_NAME=postgres \
DATABASE_USER=postgres API_SERVER_DATABASE_USER=postgres \
DATABASE_PASSWORD=postgres123 API_SERVER_DATABASE_PASSWORD=postgres123 \
CLICKHOUSE_PROTOCOL=http CLICKHOUSE_HOST=clickhouse CLICKHOUSE_PORT=8123 \
CLICKHOUSE_USERNAME=default CLICKHOUSE_PASSWORD=clickhouse CLICKHOUSE_DATABASE=analytics \
SCYLLA_HOSTS=scylla:9042 SCYLLA_USERNAME=cassandra SCYLLA_PASSWORD=cassandra \
SCYLLA_LOCAL_DATACENTER=datacenter1 \
npm run db:update -- --env staging --db api-server-pg || true

DATABASE_HOST=postgres CLICKHOUSE_PROTOCOL=http CLICKHOUSE_HOST=clickhouse \
CLICKHOUSE_PORT=8123 CLICKHOUSE_USERNAME=default CLICKHOUSE_PASSWORD=clickhouse \
CLICKHOUSE_DATABASE=analytics SCYLLA_HOSTS=scylla:9042 SCYLLA_USERNAME=cassandra \
SCYLLA_PASSWORD=cassandra SCYLLA_LOCAL_DATACENTER=datacenter1 \
npm run db:update -- --env staging --db clickhouse || true

echo "Creating demo org..."
cd /workspace/server
npm run create-org -- \
  --name "Zora" \
  --email "admin@zora.co" \
  --password "demo123!" \
  --website "https://zora.co" \
  --firstName "Demo" \
  --lastName "User" || true

echo ""
echo "============================================"
echo "  Coop is ready!"
echo "  Open two terminals and run:"
echo "    Terminal 1: npm run server:start"
echo "    Terminal 2: npm run client:start"
echo ""
echo "  Then open http://localhost:3000"
echo "  Login: admin@zora.co / demo123!"
echo "============================================"
