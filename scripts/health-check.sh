#!/bin/bash
# Health check script — tests all apps behind the reverse proxy

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Health Check — Docker Multi-App"
echo "========================================"

check_service() {
    local name=$1
    local url=$2

    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" 2>/dev/null)

    if [ "$response" = "200" ]; then
        echo -e "  ${GREEN}✓${NC} $name ($url) — HTTP $response"
    else
        echo -e "  ${RED}✗${NC} $name ($url) — HTTP $response"
    fi
}

echo ""
echo "Checking services..."
check_service "Flask API  " "http://app1.localhost/health"
check_service "Node API   " "http://app2.localhost/health"
check_service "Static Site" "http://app3.localhost"
check_service "Nginx Proxy" "http://localhost/nginx-health"

echo ""
echo "Docker container status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
echo "========================================"
