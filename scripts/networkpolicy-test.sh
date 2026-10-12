#!/bin/bash
# NetworkPolicy test: one allowed and one denied request to podinfo.
# Expected: test-allowed returns {"status":"OK"}, test-denied prints BLOCKED.

set -x

date -u

# TEST 1: pod WITH label access=allowed -> expect success
kubectl run test-allowed -n podinfo --rm -i --restart=Never \
  --image=curlimages/curl --labels="access=allowed" \
  -- sh -c 'curl -s -m 5 http://podinfo/healthz || echo "BLOCKED (curl exit code $?)"'

date -u

# TEST 2: pod WITHOUT the label -> expect blocked
kubectl run test-denied -n podinfo --rm -i --restart=Never \
  --image=curlimages/curl \
  -- sh -c 'curl -s -m 5 http://podinfo/healthz || echo "BLOCKED (curl exit code $?)"'

