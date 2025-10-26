# ✅ WireGuard VPN - Setup Complete!

## 🎉 Успешно развёрнуто!

**Дата**: 26 октября 2025
**Сервер**: 31.28.27.96
**Виртуализация**: OpenVZ (userspace WireGuard)

## 📊 Статус компонентов

✅ Docker установлен и работает
✅ WireGuard контейнер запущен (linuxserver/wireguard)
✅ IP forwarding настроен
✅ Firewall (UFW) открыт для порта 51820/udp
✅ /dev/net/tun создан
✅ 3 peer конфигурации сгенерированы
✅ QR-коды созданы

## 📱 Клиентские конфигурации

На сервере в `/opt/vpn/config/` созданы конфигурации для:

1. **phone-grisha** (10.13.13.2)
   - Config: `/opt/vpn/config/peer_phone-grisha/peer_phone-grisha.conf`
   - QR: `/opt/vpn/config/peer_phone-grisha/peer_phone-grisha.png`

2. **laptop-grisha** (10.13.13.3)
   - Config: `/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.conf`
   - QR: `/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.png`

3. **marina-iphone** (10.13.13.4)
   - Config: `/opt/vpn/config/peer_marina-iphone/peer_marina-iphone.conf`
   - QR: `/opt/vpn/config/peer_marina-iphone/peer_marina-iphone.png`

## 🔧 Как подключиться

### Для мобильных устройств (QR-код):

```bash
ssh root@31.28.27.96
cd /opt/vpn/config/peer_phone-grisha
qrencode -t ansiutf8 < peer_phone-grisha.conf
```

Отсканируйте QR-код в приложении WireGuard (iOS/Android).

### Для десктопа (файл конфигурации):

Скачайте `.conf` файл через SFTP/SCP:

```bash
scp root@31.28.27.96:/opt/vpn/config/peer_laptop-grisha/peer_laptop-grisha.conf .
```

Импортируйте в WireGuard Desktop client.

## 🛠️ Управление

### Проверить статус:
```bash
ssh root@31.28.27.96
docker ps
docker logs wireguard
```

### Перезапустить:
```bash
cd /opt/vpn
docker compose restart
```

### Добавить нового peer:
```bash
docker exec -it wireguard bash
cd /config
# Следуйте инструкциям в README.md
```

## ⚙️ Конфигурация

- **Сервер**: 10.13.13.1/24
- **Порт**: 51820/udp
- **DNS**: 1.1.1.1, 1.0.0.1
- **Endpoint**: 31.28.27.96:51820
- **Allowed IPs**: 0.0.0.0/0, ::/0 (full tunnel)

## 📝 Важные замечания

- ⚠️ Сервер использует OpenVZ виртуализацию
- ⚠️ WireGuard работает в userspace режиме (без модуля ядра)
- ⚠️ Существующие сервисы (Apache2, PM2/Childwatch) не затронуты
- ⚠️ Config директория `/opt/vpn/config/` содержит приватные ключи - не публикуйте!

## 🔐 Безопасность

- ✅ Firewall настроен (только 51820/udp открыт)
- ✅ DNS через туннель (предотвращает утечки)
- ✅ Persistent Keepalive для мобильных клиентов
- ⚠️ Рекомендуется регулярно обновлять контейнер:
  ```bash
  cd /opt/vpn && docker compose pull && docker compose up -d
  ```

## 📚 Дополнительная документация

См. [README.md](README.md) для полной документации.

---

**Проект готов к использованию!** 🚀
