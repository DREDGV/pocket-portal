# Outline VPN - Quick Start Guide

## ✅ Статус: VPN Сервер Работает!

**Сервер:** 31.28.27.96  
**Протокол:** Shadowsocks (Outline)  
**Управление:** Outline Manager (GUI приложение)

---

## 🚀 Быстрый старт

### Шаг 1: Установить Outline Manager

**Windows / macOS / Linux:**
1. Скачайте Outline Manager: https://getoutline.org/get-started/#step-1
2. Установите приложение

### Шаг 2: Подключить сервер к Manager

1. Откройте Outline Manager
2. Выберите "Set up Outline anywhere" → "I have set up Outline on a cloud provider"
3. Вставьте этот API ключ:

```
{
  "apiUrl":"https://31.28.27.96:29789/mDyT9zVKwCdpmNzDqkoSHQ",
  "certSha256":"88F316104BC94E8BFD4DDB6AABF51FEB9D068FD2D35E0B68AD753FCBD98F5C00"
}
```

4. Нажмите "Done"

### Шаг 3: Создать ключи доступа для пользователей

В Outline Manager:
1. Нажмите "+ ADD A NEW KEY"
2. Назовите ключ (например: "Marina-PC", "Marina-Phone", "Grisha-Laptop")
3. Скопируйте ключ доступа или покажите QR-код

### Шаг 4: Подключиться с устройств

#### Windows
1. Скачайте Outline Client: https://getoutline.org/get-started/#step-3
2. Установите приложение
3. Нажмите "Add Server"
4. Вставьте ключ доступа или отсканируйте QR-код
5. Нажмите "Connect"

