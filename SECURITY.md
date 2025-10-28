# 🔐 Security Policy

## ⚠️ ВАЖНО: Обнаружена утечка секретов

Этот репозиторий содержал **приватные ключи WireGuard** и **пароли** в истории коммитов. Следуйте инструкциям ниже для устранения проблемы.

---

## 🚨 Шаг 1: Немедленная ротация ключей

Все peer-конфигурации, попавшие в GitHub, **должны быть пересозданы**:

### Затронутые клиенты:
- ✅ `laptop-grisha` (приватный ключ в `laptop-grisha.conf`)
- ✅ `phone-grisha` (QR-код с ключом в `phone-grisha-qr.png`)
- ✅ `marina-iphone` (QR-код с ключом в `marina-iphone-qr.png`)

### Действия на сервере:

```bash
# 1. Подключитесь к серверу
ssh root@31.28.27.96

# 2. Остановите контейнер
cd /opt/vpn
docker compose down

# 3. Удалите старые peer-конфигурации
rm -rf config/peer_laptop-grisha
rm -rf config/peer_phone-grisha
rm -rf config/peer_marina-iphone

# 4. Обновите PEERS в docker-compose.yml (перечислите заново тех же клиентов)
# Это заставит контейнер создать новые ключи при запуске

# 5. Запустите контейнер
docker compose up -d

# 6. Проверьте создание новых конфигов
docker logs wireguard
ls -la config/
```

### Распространение новых конфигов:

```bash
# Для мобильных - покажите новый QR-код через SSH:
docker exec wireguard cat /config/peer_phone-grisha/peer_phone-grisha.conf | qrencode -t ansiutf8

# Для десктопа - скачайте через SCP:
scp root@31.28.27.96:/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.conf ~/Desktop/
```

**⚠️ Старые конфигурации больше не работают после ротации!**

---

## 🧹 Шаг 2: Очистка истории Git

### Вариант A: Использование `git filter-repo` (рекомендуется)

```bash
# 1. Установите git-filter-repo
pip install git-filter-repo

# 2. Клонируйте репозиторий заново
git clone https://github.com/DREDGV/pocket-portal.git
cd pocket-portal

# 3. Удалите секретные файлы из всей истории
git filter-repo --path laptop-grisha.conf --invert-paths
git filter-repo --path marina-iphone-qr.png --invert-paths
git filter-repo --path phone-grisha-qr.png --invert-paths
git filter-repo --path .env --invert-paths

# 4. Force-push в удалённый репозиторий
git remote add origin https://github.com/DREDGV/pocket-portal.git
git push --force --all
git push --force --tags
```

### Вариант B: BFG Repo-Cleaner (быстрее для больших репозиториев)

```bash
# 1. Скачайте BFG: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files laptop-grisha.conf pocket-portal.git
java -jar bfg.jar --delete-files "*-qr.png" pocket-portal.git
java -jar bfg.jar --delete-files .env pocket-portal.git

# 2. Очистите и push
cd pocket-portal.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

**После очистки:**
- Удалите старые локальные клоны.
- Все участники проекта должны сделать `git clone` заново (не `git pull`!).

---

## 🛡️ Шаг 3: Предотвращение будущих утечек

✅ **`.gitignore` уже обновлён** и блокирует:
- `*.conf` (клиентские конфиги)
- `*-qr.png` (QR-коды)
- `.env` (переменные окружения)
- `config/` (директория с приватными ключами)

### Безопасные практики:

1. **Никогда не коммитьте:**
   - Приватные ключи (`PrivateKey =`)
   - Пароли (`.env`, `htpasswd`)
   - QR-коды с настройками VPN

2. **Используйте `.env.example`:**
   ```bash
   cp .env.example .env
   # Заполните .env своими значениями
   # .env останется только локально
   ```

3. **Храните секреты на сервере:**
   - Конфиги клиентов: `/opt/vpn/config/` (только на VPS)
   - Передавайте через SCP/SFTP или QR в терминале
   - Никогда не отправляйте через открытые каналы (Telegram, email без шифрования)

---

## 🔒 Шаг 4: Операционная безопасность

### Firewall (UFW):
```bash
# Проверьте открытые порты
sudo ufw status

# Должен быть открыт только:
# - 51820/udp (WireGuard)
# - 22/tcp (SSH)
# - 80/tcp, 443/tcp (если используется Apache)
```

### Обновления:
```bash
# Обновляйте контейнер регулярно
cd /opt/vpn
docker compose pull
docker compose up -d

# Обновляйте систему
sudo apt update && sudo apt upgrade -y
```

### Мониторинг:
```bash
# Логи подключений
docker logs wireguard --tail 100 -f

# Активные сессии
docker exec wireguard wg show
```

---

## 📞 Контакты

Если обнаружите новые проблемы безопасности — создайте приватный Issue или напишите напрямую: https://github.com/DREDGV

**Статус:** 🔴 Требуется немедленная ротация ключей!
