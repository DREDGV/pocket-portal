# ⚠️ ВАЖНО: Проблема с ротацией ключей на OpenVZ

## 🔴 Обнаружена проблема

При попытке ротации ключей обнаружено, что образ **linuxserver/wireguard** не работает корректно на OpenVZ виртуализации.

### Причина:

Скрипт инициализации контейнера проверяет наличие модуля WireGuard в ядре:

```bash
# /etc/s6-overlay/s6-rc.d/init-wireguard-module/run
if ip link add dev test type wireguard; then
    # Модуль найден - продолжаем
else
    echo "**** Module not found ****"
    sleep infinity  # ← ЗАВИСАЕТ ЗДЕСЬ
fi
```

На OpenVZ модуля нет, поэтому контейнер зависает и **НЕ генерирует peer-конфигурации**.

---

## ✅ Решения

### Вариант 1: Переключиться на wg-easy (Рекомендую)

**wg-easy** использует **wireguard-go** (userspace) и отлично работает на OpenVZ.

#### Плюсы:
- ✅ Работает на OpenVZ
- ✅ Веб-панель для управления (UI)
- ✅ Автоматическая генерация QR-кодов
- ✅ Простое добавление/удаление peers

#### Минусы:
- ❌ Другая конфигурация
- ❌ Нужно переписать docker-compose.yml
- ❌ Порт 51821 для веб-панели

#### Как перейти:

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Создайте бэкап текущих конфигов (если нужны)
cp -r config config.backup.$(date +%Y%m%d)

# Замените docker-compose.yml на wg-easy
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - WG_HOST=31.28.27.96
      - PASSWORD=ВАШ_БЕЗОПАСНЫЙ_ПАРОЛЬ
      - WG_PORT=51820
      - WG_DEFAULT_ADDRESS=10.13.13.x
      - WG_DEFAULT_DNS=1.1.1.1,1.0.0.1
      - WG_ALLOWED_IPS=0.0.0.0/0,::/0
      - WG_PERSISTENT_KEEPALIVE=25
    volumes:
      - ./config:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"  # Веб-панель
    devices:
      - /dev/net/tun:/dev/net/tun
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped
EOF

# Запустите
docker compose up -d

# Откройте веб-панель
echo "Веб-панель: http://31.28.27.96:51821"
echo "Пароль: ВАШ_БЕЗОПАСНЫЙ_ПАРОЛЬ"
```

---

### Вариант 2: Патчить linuxserver/wireguard (Сложнее)

Создать свой Dockerfile с патчем для OpenVZ:

```dockerfile
FROM linuxserver/wireguard:latest

# Патчим скрипт инициализации для OpenVZ
RUN sed -i 's/sleep infinity/echo "OpenVZ detected, skipping module check"/' \
    /etc/s6-overlay/s6-rc.d/init-wireguard-module/run && \
    echo "wireguard-go" > /etc/wireguard/wireguard-implementation

# Устанавливаем wireguard-go
RUN apk add --no-cache wireguard-tools-wg-quick wireguard-go
```

Затем в docker-compose.yml:

```yaml
services:
  wireguard:
    build: .  # Вместо image: linuxserver/wireguard:latest
    # ... остальная конфигурация
```

**Минусы:**
- ❌ Поддержка своего форка
- ❌ Может сломаться при обновлении upstream
- ❌ Требует регулярной синхронизации

---

### Вариант 3: Использовать родной WireGuard (Без Docker)

Установить WireGuard напрямую на host:

```bash
# Установка
sudo apt update && sudo apt install wireguard qrencode -y

# Генерация ключей сервера
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

# Конфигурация
sudo nano /etc/wireguard/wg0.conf

# Запуск
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

**Минусы:**
- ❌ Нет изоляции Docker
- ❌ Сложнее менеджмент
- ❌ Ручное создание peer-конфигов

---

## 🎯 Моя рекомендация: wg-easy

### Почему:

1. **Работает из коробки на OpenVZ** — никаких патчей
2. **Веб-панель** — добавление/удаление peers через браузер
3. **QR-коды генерируются автоматически** — удобно для мобильных
4. **Активно поддерживается** — регулярные обновления

### Следующие шаги:

1. **Переключитесь на wg-easy** (инструкция выше)
2. **Добавьте peers через веб-панель**
   - Откройте http://31.28.27.96:51821
   - Введите пароль
   - Нажмите "+ Add Client"
   - Скачайте конфиг или покажите QR

3. **Обновите устройства** новыми конфигурациями

---

## 📝 Альтернатива: Миграция на KVM VPS

Если хотите остаться на linuxserver/wireguard — рассмотрите миграцию на KVM-виртуализацию:

**Преимущества KVM:**
- ✅ Полный доступ к ядру
- ✅ Модуль WireGuard работает нативно
- ✅ Лучшая производительность
- ✅ Больше возможностей для оптимизации

**Провайдеры с KVM:**
- Hetzner Cloud (от €4.51/мес)
- DigitalOcean (от $6/мес)
- Vultr (от $6/мес)
- Linode (от $5/мес)

---

## ⚡ Быстрый фикс (для теста)

Если нужно срочно проверить работу WireGuard на текущем сервере:

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Остановите текущий контейнер
docker compose down

# Используйте временно wg-easy
docker run -d \
  --name=wg-easy-test \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e WG_HOST=31.28.27.96 \
  -e PASSWORD=test123456 \
  -v $(pwd)/config:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --device /dev/net/tun:/dev/net/tun \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  --sysctl net.ipv4.ip_forward=1 \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy

# Проверьте
docker logs wg-easy-test
```

Откройте http://31.28.27.96:51821 и проверьте, работает ли.

---

**Статус ротации ключей:** 🔴 Отложена до выбора решения

**Следующий шаг:** Выберите один из вариантов выше и я помогу реализовать.
