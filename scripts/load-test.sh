#!/bin/bash
# HPA load test for podinfo.
# Load method: using fortio for fixed concurrency for a fixed duration, from inside the cluster.
# Reachability: a separate pod calls /healthz every 2 seconds during the whole test.
# Expected: replicas rise above 2 while load runs, then return to 2 after it stops.
# Run from the repo root: bash scripts/load-test.sh 2>&1 | tee evidence/12-load-test.txt

# ---------- Settings (change these to change the test) ----------
NS=podinfo
FORTIO_IMAGE="fortio/fortio:1.76.0"
CONCURRENCY=4
DURATION=180s
SAMPLES=36
INTERVAL=15

# ---------- 1. Starting state ----------
set -x
date -u
kubectl get hpa podinfo -n $NS
kubectl top pods -n $NS -l app=podinfo

# ---------- 2. Start reachability checker ----------
kubectl run reachability -n $NS --restart=Never \
  --image=curlimages/curl --labels="access=allowed" \
  -- sh -c 'while true; do echo "$(date -u +%T) $(curl -s -o /dev/null -w "%{http_code}" -m 2 http://podinfo/healthz)"; sleep 2; done'

# ---------- 3. Start load generator ---------------
kubectl run loadgen -n $NS --restart=Never \
  --image=$FORTIO_IMAGE --labels="access=allowed" \
  -- load -qps 0 -c $CONCURRENCY -t $DURATION http://podinfo/

kubectl wait --for=condition=Ready pod/loadgen pod/reachability -n $NS --timeout=90s
set +x

# ---------- 4. Watch the HPA every 15 seconds ----------
echo "LOAD STARTED at $(date -u +%T)"
echo "TIME(UTC)  CPU%(target 50)  DESIRED  CURRENT  READY  PENDING  LOADGEN"
for i in $(seq 1 $SAMPLES); do
  CPU=$(kubectl get hpa podinfo -n $NS -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')
  DESIRED=$(kubectl get hpa podinfo -n $NS -o jsonpath='{.status.desiredReplicas}')
  CURRENT=$(kubectl get hpa podinfo -n $NS -o jsonpath='{.status.currentReplicas}')
  READY=$(kubectl get deploy podinfo -n $NS -o jsonpath='{.status.readyReplicas}')
  PENDING=$(kubectl get pods -n $NS -l app=podinfo --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l)
  LOADGEN=$(kubectl get pod loadgen -n $NS -o jsonpath='{.status.phase}')
  echo "$(date -u +%T)   ${CPU:-?}%             $DESIRED        $CURRENT        $READY      $PENDING        $LOADGEN"
  kubectl top pods -n $NS -l app=podinfo --no-headers | awk '{printf "    %s %s\n", $1, $2}'
  sleep $INTERVAL
done

# ---------- 5. Final state, HPA events, results ----------
set -x
date -u
kubectl get hpa podinfo -n $NS
kubectl get pods -n $NS -l app=podinfo
kubectl describe hpa podinfo -n $NS
kubectl logs loadgen -n $NS > evidence/10-load-fortio-results-keepalive.txt
kubectl logs reachability -n $NS > evidence/10-load-reachability-keepalive.txt
set +x

TOTAL=$(wc -l < evidence/10-load-reachability-keepalive.txt)
NOT_OK=$(grep -vc ' 200$' evidence/10-load-reachability-keepalive.txt)
echo "REACHABILITY: $TOTAL checks, $NOT_OK were not HTTP 200"

# ---------- 6. Clean up test pods ----------
set -x
kubectl delete pod loadgen reachability -n $NS
