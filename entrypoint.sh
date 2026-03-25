#!/bin/bash
set -e

# Phân quyền storage & cache (www-data = user PHP-FPM chạy)
chmod -R 777 /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true

# Xóa cache cũ (tránh lỗi dev packages không tồn tại)
php artisan clear-compiled 2>/dev/null || true
rm -f /var/www/bootstrap/cache/services.php /var/www/bootstrap/cache/packages.php /var/www/bootstrap/cache/config.php

# Tạo APP_KEY nếu chưa có
php artisan key:generate --force --no-interaction

# Chờ DB nếu có cấu hình DB_HOST
if [ -n "$DB_HOST" ]; then
  echo "Đang chờ database ${DB_HOST}:${DB_PORT:-3306}..."
  TRIES=0
  MAX_TRIES=15
  until nc -z ${DB_HOST} ${DB_PORT:-3306} 2>/dev/null; do
    TRIES=$((TRIES + 1))
    if [ $TRIES -ge $MAX_TRIES ]; then
      echo "Không kết nối được DB sau ${MAX_TRIES} lần thử. Bỏ qua, tiếp tục khởi động..."
      break
    fi
    echo "Chưa kết nối được DB... thử lại ($TRIES/$MAX_TRIES)"
    sleep 2
  done

  if nc -z ${DB_HOST} ${DB_PORT:-3306} 2>/dev/null; then
    echo "Kết nối database thành công!"
    php artisan migrate --force
  fi
fi

# Cache config & route
php artisan config:cache
php artisan route:cache

echo "Khởi động PHP-FPM..."
exec php-fpm
