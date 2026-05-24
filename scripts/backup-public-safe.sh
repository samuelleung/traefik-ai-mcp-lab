#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OUT="$ROOT/backups/backup-$TS"

mkdir -p "$OUT/manifests" "$OUT/cluster-info"

echo "Exporting public-safe backup to $OUT"

kubectl get ns apps gateway monitoring webui aigateway ai mcp guardrails -o yaml \
  > "$OUT/manifests/namespaces.yaml" 2>/dev/null || true

for ns in apps gateway monitoring webui aigateway ai mcp guardrails; do
  if kubectl get ns "$ns" >/dev/null 2>&1; then
    echo "Exporting $ns"
    kubectl get all -n "$ns" -o yaml > "$OUT/manifests/$ns-all.yaml" 2>/dev/null || true
    kubectl get configmap -n "$ns" -o yaml > "$OUT/manifests/$ns-configmaps.yaml" 2>/dev/null || true
  fi
done

kubectl get gatewayclass,gateway,httproute -A -o yaml \
  > "$OUT/manifests/gateway-api.yaml" 2>/dev/null || true

kubectl get ingressroute,middleware -A -o yaml \
  > "$OUT/manifests/traefik-crds.yaml" 2>/dev/null || true

kubectl get pods -A -o wide > "$OUT/cluster-info/pods.txt" 2>/dev/null || true
kubectl get svc -A -o wide > "$OUT/cluster-info/services.txt" 2>/dev/null || true

cp "$ROOT/README.md" "$OUT/README.md" 2>/dev/null || true
cp -r "$ROOT/scripts" "$OUT/scripts" 2>/dev/null || true

tar -czf "$ROOT/backups/traefik-ai-mcp-lab-$TS.tar.gz" -C "$ROOT/backups" "backup-$TS"

echo "Done:"
ls -lh "$ROOT/backups/traefik-ai-mcp-lab-$TS.tar.gz"
