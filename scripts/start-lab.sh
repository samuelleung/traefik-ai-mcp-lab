#!/bin/bash

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
kubectl port-forward -n gateway svc/traefik 8088:80 \
  > /tmp/pf-8088.log 2>&1 &

# Traefik AI Gateway endpoint
kubectl port-forward -n gateway svc/traefik 8099:80 \
  > /tmp/pf-8099.log 2>&1 &

# Traefik dashboard
kubectl port-forward -n gateway deploy/traefik 8080:8080 \
  > /tmp/pf-8080.log 2>&1 &

# Traefik metrics
kubectl port-forward -n gateway deploy/traefik 9100:9100 \
  > /tmp/pf-9100.log 2>&1 &

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 \
  > /tmp/pf-9090.log 2>&1 &

# Open WebUI
kubectl port-forward -n webui svc/open-webui 3000:8080 \
  > /tmp/pf-3000.log 2>&1 &

# LiteLLM direct access
kubectl port-forward -n aigateway svc/litellm 4000:4000 \
  > /tmp/pf-4000.log 2>&1 &

# MCP Server
kubectl port-forward -n mcp svc/mcp-tool-server 7000:7000 \
  > /tmp/pf-7000.log 2>&1 &

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
echo "Open WebUI:"
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

jobs
