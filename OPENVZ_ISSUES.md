# OpenVZ Virtualization Issues - Detailed Report

**Дата:** 28 октября 2025  
**Сервер:** 31.28.27.96 (Ubuntu 22.04, OpenVZ)  
**Цель:** Развертывание WireGuard VPN

---

## Краткое резюме проблемы

OpenVZ виртуализация **НЕ ПОДДЕРЖИВАЕТ** WireGuard kernel module из-за архитектурных ограничений. Все попытки запустить WireGuard-based решения столкнулись с критическими ошибками.

---

## Хронология попыток

### 1. Попытка №1: linuxserver/wireguard (FAILED)

**Образ:** `lscr.io/linuxserver/wireguard:latest`  
**Результат:** ❌ Контейнер зависает на старте

#### Проблема
```bash
[cont-init.d] 30-module: executing...
Uname info: Linux 7a8eb6cd0e08 2.6.32-042stab162.2 #1 SMP Thu Jun 9 12:05:33 MSK 2022 x86_64 x86_64 x86_64 GNU/Linux
**** It seems the wireguard module is already active. Skipping kernel header install and module compilation. ****
**** The module is not active, will attempt kernel header install and module compilation. ****
Kernel headers don't seem to be available, will try to install
# ЗАВИСАНИЕ ЗДЕСЬ - скрипт уходит в sleep infinity
```

#### Анализ корневой причины
Файл `/etc/s6-overlay/s6-rc.d/init-wireguard-module/run` содержит:

```bash
if lsmod | grep wireguard; then
    # Модуль активен
else
    # Пытается установить kernel headers
    # НА OPENVZ ЭТО НЕВОЗМОЖНО
    # Затем выполняет: exec sleep infinity
fi
```

**Причина зависания:** OpenVZ не предоставляет доступ к kernel headers хост-системы. Container пытается их установить, терпит неудачу и уходит в бесконечный сон.

#### Техническая деталь
OpenVZ использует **shared kernel** архитектуру - все контейнеры используют ядро хоста. Контейнеры не могут загружать свои kernel modules, только использовать те, что загружены на хосте.

---

### 2. Попытка №2: wg-easy (FAILED)

**Образ:** `ghcr.io/wg-easy/wg-easy:latest`  
**Результат:** ❌ Контейнер не может создать WireGuard интерфейс

#### Проблема
```
2025-10-28T15:54:27.345Z WireGuard Configuration generated.
Error: WireGuard exited with the error: Cannot find device "wg0"
This usually means that your host's kernel does not support WireGuard!
```

#### Анализ
wg-easy использует команды `wg-quick up wg0` и `wg-quick down wg0`, которые требуют:
1. Kernel module `wireguard` загруженным на хосте
2. Или userspace implementation через `wireguard-go`

На нашем OpenVZ сервере:
- ✅ `wg-quick` установлен: `/usr/bin/wg-quick`
- ❌ `wireguard-go` НЕ установлен
- ❌ Kernel module недоступен (проверено через `lsmod | grep wireguard` - пусто)

#### Решение (не реализовано)
Нужно установить `wireguard-go` на хост-систему и настроить wg-easy для использования userspace реализации.

```bash
# На хосте
apt install wireguard-tools wireguard-go
export WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go
```

Но это требует изменения самого образа wg-easy или монтирования wireguard-go в контейнер.

---

### 3. Попытка №3: wg-access-server (FAILED)

**Образ:** `ghcr.io/freifunkmuc/wg-access-server:latest`  
**Результат:** ❌ Требует WireGuard private key, но затем та же проблема с device

#### Проблемы
1. **Конфигурация:** Требует явного указания `WIREGUARD_PRIVATE_KEY` в environment
2. **Та же проблема с kernel module:** После генерации ключа столкнемся с "Cannot find device wg0"

#### Что было сделано
```yaml
environment:
  - WIREGUARD_PRIVATE_KEY=QOSeG+roCyqX7qZngIoT5tkOMSNiZD3aIX2ajMNx2lQ=
  - WG_ADMIN_PASSWORD=PocketPortal2025Secure
  - WG_EXTERNAL_HOST=31.28.27.96
```

Контейнер запустился, но циклически падал с сообщением:
```
level=fatal msg="Missing WireGuard private key"
```

Даже после добавления ключа в environment, переменная не читалась корректно. Попытки использовать файл конфигурации `config.yaml` также не принесли результата из-за проблем с PowerShell heredoc синтаксисом.

---

