# Docker Compose Usage Guide

This project uses Docker Compose to create a consistent development environment.

## Prerequisites

- Docker Engine installed
- Docker Compose plugin installed

## Quick Start

Start the development container:
```bash
docker-compose up -d
```

Stop the development container:
```bash
docker-compose down
```

## Accessing the Environment

The container runs on port 8080. You can access it via:
- Web applications: http://localhost:8080
- Terminal access: `docker-compose exec ubuntu-dev bash`

## Key Features

- **Port Mapping**: Port 8080 is mapped from host to container
- **Volume Mounting**: Current directory is mounted to `/app` in container
- **Persistent Storage**: Changes to the host directory are reflected in the container
- **Interactive Shell**: Container stays running with `tail -f /dev/null`

## Useful Commands

```bash
# View container logs
docker-compose logs

# Execute commands in the container
docker-compose exec ubuntu-dev ls -la

# Restart the container
docker-compose restart

# View running containers
docker-compose ps
```

## Development Workflow

1. Run `docker-compose up -d` to start the environment
2. Make code changes on your host machine
3. See changes reflected in the container instantly
4. Use `docker-compose exec ubuntu-dev bash` for terminal access
5. Run `docker-compose down` when finished