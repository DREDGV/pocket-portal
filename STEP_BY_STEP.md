# 🚀 Пошаговая инструкция: Запуск VPN

> **Читайте внимательно каждый шаг. Не пропускайте ничего.**

---

## ШАГ 1: Останавливаем старый контейнер

### Команда (скопируйте и выполните):

```powershell
ssh root@31.28.27.96 "cd /opt/vpn && docker compose down 2>&1"
```

### Что должны увидеть:
```
Container wireguard  Stopping
Container wireguard  Stopped
Container wireguard  Removed
```

Или:
```
no such service: wireguard
```

**Оба варианта — норма!**

✅ **Скопируйте результат и покажите мне**

---

## ШАГ 2: Создаем правильный docker-compose.yml

### Команда 1: Бэкап старого файла

```powershell
ssh root@31.28.27.96 "cd /opt/vpn && cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d) 2>&1"
```

### Команда 2: Создаем новый файл

```powershell
ssh root@31.28.27.96 @"
cat > /opt/vpn/docker-compose.yml <<'ENDOFFILE'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - WG_HOST=31.28.27.96
      - PASSWORD=PocketPortal2025!Secure
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
      - 51820:51820/udp
      - 51821:51821/tcp
    devices:
      - /dev/net/tun:/dev/net/tun
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped
ENDOFFILE
"@
```

### Что должны увидеть:
Просто возврат в командную строку (без ошибок)

✅ **Покажите мне результат**

---

## ШАГ 3: Открываем порт для веб-панели

### Команда:

```powershell
ssh root@31.28.27.96 "sudo ufw allow 51821/tcp comment 'wg-easy web UI' 2>&1"
```

### Что должны увидеть:
```
Rule added
Rule added (v6)
```

Или:
```
ERROR: Could not load logging rules
```
(Это тоже норма — UFW может быть отключен)

✅ **Покажите результат**

---

## ШАГ 4: Очищаем старые конфиги и запускаем

### Команда 1: Бэкап старых конфигов

```powershell
ssh root@31.28.27.96 "cd /opt/vpn && tar -czf config.backup.$(date +%Y%m%d_%H%M%S).tar.gz config/ 2>&1"
```

### Команда 2: Очистка

```powershell
ssh root@31.28.27.96 "cd /opt/vpn && rm -rf config/* 2>&1"
```

### Команда 3: ЗАПУСК!

```powershell
ssh root@31.28.27.96 "cd /opt/vpn && docker compose pull && docker compose up -d 2>&1"
```

### Что должны увидеть:
```
Pulling wg-easy ... done
Creating wg-easy ... done
```

✅ **Покажите результат (особенно важно!)**

---

## ШАГ 5: Проверяем что контейнер работает

### Команда:

```powershell
ssh root@31.28.27.96 "docker ps | grep wg-easy 2>&1"
```

### Что должны увидеть:
```
abc123def456   ghcr.io/wg-easy/wg-easy   Up X seconds   0.0.0.0:51820->51820/udp, 0.0.0.0:51821->51821/tcp
```

**Ключевое слово:** `Up` (контейнер запущен)

✅ **Покажите результат**

---

## ШАГ 6: Смотрим логи (чтобы убедиться что всё ОК)

### Команда:

```powershell
ssh root@31.28.27.96 "docker logs wg-easy 2>&1 | tail -20"
```

### Что должны увидеть:
В логах должна быть строка типа:
```
✅ Web UI available at http://0.0.0.0:51821
```

✅ **Покажите последние 20 строк логов**

---

## ШАГ 7: Открываем веб-панель

### 1. Откройте браузер

### 2. Вставьте адрес:
```
http://31.28.27.96:51821
```

### 3. Введите пароль:
```
PocketPortal2025!Secure
```

### Что должны увидеть:
- Красивый интерфейс wg-easy
- Кнопку "+ New Client"
- Пустой список клиентов

✅ **Сделайте скриншот и покажите**

---

## ШАГ 8: Добавляем ваш первый клиент

### В веб-панели:

1. Нажмите кнопку **"+ New Client"**
2. В поле Name введите: `marina-test`
3. Нажмите **"Create"**

### Что должны увидеть:
- Появился клиент `marina-test`
- Рядом с ним кнопки: QR Code, Download, Enable/Disable

✅ **Скриншот**

---

## ШАГ 9: Подключаемся к VPN

### Для телефона (iPhone/Android):

1. Установите приложение **WireGuard** из App Store или Google Play
2. В веб-панели нажмите **QR Code** рядом с `marina-test`
3. В приложении WireGuard нажмите **"+"** → **"Scan from QR code"**
4. Наведите камеру на QR-код
5. Нажмите **"Allow"** → **"Activate"**

### Для ноутбука:

1. Установите [WireGuard](https://www.wireguard.com/install/)
2. В веб-панели нажмите **Download** рядом с `marina-test`
3. Сохраните файл `marina-test.conf`
4. В WireGuard: **Import tunnel(s) from file**
5. Выберите файл → **Activate**

---

## ШАГ 10: Проверяем что VPN работает

### 1. Подключите VPN на телефоне/ноутбуке

### 2. Откройте https://whoer.net

### Что должны увидеть:
```
IP: 31.28.27.96
Country: Russia
```

✅ **Если IP = 31.28.27.96 — ВСЁ РАБОТАЕТ!** 🎉

---

## 🆘 Если что-то пошло не так

### Контейнер не запускается:
```powershell
ssh root@31.28.27.96 "docker logs wg-easy 2>&1"
```
Покажите мне логи.

### Веб-панель не открывается:
```powershell
ssh root@31.28.27.96 "sudo ss -lntp | grep 51821 2>&1"
```
Должна быть строка с `51821`. Покажите результат.

### VPN подключается, но не работает интернет:
```powershell
ssh root@31.28.27.96 "docker exec wg-easy wg show 2>&1"
```
Покажите результат.

---

## 📞 Связь

На каждом шаге:
1. Выполните команду
2. Скопируйте результат
3. Покажите мне
4. Жду подтверждения, потом даю следующий шаг

**Поехали! Начнем с ШАГа 1?** 🚀
