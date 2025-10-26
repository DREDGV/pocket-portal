#!/bin/bash
# Главный скрипт установки WireGuard VPN на VPS

set -e

echo "========================================"
echo "WireGuard VPN - Полная установка"
echo "========================================"
echo ""

# Получение директории скриптов
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# 1. Проверка ОС
echo "→ Проверка операционной системы..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "✓ ОС: $NAME $VERSION"

    if [[ "$ID" != "ubuntu" ]]; then
        echo "⚠ ВНИМАНИЕ: Этот скрипт протестирован только на Ubuntu"
        read -p "Продолжить установку? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "✗ Не удалось определить операционную систему"
    exit 1
fi

# 2. Проверка существующих процессов
echo ""
echo "→ Проверка существующих процессов..."
if systemctl is-active --quiet apache2; then
    echo "✓ Apache2 запущен"
fi

if command -v pm2 &> /dev/null; then
    echo "✓ PM2 установлен"
    pm2 list
fi

echo ""
read -p "Продолжить установку WireGuard VPN? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# 3. Установка Docker
echo ""
bash "$SCRIPTS_DIR/install_docker.sh"

# Применение прав группы docker
echo ""
echo "→ Применение прав группы docker..."
newgrp docker << EONG
echo "✓ Права группы применены"
EONG

# 4. Настройка системы
echo ""
bash "$SCRIPTS_DIR/setup_system.sh"

# 5. Развертывание VPN
echo ""
bash "$SCRIPTS_DIR/deploy_vpn.sh"

# 6. Настройка Apache
echo ""
bash "$SCRIPTS_DIR/setup_apache.sh"

# 7. Финальная проверка
echo ""
echo "========================================"
echo "Финальная проверка"
echo "========================================"

echo "→ Проверка Docker контейнера..."
docker ps | grep wg-easy

echo ""
echo "→ Проверка порта WireGuard..."
sudo ss -lunp | grep 51820 || echo "⚠ Порт 51820 не прослушивается"

echo ""
echo "→ Проверка веб-панели..."
curl -I http://127.0.0.1:51821 2>/dev/null | head -n 1 || echo "⚠ Веб-панель не отвечает"

echo ""
echo "========================================"
echo "✓ Установка завершена!"
echo "========================================"
echo ""
echo "Доступ к панели администратора:"
echo "  URL: http://31.28.27.96/vpn-admin"
echo "  Логин: admin"
echo "  Пароль: (установленный при настройке Apache)"
echo ""
echo "Панель управления WireGuard:"
echo "  Пароль: 9334138"
echo ""
echo "Полезные команды:"
echo "  docker ps                    - статус контейнеров"
echo "  docker logs wg-easy          - логи WireGuard"
echo "  docker compose -f /opt/vpn/docker-compose.yml restart"
echo "                               - перезапуск VPN"
echo ""
