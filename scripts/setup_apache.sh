#!/bin/bash
# Скрипт настройки Apache reverse proxy для WireGuard VPN

set -e

echo "========================================"
echo "Настройка Apache Reverse Proxy"
echo "========================================"

# 1. Включение необходимых модулей Apache
echo "→ Включение модулей Apache (proxy, proxy_http, headers)..."
sudo a2enmod proxy proxy_http headers

# 2. Создание файла паролей для Basic Auth
echo ""
echo "→ Создание файла паролей для Basic Auth..."
echo "  Введите пароль для пользователя 'admin' при запросе"
sudo htpasswd -c /etc/apache2/.htpasswd-vpnadmin admin

# 3. Создание конфигурации виртуального хоста
echo ""
echo "→ Создание конфигурации виртуального хоста..."

sudo tee /etc/apache2/sites-available/vpn-admin.conf > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName 31.28.27.96

    # Proxy для веб-панели WireGuard
    <Location /vpn-admin>
        ProxyPass http://127.0.0.1:51821
        ProxyPassReverse http://127.0.0.1:51821

        # Basic Authentication
        AuthType Basic
        AuthName "WireGuard VPN Admin Panel"
        AuthUserFile /etc/apache2/.htpasswd-vpnadmin
        Require valid-user

        # Headers
        ProxyPreserveHost On
        RequestHeader set X-Forwarded-Proto "http"
        RequestHeader set X-Forwarded-Port "80"
    </Location>

    # Логи
    ErrorLog ${APACHE_LOG_DIR}/vpn-admin-error.log
    CustomLog ${APACHE_LOG_DIR}/vpn-admin-access.log combined
</VirtualHost>
EOF

# 4. Включение сайта
echo "→ Включение виртуального хоста..."
sudo a2ensite vpn-admin.conf

# 5. Проверка конфигурации Apache
echo "→ Проверка конфигурации Apache..."
sudo apache2ctl configtest

# 6. Перезагрузка Apache
echo "→ Перезагрузка Apache..."
sudo systemctl reload apache2

echo ""
echo "✓ Apache Reverse Proxy успешно настроен!"
echo ""
echo "Доступ к панели администратора:"
echo "  URL: http://31.28.27.96/vpn-admin"
echo "  Логин: admin"
echo "  Пароль: (тот, что вы ввели при создании .htpasswd)"
echo ""
echo "Для настройки HTTPS выполните:"
echo "  sudo certbot --apache -d ваш-домен.ru"
