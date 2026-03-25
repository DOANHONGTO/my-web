FROM php:8.1-fpm

# Cài đặt hệ thống + extension cho Laravel + PostgreSQL + MySQL
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    netcat-openbsd \
    && docker-php-ext-install pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd \
    && pecl install redis && docker-php-ext-enable redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Tạo user www
RUN groupadd -r www && useradd -r -g www www

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Copy source code
COPY . .

# Cài dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Phân quyền
RUN chown -R www:www /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
