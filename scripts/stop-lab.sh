#!/bin/bash

set -e

echo "Stopping kubectl port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null || true

echo "Stopping Ollama..."
pkill -f "ollama serve" 2>/dev/null || true

echo "Cleaning local ports..."
for port in 3000 4000 5000 7000 8080 8088 8099 9090 9100; do
  lsof -ti tcp:${port} | xargs kill -9 2>/dev/null || true
done

echo ""
echo "All lab services stopped."
