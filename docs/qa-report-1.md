# QA Report: Sprint 1 Week 1

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: All Team Members Can Access the Container

**Status:** [ ] PASS [ ] FAIL

**Evidence:**
```
[Paste output of each team member running `whoami` and `hostname`]
```

**Notes:**
[Any issues encountered or observations]

**Sign-off:** [ ] QA approves this check

---

### Check 2: Repository Structure Is Correct

**Status:** [ ] PASS [ ] FAIL

**Evidence:**
```
[Paste output of `ls -1` from repo root]
```

**Expected directories present:**
- [ ] README.md
- [ ] ansible
- [ ] scripts
- [ ] team-charter.md
- [ ] week-1 to week-9

**Notes:**
[Any missing directories or issues]

**Sign-off:** [ ] QA approves this check

---

### Check 3: Ansible Playbook Is Idempotent

**Status:** [ ] PASS [ ] FAIL

**First Run Output:**
```
[Paste PLAY RECAP from first `ansible-playbook` run]
```

**Second Run Output:**
```
[Paste PLAY RECAP from second `ansible-playbook` run]
```

**Verification:**
- [ ] First run shows `failed=0` and `unreachable=0`
- [ ] Second run shows `changed=0`
- [ ] All tasks on second run show `ok` status

**Notes:**
[Any tasks that showed `changed` on the second run]

**Sign-off:** [ ] QA approves this check

---

### Check 4: Google Doc Is Linked and Shared

**Status:** [ ] PASS [ ] FAIL

**Evidence:**
- [ ] Google Doc URL present in README.md
- [ ] URL is accessible at: [Paste URL here]
- [ ] Doc is readable by University of Minnesota users
- [ ] Sprint 1 Reflections section contains Part 2 answers
- [ ] Sprint 1 Reflections section contains Part 3 answers
- [ ] Week 1 Storage Baseline section contains required outputs

**Notes:**
[Any access or content issues]

**Sign-off:** [ ] QA approves this check

---

### Check 5: Check Script Passes

**Status:** [ ] PASS [ ] FAIL

**Command Run:**
```bash
./scripts/check-week1.sh
```

**Output:**
```
[Paste full output]
```

**Notes:**
[Any failures or warnings from the script]

**Sign-off:** [ ] QA approves this check

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 2

[Any observations or recommendations for the next sprint]
