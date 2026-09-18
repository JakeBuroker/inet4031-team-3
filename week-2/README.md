# Week 2: Building Your Three-Tier Application Stack

This directory will contain the Docker Compose configuration and related files for Sprint 1 async work.

## Week 2 Deliverables

You will create the following files in this directory during Week 2:

- `docker-compose.yml` - Three-tier application stack (PostgreSQL, Flask, Nginx)
- `nginx.conf` - Nginx reverse proxy configuration
- `.env.example` - Template for environment variables (real `.env` goes in `.gitignore`)
- `README.md` - Documentation for the stack

## What You Will Build

The incident tracking application consists of:
1. **PostgreSQL** (`db`) - Database service
2. **Flask** (`flask`) - Python API service
3. **Nginx** (`nginx`) - Reverse proxy service

All three services will run together in Docker Compose with:
- Named network for service discovery
- Named volume for data persistence
- Health checks for startup ordering
- Environment variable injection for credentials

## Prerequisites

Before starting Week 2, ensure:
- Week 1 complete (GitHub repo, team container access, Ansible playbook)
- Docker is running in your team container
- Application source code is available (path provided by professor)

See the full lab directions for detailed steps.
