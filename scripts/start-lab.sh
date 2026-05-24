#!/bin/bash
set -e

cleanup_port() {
  local port=$1
  lsof -ti tcp:${port} | xargs kill -9 2>/dev/null || true
}

start_pf() {
  local name=$1
  local namespace=$2
  local resource=$3
  local mapping=$4
  local logfile=$5

  local local_port
  local_port=$(echo "$mapping" | cut -d: -f1)

  cleanup_port "$local_port"

  echo "Starting ${name} on localhost:${local_port}"

  kubectl port-forward -n "$namespace" "$resource" "$mapping" \
    > "$logfile" 2>&1 &
}

# Start Ollama if not already running
if ! pgrep -x "ollama" > /dev/null; then
  echo "Starting Ollama..."
  ollama serve > /tmp/ollama.log 2>&1 &
  sleep 5
else
  echo "Ollama already running"
fi

# Ensure llama3.1:8b exists
ollama list | grep "llama3.1:8b" > /dev/null || ollama pull llama3.1:8b

echo "Starting Kubernetes port-forwards..."

# Traefik app routes
start_pf "Traefik App Routes" \
  gateway \
  svc/traefik \
  8088:80 \
  /tmp/pf-8088.log

# Traefik AI Gateway endpoint
start_pf "Traefik AI Gateway" \
  gateway \
  svc/traefik \
  8099:80 \
  /tmp/pf-8099.log

# Traefik dashboard
start_pf "Traefik Dashboard" \
  gateway \
  deploy/traefik \
  8080:8080 \
  /tmp/pf-8080.log

# Traefik metrics
start_pf "Traefik Metrics" \
  gateway \
  deploy/traefik \
  9100:9100 \
  /tmp/pf-9100.log

# Prometheus
start_pf "Prometheus" \
  monitoring \
  svc/prometheus-server \
  9090:80 \
  /tmp/pf-9090.log

# Open WebUI
start_pf "Open WebUI" \
  webui \
  svc/open-webui \
  3000:8080 \
  /tmp/pf-3000.log

# LiteLLM direct access
start_pf "LiteLLM" \
  aigateway \
  svc/litellm \
  4000:4000 \
  /tmp/pf-4000.log

# MCP Server
start_pf "MCP Tool Server" \
  mcp \
  svc/mcp-tool-server \
  7000:7000 \
  /tmp/pf-7000.log

# Guardrail Proxy Metrics
start_pf "Guardrail Metrics" \
  guardrails \
  svc/guardrail-proxy \
  5000:5000 \
  /tmp/pf-5000.log

echo ""
echo "========================================"
echo "Lab Services"
echo "========================================"
echo ""
echo "Traefik Dashboard:"
echo "  http://localhost:8080/dashboard/"
echo ""
echo "Traefik Metrics:"
echo "  http://localhost:9100/metrics"
echo ""
echo "Prometheus:"
echo "  http://localhost:9090"
echo ""
echo "Guardrail Metrics:"
echo "  http://localhost:5000/metrics"
echo ""
echo "Open WebUI (through AI Gateway):"
echo "  http://localhost:3000"
echo ""
echo "LiteLLM Direct:"
echo "  http://localhost:4000"
echo ""
echo "Traefik AI Gateway:"
echo "  http://localhost:8099/v1/chat/completions"
echo ""
echo "Whoami/Test Route:"
echo "  http://localhost:8088"
echo ""
echo "KubeView:"
echo "  http://localhost:8000"
echo ""
echo "Filesystem MCP:"
echo "  http://localhost:7000"
echo ""
echo "========================================"
echo ""
echo "Guardrail Prometheus Queries:"
echo "  guardrail_allowed_total"
echo "  guardrail_blocked_total"

jobs
