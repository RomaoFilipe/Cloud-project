#!/bin/bash
 
# Instalar NGINX
echo "Instalando NGINX..."
sudo apt-get update
sudo apt-get install -y nginx
 
# Configurar NGINX para balanceamento de carga
echo "Configurando NGINX..."
cat <<EOL | sudo tee /etc/nginx/sites-available/default
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}
 
upstream web_servers {
    server 192.168.44.21;  # IP do servidor web1
    server 192.168.44.22;  # IP do servidor web2
    server 192.168.44.23;  # IP do servidor web3
}
 
upstream websocket {
    server 192.168.44.21:8000;  # Porta do servidor WebSocket no web1
    server 192.168.44.22:8000;  # Porta do servidor WebSocket no web2
    server 192.168.44.23:8000;  # Porta do servidor WebSocket no web3
}
 
server {
    listen 80;
    server_name _;
 
    location / {
        proxy_pass http://web_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
 
    location /ws/ {
        proxy_pass http://websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
    }
 
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
}
EOL
 
# Reiniciar NGINX para aplicar as alterações
echo "Reiniciando NGINX..."
sudo nginx -t && sudo systemctl restart nginx
 
echo "Configuração do NGINX concluída."