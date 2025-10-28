# 🚀 Быстрый запуск wg-easy (для вашего сервера)

> **Обновлено:** 28.10.2025  
> **Цель:** Запустить VPN за 10 минут без переустановки сервера

---

## ✅ Что изменилось

### Было: linuxserver/wireguard
- ❌ Не работает на OpenVZ (зависает)
- ❌ Нет веб-панели
- ❌ Ручное создание peers

### Стало: wg-easy
- ✅ Работает на OpenVZ (userspace)
- ✅ Веб-панель для управления
- ✅ Автоматические QR-коды
- ✅ Добавление клиентов через браузер

---

## 🎯 Шаг 1: Загрузить новый docker-compose.yml на сервер

```bash
# С вашего компьютера (PowerShell)
scp docker-compose.yml root@31.28.27.96:/opt/vpn/docker-compose.yml
```

Или вручную через SSH:

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Бэкап старого файла
cp docker-compose.yml docker-compose.yml.backup

# Создать новый docker-compose.yml
cat > docker-compose.yml <<'EOF'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - WG_HOST=31.28.27.96
      - PASSWORD=ИЗМЕНИТЕ_ЭТОТ_ПАРОЛЬ_123
      - WG_PORT=51820
      - WG_DEFAULT_ADDRESS=10.13.13.x
      - WG_DEFAULT_DNS=1.1.1.1,1.0.0.1
      - WG_ALLOWED_IPS=0.0.0.0/0,::/0
      - WG_PERSISTENT_KEEPALIVE=25
      - WG_MTU=1420
      - UI_TRAFFIC_STATS=true
      - UI_CHART_TYPE=1
      - LANG=ru
    volumes:
      - ./config:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    devices:
      - /dev/net/tun:/dev/net/tun
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped
EOF
```

**⚠️ ВАЖНО:** Замените `ИЗМЕНИТЕ_ЭТОТ_ПАРОЛЬ_123` на свой пароль!

---

## 🎯 Шаг 2: Очистить старую конфигурацию

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Бэкап существующих конфигов (если нужны)
tar -czf config.backup.$(date +%Y%m%d_%H%M%S).tar.gz config/

# Очистить config (wg-easy создаст новую структуру)
rm -rf config/*
```

---

## 🎯 Шаг 3: Открыть порт 51821 (веб-панель)

```bash
ssh root@31.28.27.96

# Проверить firewall
sudo ufw status

# Если UFW активен - открыть порт
sudo ufw allow 51821/tcp comment 'wg-easy web UI'

# Проверить
sudo ufw status | grep 51821
```

---

## 🎯 Шаг 4: Запустить wg-easy

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Загрузить образ и запустить
docker compose pull
docker compose up -d

# Подождать 10 секунд
sleep 10

# Проверить статус
docker ps | grep wg-easy

# Посмотреть логи
docker logs wg-easy
```

**Ожидаемый результат:**
```
✅ Container wg-easy Running
   Up 20 seconds
   0.0.0.0:51820->51820/udp
   0.0.0.0:51821->51821/tcp
```

---

## 🎯 Шаг 5: Открыть веб-панель

### В браузере откройте:
```
http://31.28.27.96:51821
```

### Введите пароль, который установили в docker-compose.yml

**Должны увидеть:**
- 🟢 Интерфейс wg-easy
- 📊 Статистика (пока пустая)
- ➕ Кнопка "New Client"

---

## 🎯 Шаг 6: Добавить первого клиента (себя)

### В веб-панели:

1. Нажмите **"+ New Client"**
2. Введите имя (например: `marina-laptop`)
3. Нажмите **"Create"**

### Появится клиент с кнопками:
- 📱 **QR Code** — покажет QR для мобильных
- 📄 **Config** — скачать .conf файл для десктопа
- ⬇️ **Download** — скачать конфигурацию

---

## 🎯 Шаг 7: Подключить ваше устройство

### Для ноутбука (Windows/Mac/Linux):

1. В веб-панели нажмите **Download** рядом с клиентом
2. Скачается файл `marina-laptop.conf`
3. Откройте приложение WireGuard
4. Нажмите **Import from file**
5. Выберите скачанный .conf
6. Нажмите **Activate**

### Для телефона:

1. Установите **WireGuard** из App Store/Google Play
2. В веб-панели нажмите **QR Code** рядом с клиентом
3. В приложении нажмите **"+"** → **Create from QR code**
4. Отсканируйте QR-код на экране
5. Нажмите **Activate**

---

## ✅ Проверка работы

### На устройстве с подключенным VPN:

1. Откройте https://whoer.net
2. Должны увидеть:
   - IP: `31.28.27.96` (IP вашего сервера)
   - Локация: Россия (или где сервер)

### На сервере проверьте подключения:

```bash
ssh root@31.28.27.96
docker exec wg-easy wg show
```

Должны увидеть:
```
interface: wg0
  peer: [ключ клиента]
    endpoint: [ваш IP]:[порт]
    allowed ips: 10.13.13.x/32
    latest handshake: 1 second ago  ← АКТИВНО!
    transfer: X KB received, Y KB sent
```

---

## 👥 Добавление остальных пользователей

### Для каждого человека:

1. Откройте веб-панель http://31.28.27.96:51821
2. Нажмите **"+ New Client"**
3. Введите имя (например: `grisha-phone`)
4. Отправьте QR-код или .conf файл человеку
5. Они сканируют/импортируют и подключаются

### Рекомендую создать:

```
marina-laptop
marina-iphone
grisha-laptop
grisha-phone
мама-phone
папа-laptop
...
```

---

## 🛠️ Управление через веб-панель

### Что можно делать:

- ➕ **Добавить клиента** — New Client
- 🗑️ **Удалить клиента** — кнопка Delete
- ✏️ **Переименовать** — кнопка Edit
- 📊 **Статистика** — график трафика
- 🔄 **Вкл/Выкл клиента** — Enable/Disable
- 📱 **QR-код** — показать заново

---

## 🚨 Если что-то не работает

### Контейнер не запустился:

```bash
docker logs wg-easy
```

Ищите ошибки в логах.

### Веб-панель не открывается:

```bash
# Проверьте порт
sudo ss -lntp | grep 51821

# Проверьте firewall
sudo ufw status | grep 51821

# Если закрыто - откройте
sudo ufw allow 51821/tcp
```

### Клиент не подключается:

```bash
# На сервере проверьте WireGuard интерфейс
docker exec wg-easy wg show

# Проверьте порт 51820
sudo ss -lunp | grep 51820
```

---

## 📋 Регулярные задачи

### Обновление образа (раз в месяц):

```bash
ssh root@31.28.27.96
cd /opt/vpn
docker compose pull
docker compose up -d
```

### Backup конфигураций (раз в неделю):

```bash
ssh root@31.28.27.96
cd /opt/vpn
tar -czf backup/config.$(date +%Y%m%d).tar.gz config/
```

### Проверка активных подключений:

```bash
ssh root@31.28.27.96
docker exec wg-easy wg show
```

---

## 🎉 Готово!

Теперь у вас:
- ✅ Работающий VPN на OpenVZ
- ✅ Веб-панель для управления
- ✅ Простое добавление пользователей
- ✅ QR-коды автоматом
- ✅ Статистика использования

**Следующий шаг:** Подключите всех друзей/семью и соберите фидбек! 🚀

---

**Вопросы?** См. [STRATEGY.md](STRATEGY.md) для долгосрочного плана.
