# Dockerfile.ws

FROM ubuntu:20.04

# Argumentos para a zona de tempo
ARG DEBIAN_FRONTEND=noninteractive

# Atualizar e instalar pacotes
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update && apt-get install -y \
    php8.1-cli \
    php8.1-common \
    php8.1-zip \
    unzip \
    git \
    curl \
    sudo \
    && apt-get clean

# Instalar o Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Copiar e instalar as dependências do projeto
COPY ./ws /var/www/ws
WORKDIR /var/www/ws

# Definir variável de ambiente para permitir execução do Composer como root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Instalar dependências do Composer
RUN composer install

# Expor a porta do WebSocket
EXPOSE 8000

# Comando para iniciar o servidor WebSocket
CMD ["php", "/var/www/ws/websockets_server.php"]
