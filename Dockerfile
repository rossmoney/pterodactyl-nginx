FROM ubuntu:focal

RUN apt update && apt install -y ca-certificates nginx
RUN apt install -y sudo php8 php8-fpm php8-pecl-mcrypt php8-soap php8-openssl php8-gmp php8-pdo_odbc php8-json php8-dom php8-pdo php8-zip php8-mysqli php8-sqlite3 php8-apcu php8-pdo_pgsql php8-bcmath php8-gd php8-odbc php8-pdo_mysql php8-pdo_sqlite php8-gettext php8-xmlreader php8-bz2 php8-iconv php8-pdo_dblib php8-curl php8-ctype php8-phar php8-fileinfo php8-mbstring php8-session php8-tokenizer crontab

RUN echo "# Pterodactyl Queue Worker File\
# ----------------------------------\
\
[Unit]\
Description=Pterodactyl Queue Worker\
\
[Service]\
# On some systems the user and group might be different.\
# Some systems use `apache` or `nginx` as the user and group.\
User=www-data\
Group=www-data\
Restart=always\
ExecStart=/usr/bin/php /home/container/webroot/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3\
StartLimitInterval=180\
StartLimitBurst=30\
RestartSec=5s\
\
[Install]\
WantedBy=multi-user.target" >> /etc/systemd/system/pteroq.service

RUN sudo systemctl enable --now pteroq.service

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
