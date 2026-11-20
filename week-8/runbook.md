**Incident:** Database data loss recovery
 
**Symptom:** Application returns errors or empty results for incident queries. Row count in incidents table drops to zero or table is missing.
 
**Root Cause:** Table or data deleted. Confirmed by: SELECT COUNT(*) FROM incidents returns error "relation does not exist."
 
**Fix:**
1. Stop Flask to prevent writes: kubectl scale deployment flask --replicas=0
2. Identify the most recent clean snapshot: restic snapshots
3. Restore the database dump: restic dump <snapshot-id> /statustracker.sql | kubectl exec -i deploy/db -- psql -U appuser -d statustracker
4. Import the Flask image and restart Flask: k3d image import week-2-flask:latest -c team-<team number> && kubectl scale deployment flask --replicas=<count>
5. Verify row count matches pre-incident count
 
**Measured Before/After vs. Stated Target:**
- Row count before incident: 3
- Row count after restore: 3
- RTO target: 15 minutes
- Actual RTO: 5:27
