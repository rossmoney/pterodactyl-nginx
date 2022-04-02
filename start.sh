#!/bin/ash

echo "Starting PHP-FPM..."
/usr/sbin/php-fpm8.0 --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize

echo "Starting Queue Work..."
php /home/container/webroot/artisan queue:work --verbose --tries=3 --timeout=90 &

echo "Starting Nginx..."
/usr/sbin/nginx -c /home/container/nginx/nginx.conf
