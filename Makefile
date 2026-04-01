.PHONY: setup start stop restart logs

setup:
	@echo "→ Running Ollama setup..."
	@chmod +x setup.sh && ./setup.sh
	@echo "→ Starting Docker services..."
	@docker compose build
	@echo "→ Done. System is ready."

start:
	@launchctl bootstrap gui/$(shell id -u) ~/Library/LaunchAgents/com.ollama.plist 2>/dev/null || true
	@docker compose start

stop:
	@launchctl bootout gui/$(shell id -u) ~/Library/LaunchAgents/com.ollama.plist 2>/dev/null || true
	@docker compose stop

restart: stop start

logs:
	@docker compose logs -f &
	@tail -f ~/ollama.log
