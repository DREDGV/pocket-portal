#!/bin/bash
# Скрипт настройки системы для WireGuard VPN

set -e

echo "========================================"
echo "Настройка системы для WireGuard VPN"
echo "========================================"

# 1. Настройка IP forwarding
echo "→ Настройка IP forwarding..."
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-vpn-forwarding.conf > /dev/null
echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.d/99-vpn-forwarding.conf > /dev/null

echo "→ Применение настроек sysctl..."
sudo sysctl --system

# 2. Настройка файрвола
echo "→ Проверка статуса UFW..."
if sudo ufw status | grep -q "Status: active"; then
    echo "→ UFW активен, добавляем правило для порта 51820/udp..."
    sudo ufw allow 51820/udp
    echo "✓ Правило файрвола добавлено"
else
    echo "⚠ UFW не активен. Если используется другой файрвол, добавьте правило вручную:"
    echo "  Разрешить входящий трафик на порт 51820/udp"
fi

# 3. Проверка доступности портов
echo ""
echo "→ Проверка занятости портов..."

if sudo ss -lunp | grep -q ":51820 "; then
    echo "✗ ОШИБКА: Порт 51820/udp уже занят!"
    sudo ss -lunp | grep ":51820 "
    exit 1
else
    echo "✓ Порт 51820/udp свободен"
fi

if sudo ss -lnp | grep -q ":51821 "; then
    echo "✗ ОШИБКА: Порт 51821/tcp уже занят!"
    sudo ss -lnp | grep ":51821 "
    exit 1
else
    echo "✓ Порт 51821/tcp свободен"
fi

echo ""
echo "✓ Система успешно настроена для WireGuard VPN!"
