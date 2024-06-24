# Imagem a ser usada
FROM ubuntu:20.04

# Argumentos para a zona de tempo
ARG DEBIAN_FRONTEND=noninteractive

# Atualizar e instalar pacotes
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update && apt-get install -y \
    apache2 \
    php8.1 \
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
    zip \
    unzip \
    postgresql \
    postgresql-contrib \
    curl \
    git \
    && apt-get clean

# Instalar o Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Copiar ficheiros de configuração e scripts necessários
COPY ./provision/projectB.conf /etc/apache2/sites-available/

# Habilitar o site e módulos do Apache
RUN a2dissite 000-default.conf \
    && a2ensite projectB.conf \
    && a2enmod rewrite

# Configuração do PostgreSQL
USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER myuser WITH SUPERUSER PASSWORD 'mypassword';" \
    && createdb -O myuser mydatabase

# Voltar para o utilizar root para continuar a configuração
USER root

# Copiar o dump.sql e outras configurações para o container
COPY ./provision/dump.sql /tmp/dump.sql

# Importar o dump.sql para a base de dados
USER postgres
RUN /etc/init.d/postgresql start \
    && psql -d mydatabase -f /tmp/dump.sql \
    && psql -d mydatabase -c "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE messages TO myuser;" \
    && psql -d mydatabase -c "GRANT USAGE, SELECT, UPDATE ON SEQUENCE messages_id_seq TO myuser;" \
    && psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;" \
    && psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myuser;" \
    && psql -d mydatabase -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

# Volta para o utilizador root
USER root

# Copiar e instalar as dependências do projeto
COPY ./ws /var/www/ws
COPY ./app /var/www/app

# Definir as permissões corretas para os ficheiros e diretórios
RUN chown -R www-data:www-data /var/www/app/public_html \
    && chmod -R 755 /var/www/app/public_html

WORKDIR /var/www/ws
RUN composer install

WORKDIR /var/www/app
RUN composer install

# Atualizar a data de deploy no ficheiro .env
RUN ISO_DATE=$(TZ=Europe/Lisbon date -Iseconds) \
    && sed -i "s/^DEPLOY_DATE=.*/DEPLOY_DATE=\"$ISO_DATE\"/" .env

# Porta do Apache
EXPOSE 80

# Definir o comando padrão para iniciar o Apache e o PostgreSQL
CMD service postgresql start && apachectl -D FOREGROUND
