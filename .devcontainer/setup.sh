#!/bin/bash
set -e

echo "Starting backing services..."
cd /workspaces/coop
docker compose up -d postgres redis clickhouse scylla

echo "Waiting for Postgres to be healthy..."
until docker compose exec -T postgres pg_isready -U postgres; do sleep 2; done

echo "Running migrations..."
docker compose run --rm migrations

echo "Installing dependencies..."
npm install
(cd client && npm install)
(cd server && npm install)

echo "Building server..."
cd server && npm run build && cd ..

echo "Creating demo org..."
cd server
node --require dotenv/config bin/create-org-and-user.js \
  --name "Zora" \
  --email "admin@zora.co" \
  --password "demo123!" \
  --website "https://zora.co" \
  --firstName "Demo" \
  --lastName "User" 2>/dev/null || \
node --loader ts-node/esm --require dotenv/config bin/create-org-and-user.ts \
  --name "Zora" \
  --email "admin@zora.co" \
  --password "demo123!" \
  --website "https://zora.co" \
  --firstName "Demo" \
  --lastName "User" || true
cd ..

echo ""
echo "============================================"
echo "  Coop is ready!"
echo "  Run in two terminals:"
echo "    Terminal 1: npm run server:start"
echo "    Terminal 2: npm run client:start"
echo ""
echo "  Login: admin@zora.co / demo123!"
echo "============================================"
