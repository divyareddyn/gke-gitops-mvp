#!/bin/bash
# Observability check: where to see cluster health, workload health,
# HPA metrics/events, and application logs using kubectl.

set -x

date -u

# ---------- 1. Cluster health ---------------------
kubectl get nodes
kubectl top nodes

# ---------- 2. Workload health ----------
kubectl get application podinfo -n argocd
kubectl get deploy,pods -n podinfo
kubectl top pods -n podinfo

# ---------- 3. HPA metrics and events ----------
kubectl get hpa podinfo -n podinfo
kubectl describe hpa podinfo -n podinfo

# ---------- 4. Recent events in the namespace ----------
kubectl get events -n podinfo --sort-by=.lastTimestamp

# ---------- 5. Application logs ----------
kubectl logs -n podinfo -l app=podinfo --prefix --tail=10