### 4. Попытка №4: Outline VPN (IN PROGRESS)

**Решение:** `https://github.com/Jigsaw-Code/outline-server`  
**Статус:** 🔄 Установка в процессе

#### Почему Outline может сработать

Outline VPN использует **Shadowsocks** протокол, который работает полностью в userspace:
- ✅ Не требует kernel modules
- ✅ Работает через стандартные TCP/UDP sockets
- ✅ Проверен на OpenVZ множеством пользователей
- ✅ Официальная поддержка от Google Jigsaw

#### Команда установки
```bash
curl -sSL https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash
```

---

## Технические ограничения OpenVZ

### Что такое OpenVZ?

OpenVZ - это **container-based virtualization** для Linux:
- Использует **один общий kernel** для всех контейнеров
- Контейнеры изолированы через namespaces и cgroups
- Легче и быстрее полной виртуализации (KVM), но менее гибкий

### Ключевые ограничения

| Функция | KVM | OpenVZ |
|---------|-----|--------|
| Собственное ядро | ✅ Да | ❌ Нет (shared kernel) |
| Загрузка kernel modules | ✅ Да | ❌ Нет |
| TUN/TAP device | ✅ Да | ⚠️ Частично (нужно на хосте) |
| WireGuard kernel module | ✅ Да | ❌ Требует хост |
| WireGuard userspace (wireguard-go) | ✅ Да | ✅ Да (если установлен) |
| Shadowsocks | ✅ Да | ✅ Да |
| OpenVPN | ✅ Да | ✅ Да |

### Почему WireGuard не работает?

1. **Kernel Module Dependency**
   ```bash
   # На KVM можно загрузить:
   modprobe wireguard
   
   # На OpenVZ это вернет:
   modprobe: ERROR: could not insert 'wireguard': Operation not permitted
   ```

2. **TUN Device**
   ```bash
   # Проверка на сервере:
   ls -la /dev/net/tun
   # crw-rw-rw- 1 root root 10, 200 Oct 28 12:00 /dev/net/tun
   # Устройство есть, но kernel module для WireGuard отсутствует
   ```

3. **Shared Kernel Architecture**
   - Хост использует `2.6.32-042stab162.2` (старое ядро)
   - WireGuard требует kernel 5.6+ для нативной поддержки
   - Или userspace implementation (wireguard-go)

---

## Возможные решения

### Решение 1: Установить wireguard-go на хост (РЕКОМЕНДУЕТСЯ)

**Требует SSH root доступ к ФИЗИЧЕСКОМУ хосту** (не контейнеру)

```bash
# На хост-ноде OpenVZ
apt update
apt install wireguard-tools wireguard-go -y

# Проверка
which wireguard-go
# /usr/bin/wireguard-go
```

Затем в docker-compose добавить:
```yaml
environment:
  - WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go
volumes:
  - /usr/bin/wireguard-go:/usr/bin/wireguard-go:ro
```

**Проблема:** Требует доступ к хост-системе OpenVZ, который у нас может не быть.

---

### Решение 2: Использовать Outline VPN (ТЕКУЩИЙ ПОДХОД) ✅

**Не требует доступа к хосту**

Outline работает полностью в userspace через Shadowsocks:
```
Client (Outline app) → Shadowsocks protocol → Outline Server (Docker) → Internet
```

**Преимущества:**
- ✅ Работает на любой виртуализации
- ✅ Простая установка одной командой
- ✅ GUI приложение для управления (Outline Manager)
- ✅ Клиенты для всех платформ (Windows, Android, iOS, macOS, Linux)
- ✅ Автоматическая генерация ключей доступа
- ✅ Обфускация трафика (сложнее заблокировать)

**Недостатки:**
- ⚠️ Немного медленнее WireGuard (~5-10%)
- ⚠️ Меньше функций (только VPN, нет mesh networking)

---

### Решение 3: Использовать OpenVPN

**Классическое решение, 100% работает на OpenVZ**

```bash
docker run -d --name=openvpn-server \
  --cap-add=NET_ADMIN \
  -p 1194:1194/udp \
  -v /opt/vpn/openvpn:/etc/openvpn \
  kylemanna/openvpn
```

**Преимущества:**
- ✅ Гарантированно работает на OpenVZ
- ✅ Проверенное решение с 2001 года
- ✅ Много документации и поддержки
- ✅ Flexible конфигурация

**Недостатки:**
- ❌ Медленнее WireGuard (в 2-3 раза)
- ❌ Сложнее настройка
- ❌ Больше оверхед (TCP + SSL/TLS)

