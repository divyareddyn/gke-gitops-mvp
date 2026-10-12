#!/bin/bash
# Security check: verifies the extra security controls on the running podinfo pods.
# Expected:
#   1. id                 -> uid=10001 (not uid=0, which is root)
#   2. ls token folder    -> "No such file or directory" (no API token mounted)
#   3. securityContext    -> runAsNonRoot:true, runAsUser:10001,
#                            allowPrivilegeEscalation:false, capabilities drop ALL

set -x

date -u

kubectl exec -n podinfo deploy/podinfo -- id

kubectl exec -n podinfo deploy/podinfo -- ls /var/run/secrets/kubernetes.io/serviceaccount

# Security settings on the live pod (pod level, then container level)
kubectl get pod -n podinfo -l app=podinfo \
  -o jsonpath='{.items[0].spec.securityContext}{"\n"}{.items[0].spec.containers[0].securityContext}{"\n"}'
