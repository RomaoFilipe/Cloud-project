#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install NGINX and Keepalived\033[0m"
sudo apt-get install -y nginx keepalived

echo -e "$MSG_COLOR$(hostname): Configure NGINX for load balancing\033[0m"
cat <<EOF | sudo tee /etc/nginx/conf.d/loadbalancer.conf
upstream web_backend {
    server 192.168.44.11;
    server 192.168.44.12;
    server 192.168.44.13;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://web_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo -e "$MSG_COLOR$(hostname): Remove default NGINX config\033[0m"
sudo rm /etc/nginx/sites-enabled/default

echo -e "$MSG_COLOR$(hostname): Restart NGINX\033[0m"
sudo systemctl restart nginx

echo -e "$MSG_COLOR$(hostname): Configure Keepalived\033[0m"
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth1  # Interface de rede privada, ajuste conforme necessário
    virtual_router_id 51
    priority 99  # 100 para MASTER, 99 para BACKUP
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass secret
    }

    virtual_ipaddress {
        192.168.44.10
    }

    track_interface {
        eth1
    }

    notify_master "/etc/keepalived/scripts/notify.sh MASTER"
    notify_backup "/etc/keepalived/scripts/notify.sh BACKUP"
    notify_fault "/etc/keepalived/scripts/notify.sh FAULT"
}
EOF

echo -e "$MSG_COLOR$(hostname): Create notify script for Keepalived\033[0m"
sudo mkdir -p /etc/keepalived/scripts
cat <<EOF | sudo tee /etc/keepalived/scripts/notify.sh
#!/bin/bash
TYPE=\$1
echo \$(date) "Transition to \$TYPE" >> /var/log/keepalived.log
EOF
sudo chmod +x /etc/keepalived/scripts/notify.sh

echo -e "$MSG_COLOR$(hostname): Enable and start Keepalived\033[0m"
sudo systemctl enable keepalived
sudo systemctl start keepalived

echo -e "\033[42m$(hostname): Finished!\033[0m"
