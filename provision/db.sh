#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL\033[0m"
sudo apt-get install -y postgresql-14

echo -e "$MSG_COLOR$(hostname): Configure PostgreSQL\033[0m"
sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';"
sudo -u postgres psql -c "CREATE DATABASE mydatabase OWNER myuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

echo -e "$MSG_COLOR$(hostname): Import database schema\033[0m"
sudo -u postgres psql -d mydatabase -f /vagrant/provision/dump.sql

echo -e "\033[42m$(hostname): Database server setup completed\033[0m"
