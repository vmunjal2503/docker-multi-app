.PHONY: up down logs health ssl-generate restart build clean

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

health:
	@bash scripts/health-check.sh

ssl-generate:
	@bash scripts/setup-ssl.sh

restart:
	docker compose restart

build:
	docker compose build --no-cache

clean:
	docker compose down -v --rmi all --remove-orphans
