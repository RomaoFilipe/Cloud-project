#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install NGINX\033[0m"
sudo apt-get install -y nginx

echo -e "$MSG_COLOR$(hostname): Configure NGINX as Load Balancer\033[0m"
sudo bash -c 'cat > /etc/nginx/sites-available/loadbalancer <<EOF
upstream webapp {
    server 192.168.44.21;
    server 192.168.44.22;
}

server {
    listen 80;

    location / {
        proxy_pass http://webapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

sudo ln -s /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo -e "\033[42m$(hostname): Load Balancer setup completed\033[0m"
