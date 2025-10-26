# WireGuard VPN Server

Проект для развертывания собственного VPN-сервера на базе WireGuard в Docker-контейнере с веб-панелью управления.

## 📋 Описание

Этот проект развертывает полнофункциональный VPN-сервер на вашем VPS с использованием:
- **WireGuard** - современный, быстрый и безопасный VPN протокол
- **wg-easy** - удобная веб-панель для управления клиентами
- **Docker** - контейнеризация для изоляции и удобства управления
- **Apache2** - reverse proxy с Basic Auth для защиты панели администратора

## 🖥️ Требования к серверу

- **ОС**: Ubuntu 22.04 x86_64 (или совместимая)
- **CPU**: 2+ ядра
- **RAM**: 2 GB+
- **Диск**: 20 GB+
- **Права**: root или sudo доступ

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────┐
│             VPS Server (31.28.27.96)        │
│                                             │
│  ┌──────────────┐    ┌──────────────────┐  │
│  │   Apache2    │────│  Docker Engine   │  │
│  │              │    │                  │  │
│  │ :80/443      │    │  ┌────────────┐  │  │
│  │ /vpn-admin ─────→ │  │  wg-easy   │  │  │
│  │              │    │  │            │  │  │
│  └──────────────┘    │  │ :51820/udp │◄─┼──┼─── VPN Clients
│                      │  │ :51821/tcp │  │  │
│                      │  └────────────┘  │  │
│                      └──────────────────┘  │
└─────────────────────────────────────────────┘
```

## 📦 Структура проекта

```
wireguard-vpn/
├── .env                          # Конфигурация переменных окружения
├── docker-compose.yml            # Docker Compose конфигурация
├── install.sh                    # Главный скрипт установки
├── README.md                     # Этот файл
├── apache-configs/
│   └── vpn-admin.conf            # Конфигурация Apache виртуального хоста
└── scripts/
    ├── install_docker.sh         # Установка Docker
    ├── setup_system.sh           # Настройка системы (IP forwarding, firewall)
    ├── deploy_vpn.sh             # Развертывание VPN контейнера
    └── setup_apache.sh           # Настройка Apache reverse proxy
```

## 🚀 Быстрый старт

### Способ 1: Автоматическая установка (рекомендуется)

1. **Загрузите проект на сервер:**
```bash
# На вашем локальном компьютере
scp -r wireguard-vpn root@31.28.27.96:/tmp/

# Подключитесь к серверу
ssh root@31.28.27.96

