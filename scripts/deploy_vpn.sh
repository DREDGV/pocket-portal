#!/bin/bash
# Скрипт развертывания WireGuard VPN в Docker

set -e

VPN_DIR="/opt/vpn"

echo "========================================"
echo "Развертывание WireGuard VPN"
echo "========================================"

# 1. Создание каталога проекта
echo "→ Создание каталога $VPN_DIR..."
sudo mkdir -p $VPN_DIR/config
sudo chown -R $USER:$USER $VPN_DIR

# 2. Копирование файлов
echo "→ Копирование конфигурационных файлов..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cp "$PROJECT_DIR/docker-compose.yml" $VPN_DIR/

echo "✓ Файлы скопированы в $VPN_DIR"

# 3. Запуск контейнера
echo ""
echo "→ Запуск Docker-контейнера WireGuard..."
cd $VPN_DIR
docker compose up -d

# 4. Ожидание запуска контейнера
echo "→ Ожидание запуска контейнера..."
sleep 5

# 5. Проверка статуса
echo ""
echo "→ Проверка статуса контейнера..."
docker ps | grep wireguard

echo ""
echo "✓ WireGuard VPN успешно развернут!"
echo ""
echo "Проверьте доступность:"
echo "  - WireGuard порт: 51820/udp"
echo ""
echo "Логи контейнера:"
echo "  docker logs wireguard"
echo ""
echo "Просмотр конфигураций клиентов:"
echo "  ls -la $VPN_DIR/config/"
