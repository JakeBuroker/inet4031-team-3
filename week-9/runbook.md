**Incident 1:** CPU throttling under load

**Symptom:** P95 response time exceeds 500ms during ramped load test. Prometheus shows a non-zero CPU throttle rate for the Flask pods.

**Root Cause:** Flask Deployment CPU limit set to 100m. At 50 VUs, the container requests more CPU than the limit allows.

**Fix:**
1. Confirm throttling: rate(container_cpu_cfs_throttled_periods_total{container="flask"}[5m]) > 0
2. Identify the limit: kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}'
3. Restore the limit on the live cluster: kubectl set resources deployment flask -c flask --limits=cpu=500m
4. Confirm the cpu limit is 500m in infrastructure/flask.tf (kubernetes_deployment.flask resource), so a rebuild keeps it
5. Re-run load test and confirm throttle rate drops to near zero

**Measured Before/After vs. Stated Target:**
- P95 before fix: [8.6]ms
- P95 after fix: [892.11]ms
- CPU throttle rate before: [0.3042133549662831]
- CPU throttle rate after: [0]
- Target: P95 < 500ms

---

**Incident 2:** Sequential scan on incidents table

**Symptom:** pg_stat_statements shows high mean_exec_time. EXPLAIN ANALYZE shows Seq Scan on 50,000 rows.

**Root Cause:** No index on (status, created_at). Full table scan required for every filtered/sorted query.

**Fix:**
1. Confirm: EXPLAIN (ANALYZE, BUFFERS) shows "Seq Scan on incidents"
2. Create index: CREATE INDEX CONCURRENTLY idx_incidents_status_created ON incidents(status, created_at DESC)
3. Verify: re-run EXPLAIN ANALYZE, confirm "Index Scan" appears

**Measured Before/After vs. Stated Target:**
- Mean query time before index: [36.251]ms
- Mean query time after index: [0.149]ms
- P95 before: [8600]ms
- P95 after: [892.11]ms
- Target: P95 < 500ms
