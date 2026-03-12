#!/bin/bash
set -e

echo "Starting Coop demo (all services via Docker Compose)..."
cd /workspaces/coop

docker compose -f docker-compose.demo.yml up -d --build

echo ""
echo "Waiting for services to come up..."
echo "(This takes a few minutes on first run — building server, running migrations, seeding data)"
echo ""

# Wait for server to be healthy
timeout=300
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if docker compose -f docker-compose.demo.yml ps server 2>/dev/null | grep -q "healthy"; then
    break
  fi
  sleep 5
  elapsed=$((elapsed + 5))
  echo "  ...still starting ($elapsed s)"
done

if [ $elapsed -ge $timeout ]; then
  echo "WARNING: Server did not become healthy within ${timeout}s."
  echo "Check logs: docker compose -f docker-compose.demo.yml logs server"
  exit 1
fi

# Wait for seed to complete
echo "Seeding demo data..."
docker compose -f docker-compose.demo.yml logs -f seed 2>/dev/null || true

echo ""
echo "============================================"
echo "  Coop is ready!"
echo ""
echo "  UI:  Open port 3000 in the Ports tab"
echo "  API: Open port 8080 in the Ports tab"
echo ""
echo "  Login: admin@zora.co / demo123!"
echo "============================================"