#### Android
1. Установите из Google Play: [Outline - Secure internet access](https://play.google.com/store/apps/details?id=org.outline.android.client)
2. Откройте приложение
3. Нажмите "Add Server"
4. Отсканируйте QR-код или вставьте ключ
5. Нажмите "Connect"

#### iOS (iPhone/iPad)
1. Установите из App Store: [Outline](https://apps.apple.com/app/outline-app/id1356177741)
2. Откройте приложение
3. Нажмите "+"
4. Отсканируйте QR-код или вставьте ключ
5. Нажмите "Connect"

---

## 📊 Управление сервером

### Через Outline Manager (GUI)

- ✅ **Добавить пользователя:** Кнопка "+ ADD A NEW KEY"
- ✅ **Удалить пользователя:** Кнопка "DELETE" рядом с ключом
- ✅ **Переименовать ключ:** Кликните на имя ключа
- ✅ **Установить лимит данных:** Settings → Data limit
- ✅ **Посмотреть статистику:** Графики использования данных

### Через SSH (advanced)

```bash
# Подключиться к серверу
ssh root@31.28.27.96

# Проверить статус контейнера
docker ps | grep shadowbox

# Посмотреть логи
docker logs shadowbox

# Перезапустить сервер
docker restart shadowbox

# Остановить сервер
docker stop shadowbox

# Запустить сервер
docker start shadowbox

# Полная переустановка (ОСТОРОЖНО: удалит все ключи!)
docker rm -f shadowbox watchtower
rm -rf /opt/outline
bash -c "$(wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh)"
```

---

## 🔐 Безопасность

### Текущая конфигурация

- ✅ **Шифрование:** AES-256-GCM
- ✅ **Порт управления:** 29789 (HTTPS, самоподписанный сертификат)
- ✅ **Порты данных:** Динамические (управляются Outline)
- ✅ **Firewall:** UFW активен
- ✅ **Обфускация:** Трафик выглядит как обычный HTTPS

### Рекомендации

1. ✅ **НЕ делитесь API ключом** - это административный доступ
2. ✅ **Создавайте отдельный ключ для каждого устройства** - проще отозвать
3. ✅ **Периодически меняйте ключи** - особенно при утере устройства
4. ✅ **Мониторьте использование** - смотрите статистику в Manager
5. ⚠️ **Сохраните API ключ в надежном месте** - иначе потеряете доступ к управлению

---

## 🎯 Преимущества Outline VPN

### По сравнению с WireGuard

| Функция | WireGuard | Outline |
|---------|-----------|---------|
| Работа на OpenVZ | ❌ Нет | ✅ Да |
| Скорость | ⚡ Очень быстро | ⚡ Быстро (-5-10%) |
| Обфускация трафика | ❌ Нет | ✅ Да |
| GUI управление | ⚠️ Частично | ✅ Полностью |
| Простота настройки | ⚠️ Средне | ✅ Очень просто |
| Кросс-платформа | ✅ Да | ✅ Да |
| Открытый код | ✅ Да | ✅ Да |

### Почему Outline работает на OpenVZ

Outline использует **Shadowsocks** протокол, который:
- Работает полностью в **userspace** (не требует kernel modules)
- Использует стандартные **TCP/UDP sockets**
- Не зависит от виртуализации
- Совместим с любым Linux kernel

---

## 🐛 Troubleshooting

### Не могу подключиться к серверу

1. Проверьте, что контейнер запущен:
   ```bash
   ssh root@31.28.27.96 "docker ps | grep shadowbox"
   ```

2. Проверьте порты:
   ```bash
   ssh root@31.28.27.96 "netstat -tulpn | grep LISTEN"
   ```

3. Проверьте firewall:
   ```bash
   ssh root@31.28.27.96 "ufw status"
   ```

### Outline Manager не принимает API ключ

1. Убедитесь, что вставили **оба поля** (apiUrl и certSha256)
2. Проверьте, что не добавили лишних пробелов
3. Попробуйте вставить как JSON:
   ```json
   {"apiUrl":"https://31.28.27.96:29789/mDyT9zVKwCdpmNzDqkoSHQ","certSha256":"88F316104BC94E8BFD4DDB6AABF51FEB9D068FD2D35E0B68AD753FCBD98F5C00"}
   ```

### Медленная скорость соединения

1. Проверьте нагрузку на сервер:
   ```bash
   ssh root@31.28.27.96 "top -bn1 | head -20"
   ```

2. Попробуйте другой сервер Outline (если есть)
3. Проверьте пинг до сервера:
   ```bash
   ping 31.28.27.96
   ```

### Потерял API ключ

API ключ хранится на сервере:
```bash
ssh root@31.28.27.96 "cat /opt/outline/access.txt"
```

---

## 📈 Следующие шаги

### Ближайшие задачи
- [x] ~~Установить VPN сервер~~
- [ ] Протестировать подключение с Windows
- [ ] Протестировать подключение с Android
- [ ] Создать ключи для всех членов семьи
- [ ] Настроить мониторинг использования

### Будущие улучшения
- [ ] Настроить автоматические бекапы конфигурации
- [ ] Добавить Prometheus метрики
- [ ] Настроить алерты при высокой нагрузке
- [ ] Добавить второй сервер для резервирования

---

## 📚 Дополнительные ресурсы

- **Официальный сайт:** https://getoutline.org/
- **GitHub:** https://github.com/Jigsaw-Code/outline-server
- **Документация:** https://support.getoutline.org/
- **Reddit сообщество:** https://reddit.com/r/outlinevpn
- **Telegram группа:** https://t.me/outline_vpn

---

## ⚠️ Важные заметки

### Сохраните эту информацию!

```json
{
  "apiUrl": "https://31.28.27.96:29789/mDyT9zVKwCdpmNzDqkoSHQ",
  "certSha256": "88F316104BC94E8BFD4DDB6AABF51FEB9D068FD2D35E0B68AD753FCBD98F5C00"
}
```

**Без этого API ключа вы не сможете управлять сервером через Outline Manager!**

### Backup этой информации
1. Сохраните в password manager (1Password, Bitwarden, KeePass)
2. Или в зашифрованный файл
3. Или распечатайте и храните в безопасном месте

---

**Дата создания:** 28 октября 2025  
**Версия сервера:** Outline Shadowbox (stable)  
**Статус:** ✅ Работает
