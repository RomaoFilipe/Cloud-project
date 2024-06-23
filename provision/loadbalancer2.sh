#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install NGINX and Keepalived\033[0m"
sudo apt-get install -y nginx keepalived

echo -e "$MSG_COLOR$(hostname): Configure NGINX for load balancing\033[0m"
sudo tee /etc/nginx/conf.d/loadbalancer.conf > /dev/null <<EOF
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
sudo rm -f /etc/nginx/sites-enabled/default

echo -e "$MSG_COLOR$(hostname): Restart NGINX\033[0m"
sudo systemctl restart nginx

echo -e "$MSG_COLOR$(hostname): Configure Keepalived\033[0m"

# Determine the load balancer's IP and priority
if [[ "$(hostname)" == "loadbalancer1" ]]; then
    LB_IP="192.168.44.21"
    PRIORITY=100
elif [[ "$(hostname)" == "loadbalancer2" ]]; then
    LB_IP="192.168.44.22"
    PRIORITY=99
else
    echo -e "$MSG_COLOR$(hostname): Unknown hostname. Exiting...\033[0m"
    exit 1
fi

sudo tee /etc/keepalived/keepalived.conf > /dev/null <<EOF
vrrp_instance VI_1 {
    state BACKUP
    interface eth1  # Interface de rede privada, ajuste conforme necessário
    virtual_router_id 51
    priority $PRIORITY
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
sudo tee /etc/keepalived/scripts/notify.sh > /dev/null <<EOF
#!/bin/bash
TYPE=\$1
echo \$(date) "Transition to \$TYPE" >> /var/log/keepalived.log
EOF
sudo chmod +x /etc/keepalived/scripts/notify.sh

echo -e "$MSG_COLOR$(hostname): Enable and start Keepalived\033[0m"
sudo systemctl enable keepalived
sudo systemctl start keepalived

echo -e "$MSG_COLOR$(hostname): Install Consul\033[0m"
sudo apt-get install -y consul

echo -e "$MSG_COLOR$(hostname): Configure Consul for $LB_IP\033[0m"
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/loadbalancer.json > /dev/null <<EOF
{
  "service": {
    "name": "$(hostname)",
    "tags": ["loadbalancer"],
    "address": "$LB_IP",
    "port": 80,
    "check": {
      "http": "http://$LB_IP",
      "interval": "10s"
    }
  }
}
EOF

echo -e "$MSG_COLOR$(hostname): Start Consul Agent\033[0m"
sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul Agent
After=network.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/ -bind=$LB_IP -client=0.0.0.0 -retry-join=192.168.44.15 -data-dir=/opt/consul
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /opt/consul
sudo chown vagrant:vagrant /opt/consul

sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

echo -e "$MSG_COLOR$(hostname): Finished!\033[0m"
