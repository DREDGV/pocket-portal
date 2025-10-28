# 🌀 Pocket Portal

> Your personal gateway to secure internet access

**Pocket Portal** - компактный и безопасный VPN-сервер, работающий в Docker-контейнере. Идеально подходит для OpenVZ/контейнерной виртуализации.

[![Status](https://img.shields.io/badge/status-active-success)](https://github.com/DREDGV/pocket-portal)
[![Outline](https://img.shields.io/badge/Outline-Shadowsocks-blue)](https://getoutline.org/)
[![Docker](https://img.shields.io/badge/Docker-shadowbox-2496ED?logo=docker)](https://github.com/Jigsaw-Code/outline-server)

> ✅ **РАБОЧАЯ ВЕРСИЯ (28.10.2025):** Используется **Outline VPN** (Shadowsocks) из-за ограничений OpenVZ. См. [OUTLINE_QUICKSTART.md](OUTLINE_QUICKSTART.md)
> 
> ⚠️ **О WireGuard:** WireGuard несовместим с OpenVZ без дополнительной настройки хоста. Подробности в [OPENVZ_ISSUES.md](OPENVZ_ISSUES.md)

---

## ✨ Особенности

- 🚀 **Быстрый и надежный** - протокол Shadowsocks
- 🔒 **Безопасный** - современное шифрование AES-256-GCM
- 📦 **Контейнеризированный** - изолированный Docker-контейнер
- 🌐 **OpenVZ совместимый** - работает на любой виртуализации
- 🖥️ **GUI управление** - Outline Manager для десктопа
- 📱 **Мультиплатформенный** - поддержка iOS, Android, Windows, macOS, Linux
- ⚡ **Лёгкий** - минимальное использование ресурсов
- 📊 **Статистика** - графики использования данных
- 🎭 **Обфускация** - трафик выглядит как обычный HTTPS

---

## 🎯 Что внутри

- **Сервер**: Ubuntu 22.04 (OpenVZ)
- **VPN**: Outline (Shadowsocks protocol)
- **Образ**: quay.io/outline/shadowbox:stable
- **Управление**: Outline Manager (GUI app)
- **Автообновление**: Watchtower
- **Шифрование**: AES-256-GCM
- **DNS**: Auto-configured

---

## 🚀 Быстрый старт

> 📖 **Полная инструкция:** См. [OUTLINE_QUICKSTART.md](OUTLINE_QUICKSTART.md)

### Шаг 1: Установить Outline Manager

Скачайте с официального сайта: https://getoutline.org/get-started/#step-1

### Шаг 2: Подключить сервер

В Outline Manager вставьте этот API ключ:

```json
{
  "apiUrl": "https://31.28.27.96:29789/mDyT9zVKwCdpmNzDqkoSHQ",
  "certSha256": "88F316104BC94E8BFD4DDB6AABF51FEB9D068FD2D35E0B68AD753FCBD98F5C00"
}
```

### Шаг 3: Создать ключи доступа

1. В Outline Manager нажмите "+ ADD A NEW KEY"
2. Назовите ключ (например: "My Phone")
3. Скопируйте ключ или покажите QR-код

### Шаг 4: Подключиться

1. Установите **Outline Client** на устройство
2. Отсканируйте QR-код или вставьте ключ
3. Нажмите "Connect"

**Готово!** 🎉

---

## 📱 Установка клиентов

### Windows / macOS / Linux

1. Скачайте Outline Client: https://getoutline.org/get-started/#step-3
2. Установите приложение
3. Вставьте ключ доступа из Manager
4. Нажмите "Connect"

### Android

1. Установите [Outline](https://play.google.com/store/apps/details?id=org.outline.android.client) из Google Play
2. Откройте приложение
3. Отсканируйте QR-код или вставьте ключ
4. Нажмите "Connect"

### iOS (iPhone/iPad)

1. Установите [Outline](https://apps.apple.com/app/outline-app/id1356177741) из App Store
2. Откройте приложение
3. Отсканируйте QR-код или вставьте ключ
4. Нажмите "Connect"

---

## 🔧 Управление

### Через Outline Manager (GUI)

- ➕ **Добавить пользователя:** Кнопка "+ ADD A NEW KEY"
- 🗑️ **Удалить пользователя:** Кнопка "DELETE"
- ✏️ **Переименовать:** Кликните на имя ключа
- � **Статистика:** Графики использования данных
- ⚙️ **Настройки:** Settings → Data limit

### Через SSH (advanced)

#### Просмотр логов

```bash
docker logs wg-easy
docker logs -f wg-easy  # live logs
```

#### Проверка активных подключений

```bash
docker exec wg-easy wg show
```

#### Перезапуск

```bash
cd /opt/vpn
docker compose restart
```

#### Обновление образа

```bash
cd /opt/vpn
docker compose pull
docker compose up -d
```

---

## 📊 Текущая конфигурация

| Клиент | IP-адрес | Статус |
|--------|----------|--------|
| phone-grisha | 10.13.13.2 | ✅ Активен |
### Через SSH (advanced)

```bash
# Подключиться к серверу
ssh root@31.28.27.96

# Проверить статус
docker ps | grep shadowbox

# Посмотреть логи
docker logs shadowbox

# Перезапустить сервер
docker restart shadowbox

# Получить API ключ (если потеряли)
cat /opt/outline/access.txt
```

---

## 📊 Статус сервера

| Компонент | Статус | Порт |
|-----------|--------|------|
| Outline Shadowbox | ✅ Работает | Dynamic |
| Management API | ✅ Работает | 29789/tcp |
| Watchtower | ✅ Работает | - |

### Активные подключения

Статистику можно посмотреть в **Outline Manager**.

---

## 🛡️ Безопасность

- ✅ Современное шифрование (AES-256-GCM)
- ✅ Обфускация трафика (выглядит как HTTPS)
- ✅ Firewall настроен (UFW)
- ✅ Автоматические обновления (Watchtower)
- ✅ Контейнерная изоляция

**Важно:** Никогда не публикуйте API ключ управления! См. [SECURITY.md](SECURITY.md) для деталей.

---

## 📚 Документация

### Основные документы

- **[OUTLINE_QUICKSTART.md](OUTLINE_QUICKSTART.md)** - 🚀 Полное руководство по Outline VPN
- **[OPENVZ_ISSUES.md](OPENVZ_ISSUES.md)** - 📋 Детальный отчет о проблемах OpenVZ и WireGuard
- **[SECURITY.md](SECURITY.md)** - 🔐 Инструкции по безопасности
- **[STRATEGY.md](STRATEGY.md)** - 🎯 Стратегия развития проекта

### Дополнительные документы

- **[ROADMAP.md](ROADMAP.md)** - 🗺️ Концепция и план развития
- **[DEVELOPMENT_PATHS.md](DEVELOPMENT_PATHS.md)** - 🛤️ Варианты развития
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - 🤝 Как участвовать в развитии

---

## 🗺️ Куда движется проект?

**Текущий фокус (2025-2026):** Personal VPN для семьи и друзей (10-20 человек)

Мы развиваемся поэтапно:

1. **Сейчас:** ✅ Стабильный VPN на OpenVZ (Outline)
2. **Через 3-6 мес:** Сбор фидбека, улучшения, документация
3. **Через 6-12 мес:** Оценка спроса на коммерциализацию

Подробнее см. **[STRATEGY.md](STRATEGY.md)** и **[ROADMAP.md](ROADMAP.md)**

---

## 🐛 Устранение неполадок

### Не могу подключиться к серверу

```bash
# Проверить статус контейнера
ssh root@31.28.27.96 "docker ps | grep shadowbox"

# Посмотреть логи
ssh root@31.28.27.96 "docker logs shadowbox"

# Проверить порты
ssh root@31.28.27.96 "netstat -tulpn | grep LISTEN"
```

### Outline Manager не принимает API ключ

1. Убедитесь, что вставили **весь JSON** (обе строки)
2. Проверьте отсутствие лишних пробелов
3. Попробуйте одной строкой:
   ```json
   {"apiUrl":"https://31.28.27.96:29789/mDyT9zVKwCdpmNzDqkoSHQ","certSha256":"88F316104BC94E8BFD4DDB6AABF51FEB9D068FD2D35E0B68AD753FCBD98F5C00"}
   ```

### Потерял API ключ

```bash
ssh root@31.28.27.96 "cat /opt/outline/access.txt"
```

### Медленная скорость

1. Проверьте пинг до сервера: `ping 31.28.27.96`
2. Проверьте нагрузку: `ssh root@31.28.27.96 "top -bn1 | head -20"`
3. Попробуйте другой регион (если есть резервный сервер)

Полное руководство: **[OUTLINE_QUICKSTART.md](OUTLINE_QUICKSTART.md)**

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
