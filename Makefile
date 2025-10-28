.PHONY: help up down restart logs status peers add-peer show-qr update clean

# Цвета для вывода
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Показать справку
	@echo "$(GREEN)Pocket Portal - WireGuard VPN Management$(NC)"
	@echo ""
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

up: ## Запустить VPN
	@echo "$(GREEN)→ Запуск WireGuard VPN...$(NC)"
	cd /opt/vpn && docker compose up -d
	@sleep 2
	@docker ps | grep wireguard || echo "$(YELLOW)⚠ Контейнер не запущен$(NC)"

down: ## Остановить VPN
	@echo "$(YELLOW)→ Остановка WireGuard VPN...$(NC)"
	cd /opt/vpn && docker compose down

restart: ## Перезапустить VPN
	@echo "$(GREEN)→ Перезапуск WireGuard VPN...$(NC)"
	cd /opt/vpn && docker compose restart
	@sleep 2
	@docker ps | grep wireguard

logs: ## Показать логи (Ctrl+C для выхода)
	@echo "$(GREEN)→ Логи WireGuard (live):$(NC)"
	docker logs -f wireguard

status: ## Показать статус и активные подключения
	@echo "$(GREEN)→ Статус контейнера:$(NC)"
	@docker ps | grep wireguard || echo "$(YELLOW)Контейнер не запущен$(NC)"
	@echo ""
	@echo "$(GREEN)→ Активные подключения:$(NC)"
	@docker exec wireguard wg show 2>/dev/null || echo "$(YELLOW)Нет активных подключений$(NC)"

peers: ## Список всех клиентов
	@echo "$(GREEN)→ Доступные клиенты:$(NC)"
	@ls -1 /opt/vpn/config/ | grep peer_ | sed 's/peer_/  - /'

add-peer: ## Добавить нового клиента (использование: make add-peer NAME=new-client)
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)Ошибка: укажите имя клиента$(NC)"; \
		echo "Использование: make add-peer NAME=new-client"; \
		exit 1; \
	fi
	@echo "$(GREEN)→ Добавление клиента: $(NAME)$(NC)"
	@echo "Откройте docker-compose.yml и добавьте '$(NAME)' в PEERS"
	@echo "Затем выполните: make restart"

show-qr: ## Показать QR-код клиента (использование: make show-qr NAME=phone-grisha)
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)Ошибка: укажите имя клиента$(NC)"; \
		echo "Использование: make show-qr NAME=phone-grisha"; \
		echo ""; \
		echo "Доступные клиенты:"; \
		make peers; \
		exit 1; \
	fi
	@echo "$(GREEN)→ QR-код для клиента: $(NAME)$(NC)"
	@docker exec wireguard cat /config/peer_$(NAME)/peer_$(NAME).conf | qrencode -t ansiutf8

update: ## Обновить образ WireGuard
	@echo "$(GREEN)→ Обновление образа WireGuard...$(NC)"
	cd /opt/vpn && docker compose pull
	@echo "$(GREEN)→ Перезапуск с новым образом...$(NC)"
	cd /opt/vpn && docker compose up -d

clean: ## Остановить и удалить контейнер (конфиги останутся)
	@echo "$(YELLOW)→ Остановка и удаление контейнера...$(NC)"
	cd /opt/vpn && docker compose down -v
	@echo "$(GREEN)✓ Контейнер удален (конфиги сохранены в /opt/vpn/config/)$(NC)"

# По умолчанию показываем справку
.DEFAULT_GOAL := help
