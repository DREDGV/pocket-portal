# 🌀 Pocket Portal

> Your personal gateway to secure internet access

**Pocket Portal** - компактный и безопасный VPN-сервер на базе WireGuard, работающий в Docker-контейнере. Идеально подходит для OpenVZ/контейнерной виртуализации.

[![Status](https://img.shields.io/badge/status-deployed-success)](https://github.com/DREDGV/pocket-portal)
[![WireGuard](https://img.shields.io/badge/WireGuard-userspace-blue)](https://www.wireguard.com/)
[![Docker](https://img.shields.io/badge/Docker-linuxserver-2496ED?logo=docker)](https://hub.docker.com/r/linuxserver/wireguard)

---

## ✨ Особенности

- 🚀 **Быстрый и современный** - протокол WireGuard
- 🔒 **Безопасный** - современное шифрование ChaCha20-Poly1305
- 📦 **Контейнеризированный** - изолированный Docker-контейнер
- 🌐 **OpenVZ совместимый** - работает в userspace режиме
- 📱 **Мультиплатформенный** - поддержка iOS, Android, Windows, macOS, Linux
- ⚡ **Лёгкий** - минимальное использование ресурсов

---

## 🎯 Что внутри

- **Сервер**: Ubuntu 22.04 (OpenVZ)
- **Образ**: linuxserver/wireguard
- **Порт**: 51820/udp
- **Сеть**: 10.13.13.0/24
- **DNS**: Cloudflare (1.1.1.1) + Quad9 (9.9.9.9)

---

## 🚀 Быстрый старт

### Требования

- VPS с Ubuntu 22.04
- Docker и Docker Compose
- Открытый порт 51820/udp

### Развертывание

```bash
# 1. Клонировать репозиторий
git clone https://github.com/DREDGV/pocket-portal.git
cd pocket-portal

# 2. Отредактировать переменные окружения (опционально)
nano .env

# 3. Запустить
docker compose up -d

# 4. Проверить статус
docker ps
docker logs wireguard
```

---

## 📱 Подключение клиентов

### Для мобильных устройств

1. Установите приложение **WireGuard** из App Store или Google Play
2. Отсканируйте QR-код:

```bash
# На сервере
qrencode -t ansiutf8 < /opt/vpn/config/peer_phone-grisha/peer_phone-grisha.conf
```

### Для десктопа

1. Установите [WireGuard Desktop](https://www.wireguard.com/install/)
2. Скачайте конфигурацию:

```bash
scp root@31.28.27.96:/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.conf .
```

3. Импортируйте файл в приложение

---

## 🔧 Управление

### Просмотр логов

```bash
docker logs wireguard
docker logs -f wireguard  # live logs
```

### Перезапуск

```bash
docker compose restart
```

### Добавить нового клиента

См. [SETUP_COMPLETE.md](SETUP_COMPLETE.md) для подробных инструкций.

---

## 📊 Текущая конфигурация

| Клиент | IP-адрес | Статус |
|--------|----------|--------|
| phone-grisha | 10.13.13.2 | ✅ Активен |
| laptop-grisha | 10.13.13.3 | ✅ Активен |
| marina-iphone | 10.13.13.4 | ✅ Активен |

---

## 🛡️ Безопасность

- ✅ Современное шифрование (ChaCha20-Poly1305)
- ✅ DNS через туннель (предотвращает утечки)
- ✅ Firewall настроен (UFW)
- ✅ Приватные ключи защищены
- ✅ Контейнерная изоляция

**Важно:** Никогда не публикуйте содержимое директории `config/` - там хранятся приватные ключи!

---

## 📚 Документация

- [SETUP_COMPLETE.md](SETUP_COMPLETE.md) - Полная документация по установке
- [docker-compose.yml](docker-compose.yml) - Конфигурация контейнера
- [WireGuard Documentation](https://www.wireguard.com/) - Официальная документация

---

## 🐛 Устранение неполадок

### Контейнер не запускается

```bash
# Проверить логи
docker logs wireguard

# Проверить порты
sudo ss -lunp | grep 51820
```

### Клиент не подключается

```bash
# Проверить IP forwarding
sudo sysctl net.ipv4.ip_forward

# Проверить файрвол
sudo ufw status
```

### Обновить контейнер

```bash
cd /opt/vpn
docker compose pull
docker compose up -d
```

---

## 🤝 Вклад

Если у вас есть предложения по улучшению - создавайте Issues или Pull Requests!

---

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE)

---

## 👤 Автор

**DREDGV** - [GitHub](https://github.com/DREDGV)

---

## ⭐ Благодарности

- [WireGuard](https://www.wireguard.com/) - за отличный VPN протокол
- [LinuxServer.io](https://www.linuxserver.io/) - за Docker образ
- [Claude](https://claude.ai) - за помощь в настройке

---

<p align="center">
  <sub>Создано с ❤️ для приватного и безопасного доступа в интернет</sub>
</p>

<p align="center">
  🌀 <strong>Pocket Portal</strong> - Your personal gateway to secure internet
</p>
