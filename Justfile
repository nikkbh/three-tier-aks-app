# Development commands for three-tier-aks-app

# Start all containers in the background
up:
    docker compose up -d

# Start all containers in the background with a rebuild
build:
    docker compose up -d --build

# Stop all containers
down:
    docker compose down

# Remove containers, volumes, and networks
down-clean:
    docker compose down -v

# View logs for all services
logs:
    docker compose logs -f

# View logs for a specific service (api, postgres, ui)
logs-service service:
    docker compose logs -f {{ service }}

# Check container status
status:
    docker compose ps

# View logs for API service
logs-api:
    docker compose logs -f api

# View logs for UI service
logs-ui:
    docker compose logs -f ui

# View logs for PostgreSQL
logs-db:
    docker compose logs -f postgres

# Rebuild and start specific service
rebuild-api:
    docker compose up -d --build api

rebuild-ui:
    docker compose up -d --build ui

# Open Prisma Studio for database inspection
studio:
    cd backend && prisma studio

# Run migrations (from backend directory)
migrate:
    cd backend && prisma migrate dev

# Reset database (development only)
db-reset:
    cd backend && prisma migrate reset --force

# Health check all services
health:
    docker compose ps --format "table {{.Names}}\t{{.Status}}"

# Stop and remove everything, then start fresh
restart:
    docker compose down
    docker compose up -d --build

# View specific container logs with line count
logs-tail lines="100":
    docker compose logs --tail {{ lines }}

# Execute command in API container
api-shell:
    docker compose exec api sh

# Execute command in UI container
ui-shell:
    docker compose exec users-app sh

# Execute command in postgres container
db-shell:
    docker compose exec postgres psql -U postgres -d userdb

# Display this help message
help:
    @just --list
