#!/bin/ash

echo "Starting PHP-FPM..."
/usr/sbin/php-fpm8.0 --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize

echo "Starting Queue Work..."
#php /home/container/webroot/artisan queue:work --verbose --tries=3 --timeout=90 & >> /home/container/logs/queue_work.log 2>&1

sudo supervisorctl reread
sudo supervisorctl update
supervisorctl start queue

echo "Starting Nginx..."
/usr/sbin/nginx -c /home/container/nginx/nginx.conf
