# Week 7 – Security Hardening & Shift Left

**INET 4031 · Team 3 · Sprint 4 Kickoff**

This week we locked down our Flask app running on our `team3` k3d cluster. Before this, every pod could talk to every other pod, Flask ran with the default ServiceAccount, and nothing was checking our images for vulnerabilities. Now we have:

- **RBAC** – Flask runs as its own `flask-app` ServiceAccount
- **NetworkPolicy** – pods can only talk to each other on paths we allowed
- **SecurityContext** – the Flask container can't escalate privileges or write to its filesystem
- **Trivy scan in CI** – the pipeline scans our image for critical vulnerabilities

**Result: `check-week7.sh` passed 23/23 checks, 0 failed.**

---

## Starting Point (Sprint 4 Kickoff)

Before making any changes, we checked our environment:

| Item | State |
|---|---|
| k3d cluster `team3` | 1/1 servers, 2/2 agents |
| `db` pod | Running |
| `flask` pod | Running |
| `nginx` pod | Running |
| Prometheus (`monitoring` namespace) | `kube-state-metrics` and `server` both Running |
| Latest commit | `Week 6 lab files` |

---

## What We Added

### RBAC

| File | What it does |
|---|---|
| `manifests/flask-serviceaccount.yaml` | Creates the `flask-app` ServiceAccount and turns off auto-mounting the API token |
| `manifests/flask-role.yaml` | `flask-reader` Role that can only `get` and `list` ConfigMaps |
| `manifests/flask-rolebinding.yaml` | Connects `flask-app` to the `flask-reader` Role |

Flask doesn't call the Kubernetes API, so there's no reason for it to have a token sitting inside the container.

### NetworkPolicy

We started with deny-all, tested that it actually blocked traffic, then opened up only what the app needs.

| Policy | From | To | Port |
|---|---|---|---|
| `default-deny-ingress` | anything | all pods | blocked |
| `allow-ingress-to-nginx` | outside | nginx | 80 |
| `allow-nginx-to-flask` | nginx | flask | 5000 |
| `allow-flask-to-postgres` | flask | db | 5432 |
| `allow-prometheus-to-flask` | `monitoring` namespace | flask | 5000 |

**Deny test:** after applying `default-deny-ingress`, we ran a curl test pod against `http://flask/health`. It timed out after about 5 seconds, which is what we wanted.

### SecurityContext

Added to the Flask container in `infrastructure/flask.tf`, and applied to the live cluster with `manifests/flask-securitycontext-patch.yaml`.

| Setting | Value | Why |
|---|---|---|
| `allowPrivilegeEscalation` | `false` | A process can't gain more privileges than it started with |
| `readOnlyRootFilesystem` | `true` | Nobody can drop files or change binaries inside the container |
| `runAsNonRoot` | `true` | Container won't start as root |
| `runAsUser` | `1000` | Runs as a regular user |
| `capabilities.drop` | `ALL` | Removes Linux capabilities a lot of exploits rely on |

### Trivy Scan in CI

Added a `security-scan` job to `.github/workflows/ci.yml`. It runs after `build-and-push`, only on pushes to `main`, and fails if Trivy finds any **CRITICAL** vulnerabilities.

---

## OpenTofu vs. kubectl

We made every Flask change in two places:

| Where | Why |
|---|---|
| `infrastructure/flask.tf` | Source of truth for the rebuild on an empty VM. We did **not** run `tofu plan` or `tofu apply`. |
| `kubectl set` / `kubectl patch` | Changes the Deployment that's running right now, since OpenTofu hasn't been applied yet |

---

## How to Apply It

From the repo root:

```bash
# RBAC
kubectl apply -f manifests/flask-serviceaccount.yaml
kubectl apply -f manifests/flask-role.yaml
kubectl apply -f manifests/flask-rolebinding.yaml
kubectl set serviceaccount deployment flask flask-app
kubectl rollout status deployment/flask

# NetworkPolicy
kubectl apply -f manifests/default-deny.yaml
kubectl apply -f manifests/allow-nginx-to-flask.yaml
kubectl apply -f manifests/allow-flask-to-postgres.yaml
kubectl apply -f manifests/allow-ingress-to-nginx.yaml
kubectl apply -f manifests/allow-prometheus-to-flask.yaml

# SecurityContext
kubectl patch deployment flask --patch-file manifests/flask-securitycontext-patch.yaml
```

---

## Verification Results

| Check | Command | What we got |
|---|---|---|
| Flask uses the new ServiceAccount | `kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'` | `flask-app` ✅ |
| Policies are applied | `kubectl get networkpolicy` | All 5 policies listed ✅ |
| App still works | `curl -s http://localhost:8093/incidents` | `[]` (valid JSON) ✅ |
| SecurityContext is set | `kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'` | `false` ✅ |
| OpenTofu file updated | `grep -E "service_account_name\|allow_privilege_escalation" infrastructure/flask.tf` | Both lines found ✅ |

### check-week7.sh

| Check | Result |
|---|---|
| 1. RBAC and NetworkPolicy manifests exist (9 files) | PASS |
| 2. CI workflow includes Trivy scan | PASS |
| 3. Flask uses custom ServiceAccount | PASS |
| 4. All 5 NetworkPolicies exist | PASS |
| 5. App responds at `localhost:8093/incidents` (HTTP 200) | PASS |
| 6. SecurityContext settings (4 checks) | PASS |
| 7. OpenTofu config updated (2 checks) | PASS |
| **Total** | **23 passed, 0 failed** |

Screenshots are in our team Google Doc.

---

## Problems We Ran Into

| Problem | Cause | Fix |
|---|---|---|
| `the path "manifests/default-deny.yaml" does not exist` | We ran the command from inside the `manifests/` folder | `cd ..` back to the repo root and ran it again |
| `curl http://localhost:<your Kubernetes port>/incidents` gave a bash error | Copied the placeholder literally | Typed the actual port number |
| `curl http://localhost:<8093>/incidents` gave a syntax error | Left the `< >` around the port | Removed the brackets |
| `curl http://localhost:8083/incidents` – connection refused | Wrong port (8083 instead of 8093) | Used `8093`, our Kubernetes port |

---

## Takeaways

- Kubernetes is pretty open by default. You have to lock it down yourself.
- Authentication is "who are you" and authorization is "what are you allowed to do." RBAC handles the second part.
- Always test that a deny policy actually blocks traffic before adding allow rules.
- Run `kubectl apply -f manifests/...` from the repo root, not from inside `manifests/`.

---

## Up Next: Week 8

Backups and recovery: MinIO as a backup target, restic for the PostgreSQL volume, a scheduled backup workflow in GitHub Actions, and a data loss recovery drill.
