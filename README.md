# UniVid Pro (Scaffold)

This is a minimal, safe-to-run scaffold for the UniVid Pro platform. It includes:

- Backend API (Node.js + Express)
- PostgreSQL + Redis via Docker Compose
- FFmpeg placeholder service
- Scripts with safe placeholders for sensitive operations (AWS/Stripe/Google Play/banking)

Production credentials, developer accounts, and bank connections are NOT included and must be provisioned by you. All sensitive operations are stubbed to avoid unsafe automation.

## Quick start

- Prerequisites: Docker + Docker Compose
- Start services:

```bash
docker compose up -d --build
```

- API health check: http://localhost:8080/health

## Structure

- `services/api`: Express API with a basic health route
- `database`: SQL migrations and seed placeholders
- `scripts`: Installer and platform scripts (safe stubs)
- `infra`: Placeholder for IaC (e.g., Terraform)

## Notes

- Replace stubbed environment variables in `services/api/.env.example` and create `services/api/.env` before enabling DB access.
- Do NOT store real credentials in the repository.
- For mobile (React Native) and full automation flows, this scaffold uses documentation and placeholders to avoid unsafe actions in this environment.