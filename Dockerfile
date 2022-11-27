FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

# Update repositories list
RUN apt update && apt upgrade -y

RUN apt -y install cron nano htop sudo

# Add "add-apt-repository" command
RUN apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg

# Add additional repositories for PHP, Redis, and MariaDB
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

# Add universe repository if you are on Ubuntu 18.04
RUN apt-add-repository universe

RUN apt update

# Install Dependencies
RUN apt -y install php7.4-intl php7.4-imagick php7.4 php7.4-cli php7.4-gd php7.4-mysql php7.4-pdo php7.4-mbstring php7.4-tokenizer php7.4-bcmath php7.4-xml php7.4-fpm php7.4-curl php7.4-zip nginx tar unzip

RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

COPY ./scheduler.cron /etc/cron.d/scheduler.cron
COPY ./hosts /tmp/hosts
RUN cat /tmp/hosts >> /etc/hosts

RUN chmod 0644 /etc/cron.d/scheduler.cron

# Apply cron job
RUN crontab /etc/cron.d/scheduler.cron

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
