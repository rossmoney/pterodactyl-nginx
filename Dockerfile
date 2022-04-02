FROM ubuntu:focal

# Update repositories list
RUN apt update && apt upgrade -y

# Add "add-apt-repository" command
RUN apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg sudo cron

# Add additional repositories for PHP, Redis, and MariaDB
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:chris-lea/redis-server

# Add universe repository if you are on Ubuntu 18.04
RUN apt-add-repository universe

RUN apt update

# Install Dependencies
RUN apt -y install php8.0 php8.0-cli php8.0-gd php8.0-mysql php8.0-pdo php8.0-mbstring php8.0-tokenizer php8.0-bcmath php8.0-xml php8.0-fpm php8.0-curl php8.0-zip nginx tar unzip

RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

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
