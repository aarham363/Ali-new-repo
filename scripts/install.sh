#!/usr/bin/env bash
set -euo pipefail

command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is required. Please install Docker."; exit 1; }
command -v docker compose >/dev/null 2>&1 || { echo >&2 "Docker Compose plugin is required. Please install it."; exit 1; }

printf "Starting UniVid Pro scaffold...\n"

docker compose up -d --build

echo "Services started. API: http://localhost:8080/health"
echo "Next: copy services/api/.env.example to services/api/.env and customize."