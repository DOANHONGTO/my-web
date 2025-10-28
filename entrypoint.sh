#!/bin/bash
set -e

echo "Đang chờ database kết nối..."

# Chờ DB sẵn sàng (Render DB có thể chậm khởi động)
until nc -z $DB_HOST $DB_PORT; do
  echo "Chưa kết nối được... thử lại sau 1 giây"
  sleep 1
done

echo "Kết nối database thành công!"

echo "Chạy các lệnh Laravel..."
php artisan key:generate --force
php artisan config:cache
php artisan route:cache
php artisan migrate --force

echo "Khởi động PHP-FPM..."
exec php-fpm