# 🚀 Следующие шаги

## ✅ Что сделано

1. ✅ **Защищены секреты**
   - Обновлён `.gitignore` для блокировки `*.conf`, `*-qr.png`, `.env`
   - Создан `.env.example` для безопасного копирования
   - Добавлен `SECURITY.md` с инструкциями по ротации ключей

2. ✅ **Унифицирован Docker-стек**
   - Удалены неиспользуемые файлы: `Dockerfile`, Apache-конфиги
   - Исправлены все скрипты под `linuxserver/wireguard`
   - Обновлены `README.md` и `SETUP_COMPLETE.md`

3. ✅ **Добавлены удобные утилиты**
   - Создан `Makefile` с командами управления
   - Добавлен `CONTRIBUTING.md` с правилами участия

---

## 🔴 КРИТИЧЕСКИ ВАЖНО: Ротация ключей

**Текущий статус:** Ваши приватные ключи были опубликованы в GitHub!

### Немедленные действия:

#### 1. Подключитесь к серверу и пересоздайте ключи:

```bash
ssh root@31.28.27.96
cd /opt/vpn

# Остановите контейнер
docker compose down

# Удалите все старые peer-конфигурации
rm -rf config/peer_*

# Запустите контейнер заново (он создаст новые ключи)
docker compose up -d

# Дождитесь создания конфигов
sleep 5
docker logs wireguard
```

#### 2. Получите новые конфигурации:

**Для laptop-grisha (десктоп):**
```bash
# С вашего Windows-компьютера
scp root@31.28.27.96:/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.conf C:\Users\Marina\Desktop\
```

**Для phone-grisha (мобильный):**
```bash
# На сервере покажите QR-код
ssh root@31.28.27.96
docker exec wireguard cat /config/peer_phone-grisha/peer_phone-grisha.conf | qrencode -t ansiutf8
```

**Для marina-iphone:**
```bash
# На сервере покажите QR-код
docker exec wireguard cat /config/peer_marina-iphone/peer_marina-iphone.conf | qrencode -t ansiutf8
```

#### 3. Обновите конфигурации на всех устройствах:

- Удалите старое подключение `pocket-portal` из приложения WireGuard
- Импортируйте новую конфигурацию (QR-код или файл)
- Проверьте подключение

---

## 🧹 Очистка истории Git (опционально, но рекомендуется)

Чтобы полностью удалить секреты из истории репозитория:

### Вариант 1: Использование git-filter-repo (рекомендуется)

```powershell
# Установите git-filter-repo
pip install git-filter-repo

# Создайте backup текущего репозитория
cd C:\Users\Marina\
cp -r wireguard-vpn wireguard-vpn-backup

# Очистите историю
cd wireguard-vpn
git filter-repo --path laptop-grisha.conf --invert-paths
git filter-repo --path marina-iphone-qr.png --invert-paths
git filter-repo --path phone-grisha-qr.png --invert-paths
git filter-repo --path .env --invert-paths

# Force-push (после того как убедитесь, что всё работает)
git remote add origin https://github.com/DREDGV/pocket-portal.git
git push --force --all
```

⚠️ **Внимание:** Force-push перезапишет историю на GitHub. Все участники проекта должны будут сделать `git clone` заново.

---

## 📦 Закоммитить изменения

```powershell
cd C:\Users\Marina\wireguard-vpn

# Просмотрите изменения
git status

# Добавьте все файлы
git add .

# Создайте коммит
git commit -m "security: защита секретов и унификация под linuxserver/wireguard

- Обновлён .gitignore для блокировки *.conf, *-qr.png, .env
- Удалены Dockerfile и Apache-конфиги (не используются)
- Исправлены скрипты под linuxserver/wireguard
- Добавлены SECURITY.md, CONTRIBUTING.md, Makefile
- Обновлена документация"

# Push в GitHub
git push origin master
```

---

## 📋 Регулярные задачи

### Обновление контейнера (раз в месяц):

```bash
ssh root@31.28.27.96
cd /opt/vpn
make update
# или
docker compose pull && docker compose up -d
```

### Мониторинг подключений:

```bash
ssh root@31.28.27.96
make status
# или
docker exec wireguard wg show
```

### Добавление нового клиента:

```bash
# 1. Откройте docker-compose.yml на сервере
ssh root@31.28.27.96
nano /opt/vpn/docker-compose.yml

# 2. Добавьте имя в PEERS:
# - PEERS=phone-grisha,laptop-grisha,marina-iphone,new-device

# 3. Перезапустите
docker compose up -d

# 4. Покажите QR-код
docker exec wireguard cat /config/peer_new-device/peer_new-device.conf | qrencode -t ansiutf8
```

---

## 🎯 Итоговый чеклист

- [ ] Ротация ключей на сервере (выполнено)
- [ ] Обновление конфигураций на всех устройствах (laptop, phone, iPhone)
- [ ] Проверка подключения с каждого устройства
- [ ] Коммит изменений в GitHub
- [ ] (Опционально) Очистка истории Git через `git filter-repo`
- [ ] Удаление локальных файлов `laptop-grisha.conf`, `*-qr.png`, `.env`

---

## 🆘 Если возникли проблемы

### Контейнер не запускается:
```bash
docker logs wireguard
# Проверьте ошибки
```

### Клиент не подключается:
```bash
# На сервере проверьте порт
sudo ss -lunp | grep 51820

# Проверьте файрвол
sudo ufw status
```

### Нужна помощь:
- 📖 См. `README.md` для полной документации
- 🔒 См. `SECURITY.md` для инструкций по безопасности
- 🐛 Создайте Issue: https://github.com/DREDGV/pocket-portal/issues

---

**Удачи!** 🎉 Ваш Pocket Portal готов к безопасной работе.
