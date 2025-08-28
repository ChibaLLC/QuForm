#!/bin/bash

# Create log directories
mkdir -p /var/log/supervisor
mkdir -p /var/log/nginx

# Configure PHP upload limits at runtime (can be overridden by env vars)
# Default to 100M upload_max_filesize and 110M post_max_size if not provided
{
    echo "upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-100M}"
    echo "post_max_size=${PHP_POST_MAX_SIZE:-110M}"
    echo "max_execution_time=${PHP_MAX_EXECUTION_TIME:-300}"
    echo "memory_limit=${PHP_MEMORY_LIMIT:-512M}"
    echo "max_input_time=${PHP_MAX_INPUT_TIME:-300}"
    echo "max_file_uploads=${PHP_MAX_FILE_UPLOADS:-20}"
    echo "default_socket_timeout=${PHP_DEFAULT_SOCKET_TIMEOUT:-300}"
} >/usr/local/etc/php/conf.d/uploads.ini
# Ensure storage symlink exists for public file serving
php artisan storage:link >/dev/null 2>&1 || true

# Run database migrations (no-interaction)
# echo "Running database migrations..."
# php artisan migrate --force --no-interaction || true
mkdir -p /var/lib/nginx/tmp/client_body
mkdir -p /var/lib/nginx/tmp/fastcgi
chown -R www-data:www-data /var/lib/nginx
# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Start supervisor (which manages nginx, php-fpm, queue workers, and scheduler)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
