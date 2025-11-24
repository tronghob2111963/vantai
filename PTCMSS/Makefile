.PHONY: help up down restart logs build clean reset status shell-backend shell-frontend shell-mysql

help: ## Show this help message
	@echo "PTCMSS Docker Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## Show logs (use: make logs SERVICE=backend)
	@if [ -z "$(SERVICE)" ]; then \
		docker-compose logs -f; \
	else \
		docker-compose logs -f $(SERVICE); \
	fi

build: ## Rebuild all services
	docker-compose up -d --build

build-backend: ## Rebuild only backend
	docker-compose up -d --build backend

build-frontend: ## Rebuild only frontend
	docker-compose up -d --build frontend

clean: ## Stop and remove containers, networks
	docker-compose down

reset: ## Reset everything (including volumes)
	docker-compose down -v
	docker-compose up -d --build

status: ## Show status of all services
	docker-compose ps

shell-backend: ## Access backend container shell
	docker exec -it ptcmss-backend sh

shell-frontend: ## Access frontend container shell
	docker exec -it ptcmss-frontend sh

shell-mysql: ## Access MySQL shell
	docker exec -it ptcmss-mysql mysql -uroot -proot ptcmss_db

health: ## Check health of all services
	@echo "Backend Health:"
	@curl -s http://localhost:8080/actuator/health | jq . || echo "Backend not ready"
	@echo "\nFrontend Health:"
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 || echo "Frontend not ready"
	@echo "\nMySQL Health:"
	@docker exec ptcmss-mysql mysqladmin ping -h localhost -uroot -proot 2>/dev/null && echo "MySQL is alive" || echo "MySQL not ready"

init: ## Initialize project (copy .env.example to .env)
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created. Please update it with your configuration."; \
	else \
		echo ".env file already exists."; \
	fi