# Перейдите в каталог проекта
cd /tmp/wireguard-vpn
```

2. **Запустите установку:**
```bash
chmod +x install.sh scripts/*.sh
./install.sh
```

Скрипт автоматически:
- Установит Docker и Docker Compose Plugin
- Настроит IP forwarding и файрвол
- Развернет WireGuard VPN контейнер
- Настроит Apache reverse proxy с Basic Auth

### Способ 2: Пошаговая установка

#### Шаг 1: Установка Docker
```bash
chmod +x scripts/install_docker.sh
./scripts/install_docker.sh
newgrp docker  # Применить права группы
```

#### Шаг 2: Настройка системы
```bash
chmod +x scripts/setup_system.sh
./scripts/setup_system.sh
```

#### Шаг 3: Развертывание VPN
```bash
chmod +x scripts/deploy_vpn.sh
./scripts/deploy_vpn.sh
```

#### Шаг 4: Настройка Apache
```bash
chmod +x scripts/setup_apache.sh
./scripts/setup_apache.sh
```

## ⚙️ Конфигурация

### Переменные окружения (.env)

```bash
# IP-адрес или домен сервера
WG_HOST=31.28.27.96

# UDP порт для WireGuard
WG_PORT=51820

# Разрешенные IP (0.0.0.0/0 = весь трафик)
WG_ALLOWED_IPS=0.0.0.0/0,::/0

# DNS серверы для клиентов
WG_DEFAULT_DNS=1.1.1.1,9.9.9.9

# MTU
WG_MTU=1280

# Keepalive (секунды)
WG_PERSISTENT_KEEPALIVE=25

# Пароль веб-панели
ADMIN_PASSWORD=9334138
```

### Порты

- **51820/udp** - WireGuard VPN туннель
- **51821/tcp** - Веб-панель администратора (только localhost)
- **80/tcp** - Apache HTTP (публичный доступ к /vpn-admin)

## 🔐 Доступ к панели управления

После успешной установки:

**URL**: http://31.28.27.96/vpn-admin

**Basic Auth**:
- Логин: `admin`
- Пароль: (тот, что вы установили при выполнении `setup_apache.sh`)

**Панель WireGuard**:
- Пароль: `9334138`

## 📱 Подключение клиентов

1. Откройте веб-панель по адресу http://31.28.27.96/vpn-admin
2. Войдите используя Basic Auth и пароль панели
3. Нажмите "New Client" и введите имя клиента
4. Скачайте конфигурационный файл или отсканируйте QR-код
5. Импортируйте конфигурацию в WireGuard клиент:
   - **Windows/Mac/Linux**: https://www.wireguard.com/install/
   - **iOS**: WireGuard из App Store
   - **Android**: WireGuard из Google Play

## 🔧 Управление сервисом

### Просмотр статуса контейнера
```bash
docker ps
docker logs wg-easy
```

### Перезапуск VPN сервиса
```bash
cd /opt/vpn
docker compose restart
```

### Остановка VPN сервиса
```bash
cd /opt/vpn
docker compose down
```

### Запуск VPN сервиса
```bash
cd /opt/vpn
docker compose up -d
```

### Просмотр конфигурации WireGuard
```bash
ls -la /opt/vpn/config/
```

### Просмотр логов Apache
```bash
sudo tail -f /var/log/apache2/vpn-admin-access.log
sudo tail -f /var/log/apache2/vpn-admin-error.log
```

## 🔒 Настройка HTTPS (опционально)

После получения доменного имени вы можете настроить HTTPS:

1. **Установите Certbot:**
```bash
sudo apt install certbot python3-certbot-apache
```

2. **Получите SSL сертификат:**
```bash
sudo certbot --apache -d ваш-домен.ru
```

3. **Обновите конфигурацию:**
- Откройте `/etc/apache2/sites-available/vpn-admin.conf`
- Измените `ServerName` на ваш домен
- Certbot автоматически настроит SSL

## 🛡️ Безопасность

- ✅ Веб-панель защищена Basic Authentication
- ✅ Веб-панель доступна только через Apache reverse proxy
- ✅ Контейнер изолирован от основной системы
- ✅ WireGuard использует современное шифрование
- ⚠️ Рекомендуется настроить HTTPS для дополнительной защиты
- ⚠️ Используйте сложный пароль для Basic Auth
- ⚠️ Регулярно обновляйте систему и Docker образы

## 🐛 Устранение неполадок

### Контейнер не запускается
```bash
# Проверьте логи
docker logs wg-easy

# Проверьте порты
sudo ss -lunp | grep 51820
sudo ss -lnp | grep 51821
```

### Веб-панель недоступна
```bash
# Проверьте статус Apache
sudo systemctl status apache2

# Проверьте конфигурацию
sudo apache2ctl configtest

# Проверьте логи
sudo tail -f /var/log/apache2/error.log
```

### Клиенты не могут подключиться
```bash
# Проверьте IP forwarding
sudo sysctl net.ipv4.ip_forward
sudo sysctl net.ipv6.conf.all.forwarding

# Проверьте файрвол
sudo ufw status
sudo iptables -L -n -v
```

### Обновление контейнера
```bash
cd /opt/vpn
docker compose pull
docker compose up -d
```

## 📊 Мониторинг

### Просмотр подключенных клиентов
Через веб-панель: http://31.28.27.96/vpn-admin

### Статистика использования
```bash
docker stats wg-easy
```

### Использование диска
```bash
du -sh /opt/vpn/config/
```

## 🔄 Резервное копирование

### Создание бэкапа конфигурации
```bash
sudo tar -czf wireguard-backup-$(date +%Y%m%d).tar.gz /opt/vpn/config/
```

### Восстановление из бэкапа
```bash
cd /opt/vpn
sudo tar -xzf wireguard-backup-YYYYMMDD.tar.gz -C /
docker compose restart
```

## 📝 Примечания

- Этот VPN сервер не затрагивает существующие сервисы (Apache2, PM2, Childwatch)
- Все данные VPN хранятся в `/opt/vpn/config/`
- Контейнер автоматически перезапускается при перезагрузке сервера (`restart: unless-stopped`)

## 📚 Дополнительные ресурсы

- [WireGuard официальная документация](https://www.wireguard.com/)
- [wg-easy GitHub](https://github.com/WeeJeWel/wg-easy)
- [Docker документация](https://docs.docker.com/)

## 📄 Лицензия

MIT License

## 👤 Автор

DREDGV - https://github.com/DREDGV

## 🤝 Поддержка

Если у вас возникли проблемы, создайте Issue в GitHub репозитории.

---

**Версия**: 1.0.0
**Дата**: 2025-01-26
