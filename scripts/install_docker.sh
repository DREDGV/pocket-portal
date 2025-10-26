#!/bin/bash
# Скрипт установки Docker и Docker Compose Plugin

set -e

echo "========================================="
echo "Установка Docker и Docker Compose Plugin"
echo "========================================="

# Проверка наличия Docker
if command -v docker &> /dev/null; then
    echo "✓ Docker уже установлен (версия $(docker --version))"

    # Проверка наличия compose plugin
    if docker compose version &> /dev/null; then
        echo "✓ Docker Compose Plugin уже установлен (версия $(docker compose version))"
        exit 0
    fi
fi

echo "→ Обновление списка пакетов..."
sudo apt update

echo "→ Установка необходимых зависимостей..."
sudo apt install -y ca-certificates curl gnupg

echo "→ Создание каталога для GPG ключа..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "→ Добавление GPG ключа Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "→ Добавление репозитория Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "→ Обновление списка пакетов с новым репозиторием..."
sudo apt update

echo "→ Установка Docker Engine и Docker Compose Plugin..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "→ Добавление текущего пользователя в группу docker..."
sudo usermod -aG docker $USER

echo ""
echo "✓ Docker и Docker Compose Plugin успешно установлены!"
echo ""
echo "ВАЖНО: Для применения изменений группы выполните:"
echo "  newgrp docker"
echo "  или перезайдите в систему"
echo ""
echo "Версии:"
docker --version
docker compose version
