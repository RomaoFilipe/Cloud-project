# Use uma imagem base adequada
FROM ubuntu:20.04

# Define o frontend não interativo para o apt
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza os pacotes e instala os pacotes necessários
RUN apt-get update && \
    apt-get install -y \
    php8.1-cli \
    php8.1-common \
    curl \
    sudo

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Cria o diretório /var/www/ws e define como o diretório de trabalho
WORKDIR /var/www/ws

# Copia os arquivos da aplicação para o contêiner
COPY . /var/www/ws

# Instala as dependências do servidor WebSocket
RUN composer install

# Cria o serviço systemd para o servidor WebSocket
RUN echo '[Unit]\n\
Description=WebSockets Server\n\
After=network.target\n\
\n\
[Service]\n\
Type=simple\n\
User=root\n\
WorkingDirectory=/var/www/ws\n\
ExecStart=/usr/bin/php /var/www/ws/websockets_server.php\n\
Restart=always\n\
\n\
[Install]\n\
WantedBy=multi-user.target\n' > /etc/systemd/system/websockets.service

# Ativa e inicia o serviço WebSocket
RUN systemctl enable websockets.service && \
    systemctl start websockets.service

# Exibe uma mensagem final
CMD echo -e "\033[42m$(hostname): Finished!\033[0m" && tail -f /dev/null