---

### Решение 4: Сменить хостинг на KVM виртуализацию

**Полное решение проблемы**

Провайдеры с KVM:
- DigitalOcean (от $6/мес)
- Vultr (от $5/мес)
- Hetzner (от €4.5/мес)
- Linode (от $5/мес)

**Преимущества:**
- ✅ WireGuard работает нативно
- ✅ Полный контроль над kernel
- ✅ Можно загружать любые modules
- ✅ Лучшая изоляция

**Недостатки:**
- ❌ Требует миграцию данных
- ❌ Простой на время переноса
- ❌ Нужно настраивать все заново

---

## PowerShell Issues (Побочная проблема)

### Проблема с heredoc синтаксисом

При попытке создать файлы на сервере через SSH + PowerShell:

```powershell
ssh root@31.28.27.96 @"
cat > /opt/vpn/config.yaml << 'EOF'
content here
EOF
"@
```

**Ошибка:**
```
System.ArgumentOutOfRangeException: Значение не может быть отрицательным.
Параметр: top
Смещение было -7.
```

#### Причина
PowerShell here-string (`@"..."@`) конфликтует с bash heredoc (`<< 'EOF'`). PowerShell пытается парсить содержимое как часть своей строки.

#### Обходные пути
1. Создать файл локально и скопировать через SCP ✅ (использовали)
2. Использовать `echo` с экранированием
3. Использовать `printf` вместо heredoc
4. Использовать базовый `bash` вместо `PowerShell`

---

## Текущий статус

### Что работает ✅
- ✅ Docker установлен и работает
- ✅ Порты 51820/udp и 51821/tcp открыты в firewall
- ✅ `/dev/net/tun` доступен
- ✅ Контейнеры запускаются (но падают)
- ✅ SCP/SSH доступ работает

### Что НЕ работает ❌
- ❌ linuxserver/wireguard - зависает на init
- ❌ wg-easy - "Cannot find device wg0"
- ❌ wg-access-server - не читает WIREGUARD_PRIVATE_KEY
- ❌ WireGuard kernel module недоступен

### В процессе 🔄
- 🔄 Outline VPN установка (Shadowsocks-based)
- 🔄 Проверка работоспособности Outline

---

## Рекомендации

### Краткосрочные (Сейчас)
1. ✅ Завершить установку Outline VPN
2. ✅ Протестировать подключение с Windows
3. ✅ Протестировать подключение с Android
4. ✅ Задокументировать процесс

### Среднесрочные (1-2 недели)
1. Связаться с хостинг-провайдером:
   - Запросить установку `wireguard-go` на хост-систему
   - Или запросить апгрейд kernel до 5.6+
   - Или запросить миграцию на KVM
2. Если хостер не поможет - рассмотреть миграцию на KVM-провайдера

### Долгосрочные (Если WireGuard критичен)
1. Сменить хостинг на KVM виртуализацию
2. Настроить WireGuard нативно
3. Реализовать все функции из ROADMAP.md

---

## Дополнительные материалы

### Полезные команды для диагностики

```bash
# Проверка виртуализации
systemd-detect-virt
# Вернет: openvz

# Проверка kernel
uname -r
# Вернет: 2.6.32-042stab162.2

# Проверка WireGuard module
lsmod | grep wireguard
# Пусто (модуль не загружен)

# Проверка TUN device
ls -la /dev/net/tun
cat /sys/class/net/tun/uevent

# Проверка capabilities контейнера
docker run --rm -it --cap-add=NET_ADMIN alpine sh -c "ip link add wg0 type wireguard"
# Вернет: Operation not supported
```

### Ссылки на GitHub Issues

Эта проблема известна в сообществе:
- https://github.com/linuxserver/docker-wireguard/issues/115
- https://github.com/wg-easy/wg-easy/issues/256
- https://serverfault.com/questions/1073679/wireguard-in-docker-container-on-openvz

---

## Выводы

OpenVZ виртуализация **фундаментально несовместима** с WireGuard без:
- Установки `wireguard-go` на хост-системе
- Или апгрейда kernel хоста до 5.6+
- Или смены на KVM виртуализацию

**Наилучшее краткосрочное решение:** Outline VPN (Shadowsocks)  
**Наилучшее долгосрочное решение:** Миграция на KVM с WireGuard

---

**Автор документа:** GitHub Copilot  
**Дата последнего обновления:** 28 октября 2025, 16:10 UTC
