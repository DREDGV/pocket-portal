FROM weejewel/wg-easy:latest

# Установка wireguard-go для userspace режима
RUN apk add --no-cache wireguard-tools wireguard-go

# Создание директории для TUN устройства
RUN mkdir -p /dev/net

LABEL description="WireGuard VPN with userspace support (wireguard-go) for OpenVZ/VPS"
