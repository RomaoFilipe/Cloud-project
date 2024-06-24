# Dockerfile para webapps e websockets
FROM php:8.1-apache

# Instalação de dependências
RUN apt-get update && apt-get install -y \
    libpq-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_pgsql

# Instalação do Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Habilitação de módulos do Apache
RUN a2enmod rewrite

# Copiar arquivos da aplicação
COPY ./app /var/www/html
COPY ./ws /var/www/ws

# Diretório de trabalho
WORKDIR /var/www/html

# Instalação de dependências PHP
RUN composer install

# Diretório de trabalho para websockets
WORKDIR /var/www/ws

# Instalação de dependências PHP para websockets
RUN composer install

# Expor porta
EXPOSE 8000
