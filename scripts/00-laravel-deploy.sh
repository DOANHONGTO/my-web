#!/usr/bin/env bash
echo "Running composer"
composer global require hirak/prestissimo
composer install --no-dev --working-dir=/var/www/html --optimize-autoloader
echo "Generating application key..."
php artisan key:generate --show
echo "Caching config..."
php artisan config:cache
echo "Caching routes..."
php artisan route:cache
echo "Running migrations (if DB connected)..."
php artisan migrate --force
# Thêm dòng này nếu bạn có seed: php artisan db:seed --force