# Cybercare Stack

[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker)](https://docs.docker.com/compose/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-15-336791?logo=postgresql)](https://www.postgresql.org/)
[![FastAPI](https://img.shields.io/badge/fastapi-latest-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/python-3.11%20%7C%203.12-blue?logo=python)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Full stack orchestration for Cybercare services (Consumer + Propagator + PostgreSQL).

## Quick Start

```bash
# Clone and navigate
git clone https://github.com/alfon96/cybercare-stack.git
cd cybercare-stack

# Create directories
mkdir -p consumer propagator

# Create root environment
cat > .env << 'EOF'
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=cybercare
EOF

# Create consumer config
cat > consumer/.env << 'EOF'
APP_PORT=8000
DATABASE_URL=postgresql+asyncpg://user:password@postgres:5432/cybercare
EOF

# Create propagator config
cat > propagator/.env << 'EOF'
PERIOD_IN_SECONDS=2
HTTP_POST_ENDPOINT=http://consumer:8000/event
PAYLOAD_FILE_PATH=/app/payloads.json
EOF

# Create sample payloads
cat > propagator/payloads.json << 'EOF'
[
  {"event_type":"user_joined","event_payload":"Alice"},
  {"event_type":"user_joined","event_payload":"Bob"},
  {"event_type":"message","event_payload":"Hello World"}
]
EOF

# Start all services
make up
```

## Try It Out

```bash
make help          # Show all available commands
make status        # Show service status
make logs          # View real-time logs
make test-health   # Check if services are responding
make db-count      # Count events stored in database
```

## Architecture

- **PostgreSQL** (port 5432): Data storage
- **Consumer** (port 8000): FastAPI event consumer
- **Propagator**: Sends events to consumer every 5 seconds

## Commands

**Core:**

```bash
make up            # Start all services
make down          # Stop all services
make restart       # Restart all services
make clean         # Stop and remove all data
```

**Observability:**

```bash
make status        # Show running services
make logs          # View all service logs (follow)
make logs-consumer # View consumer logs only
make logs-propagator # View propagator logs only
```

**Database:**

```bash
make db-count      # Count total events
make db-events     # Show last 20 events
make db-shell      # Open PostgreSQL interactive shell
make db-reset      # Delete all events
```

**Testing:**

```bash
make test-health   # Check service health
make test-api      # Send test event to consumer
```

## API

Consumer API available at `http://localhost:8000`

**Health Check:**

```bash
curl http://localhost:8000/health
```

**Send Event:**

```bash
curl -X POST http://localhost:8000/event \
  -H "Content-Type: application/json" \
  -d '{"event_type":"test","event_payload":"Hello"}'
```

## Troubleshooting

**Services won't start:**

```bash
make logs          # Check error messages
```

**Database issues:**

```bash
make db-shell      # Connect to database and run SQL
SELECT * FROM events;
```

**Reset everything:**

```bash
make clean
make up
```
