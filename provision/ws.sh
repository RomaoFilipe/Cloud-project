#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PHP 8.1 and additional modules\033[0m"
sudo apt-get install -y php8.1-cli php8.1-zip unzip

echo -e "$MSG_COLOR$(hostname): Install Composer\033[0m"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo -e "$MSG_COLOR$(hostname): Install WebSocket server dependencies\033[0m"
cd /var/www/ws
sudo -u vagrant composer install

echo -e "\033[42m$(hostname): WebSocket server setup completed\033[0m"
