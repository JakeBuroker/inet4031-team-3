# Week 8: Data Observability and Backup Verification

**Sprint 4 | Due before Sprint 4 Review**

## Overview

In this lab, your team builds an automated backup pipeline for your PostgreSQL database, verifies backups actually work under a simulated failure, and measures recovery time against a defined target. You will provision a MinIO container as an S3-compatible backup destination, automate backups with restic via a GitHub Actions scheduled workflow, apply a retention policy, and run a recovery drill.

## Learning Objectives

- Provision MinIO as an S3-compatible backup target using a Docker container
- Configure restic for PostgreSQL data volume backups to an S3-compatible backend
- Implement a retention policy using `restic forget --prune`
- Automate backups using a GitHub Actions scheduled workflow with cron syntax
- Execute a recovery drill and measure actual RTO against a stated target

## Prerequisites

- Week 7 complete: security controls applied, CI pipeline passing
- Application is running with data in the database

## Pulling This Week's Starter Content Into Your Team Repo

This repo (`inet4031-week08`) is instructor-provided starter/reference content for
Week 8, not something you clone standalone. Pull the pieces you need into your
team's single repo:

```bash
git remote add week8 https://github.com/INET4031-Labs/inet4031-week08.git
git fetch week8
git checkout week8/main -- week-8 scripts docs
git remote remove week8
```

**`.github/workflows/backup.yml` is not shipped as a file in this repo.** You write it
yourself, following the wiki, it's the actual exercise for this lab. Do this before
you start editing `week-8/` locally, or your local changes will be silently
overwritten by the checkout.

## Role Distribution

- **Scrum Master:** sprint process, issue tracking, completion summary
- **System Admin:** environment health, Docker/MinIO configuration decisions, backup target placement
- **QA:** validation check verification, recovery drill sign-off before submission
- **Developer(s):** restic configuration, GitHub Actions workflow, runbook authoring

## Deliverables

- `week-8/restic-env.sh` committed (credentials placeholdered or omitted)
- `.github/workflows/backup.yml` committed
- `week-8/runbook.md` committed using the required format
- Google Doc updated with recovery drill results
- `./scripts/check-week8.sh` runs clean

## Full Instructions

The complete step-by-step lab, including exact restic configuration and the recovery drill procedure, is in this repo's Wiki tab. This README is a reference, not a substitute.
