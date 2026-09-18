# INET 4031: Team 3 Repository

This is the semester-long repository for our team's INET 4031 Systems Administration
project: an incident-tracking application built and operated across nine weeks,
moving from Docker Compose through Kubernetes, Infrastructure as Code, CI/CD,
observability, security hardening, and backup/recovery.

**The full in-depth lab instructions for every week are in the "Wiki" tab of each week's lab repository.**

## Team

**Team Name:** INET 4031 Team 3 

**Team Number:** 3

**Roster:**

Jake
Ismail
Hugo
Tomas
Mohamed
Yasir

See `team-charter.md` for role assignments and the 7-sprint rotation schedule.

## Directory Structure

```
README.md              - this file
team-charter.md         - team roles, rotation schedule, operating agreements
ansible/                - playbook that grows one role per week (Weeks 1-4)
scripts/                - validation check scripts, one per week
docs/                   - sprint retrospectives, environment log, acceptance criteria, QA reports
week-1/ .. week-9/      - per-week working directories (some weeks' real deliverables
                          live in top-level dirs instead - manifests/, infrastructure/,
                          .github/workflows/ - see each week-N README for specifics)
```

## Getting Each Week's Starter Content

Starting Week 2, each week has a corresponding `inet4031-week0N` repo with starter
and reference files for that week. You pull only what you need from it into this one
repo, it will never replace this repository.

## Team Documents

**Google Doc:** [Google Doc link will go here]

All sprint reflections, screenshots, and storage-check output are recorded in this
document as each week's wiki directions require.

## Getting Started

1. Read the Week 1 wiki directions completely before beginning.
2. Follow Part 1, then Part 2, then Part 3 in order.
3. Before submitting, run `./scripts/check-week1.sh` from the repo root to verify
   all Week 1 requirements are met.
4. Reference `docs/qa-report-1.md` for the sign-off checklist.

## Questions or Issues

1. Check the troubleshooting notes in the wiki.
2. Consult with your team's System Admin and QA roles.
3. Contact the course instructor if blocked.
