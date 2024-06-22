#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PHP 8.1\033[0m"
sudo apt-get install -y php8.1-cli php8.1-common

echo -e "$MSG_COLOR$(hostname): Install Composer (PHP)\033[0m"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo -e "$MSG_COLOR$(hostname): Install dependencies for websockets server\033[0m"
cd /vagrant/ws
sudo -u vagrant bash -c 'composer install'

echo -e "\033[42m$(hostname): Finished! Start the WebSocket server manually or configure it as a service\033[0m"
