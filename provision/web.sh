#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install Apache HTTP Server\033[0m"
sudo apt-get install -y apache2

echo -e "$MSG_COLOR$(hostname): Install PHP 8.1\033[0m"
sudo apt install -y --no-install-recommends php8.1

echo -e "$MSG_COLOR$(hostname): Install additional PHP 8.1 modules\033[0m"
sudo apt-get install -y \
    php8.1-cli \
    php8.1-common \
    php8.1-mysql \
    php8.1-pgsql \
    php8.1-pdo \
    php8.1-zip \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-xml \
    php8.1-bcmath \
    php-redis \
    zip \
    unzip

sudo systemctl restart apache2

echo -e "$MSG_COLOR$(hostname): Install Composer (PHP)\033[0m"
cd ~
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo -e "$MSG_COLOR$(hostname): Install dependencies for websockets server\033[0m"
cd /vagrant/ws
sudo -u vagrant bash -c 'composer install'

echo -e "$MSG_COLOR$(hostname): Install dependencies for webapp\033[0m"
cd /vagrant/app
sudo -u vagrant bash -c 'composer install'

echo -e "$MSG_COLOR$(hostname): Copy apache config, disable the default site / enable ours\033[0m"
sudo cp /vagrant/provision/projectA.conf /etc/apache2/sites-available/
sudo a2dissite 000-default.conf
sudo a2ensite projectA.conf
sudo systemctl reload apache2

echo -e "$MSG_COLOR$(hostname): Configure PHP to use Redis for sessions\033[0m"
sudo bash -c 'echo "session.save_handler = redis" >> /etc/php/8.1/apache2/php.ini'
sudo bash -c 'echo "session.save_path = \"tcp://192.168.44.20:6379\"" >> /etc/php/8.1/apache2/php.ini'
sudo systemctl restart apache2

echo -e "$MSG_COLOR$(hostname): Install Consul\033[0m"
sudo apt-get install -y consul

# Determine the hostname and configure Consul accordingly
hostname=$(hostname)

if [[ "$hostname" == "webapp1" ]]; then
    ip_address="192.168.44.11"
    service_name="webapp1"
elif [[ "$hostname" == "webapp2" ]]; then
    ip_address="192.168.44.12"
    service_name="webapp2"
elif [[ "$hostname" == "webapp3" ]]; then
    ip_address="192.168.44.13"
    service_name="webapp3"
else
    echo -e "$MSG_COLOR$(hostname): Unknown hostname. Exiting...\033[0m"
    exit 1
fi

echo -e "$MSG_COLOR$(hostname): Configure Consul for $service_name\033[0m"
cat <<EOF | sudo tee /etc/consul.d/$service_name.json
{
  "service": {
    "name": "$service_name",
    "tags": ["web"],
    "address": "$ip_address",
    "port": 80,
    "check": {
      "http": "http://$ip_address",
      "interval": "10s"
    }
  }
}
EOF

# Create a data directory for Consul
sudo mkdir -p /opt/consul

echo -e "$MSG_COLOR$(hostname): Start Consul Agent\033[0m"
sudo tee /etc/systemd/system/consul.service <<EOF
[Unit]
Description=Consul Agent
After=network.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/ -bind=$ip_address -client=0.0.0.0 -retry-join=192.168.44.15 -data-dir=/opt/consul
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

echo -e "$MSG_COLOR$(hostname): Update deploy date @ .env file\033[0m"
cd /vagrant/app
ISO_DATE=$(TZ=Europe/Lisbon date -Iseconds)
sed -i "s/^DEPLOY_DATE=.*/DEPLOY_DATE=\"$ISO_DATE\"/" .env

echo -e "\033[42m$(hostname): Finished! Visit http://192.168.44.10\033[0m"
