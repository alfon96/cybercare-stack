.PHONY: up down logs restart stop clean ps status help db-shell db-events db-count db-reset logs-consumer logs-propagator test-api test-health

help:
	@echo "Available commands:"
	@echo "  up               - Start all services (detached)"
	@echo "  down             - Stop and remove services"
	@echo "  restart          - Restart all services"
	@echo "  stop             - Stop all services"
	@echo "  clean            - Remove services and volumes"
	@echo "  status           - Show container status"
	@echo "  logs             - Tail all logs"
	@echo "  logs-consumer    - Tail consumer logs"
	@echo "  logs-propagator  - Tail propagator logs"
	@echo "  db-shell         - Open psql shell"
	@echo "  db-events        - Show last 20 events"
	@echo "  db-count         - Show events count"
	@echo "  db-reset         - Clear all events"
	@echo "  test-health      - Check consumer /health"
	@echo "  test-api         - Send test event to API"

# Core
up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

stop:
	docker compose stop

clean:
	docker compose down -v

# Observability
status:
	docker compose ps

logs:
	docker compose logs -f

logs-consumer:
	docker compose logs -f consumer

logs-propagator:
	docker compose logs -f propagator

# Database
db-shell:
	docker compose exec postgres psql -U user -d cybercare

db-events:
	docker compose exec postgres psql -U user -d cybercare -c "SELECT * FROM events ORDER BY created_at DESC LIMIT 20;"

db-count:
	docker compose exec postgres psql -U user -d cybercare -c "SELECT COUNT(*) as total_events FROM events;"

db-reset:
	docker compose exec postgres psql -U user -d cybercare -c "DELETE FROM events; SELECT 'All events deleted' as status;"

# Testing
test-health:
	@echo "Testing Consumer health..."
	@curl -s http://localhost:8000/health | jq . || echo "Consumer not responding"

test-api:
	@echo "Sending test event..."
	@curl -s -X POST http://localhost:8000/event \
		-H "Content-Type: application/json" \
		-d '{"event_type":"test_event","event_payload":"test"}' | jq . || echo "Failed to send event"
