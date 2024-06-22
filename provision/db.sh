#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL\033[0m"
sudo apt-get install -y postgresql postgresql-contrib

echo -e "$MSG_COLOR$(hostname): Configure PostgreSQL\033[0m"
sudo -u postgres psql -c "CREATE ROLE myuser WITH LOGIN PASSWORD 'mypassword';"
sudo -u postgres psql -c "CREATE DATABASE mydatabase OWNER myuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

# Allow remote connections to PostgreSQL
echo -e "$MSG_COLOR$(hostname): Allow remote connections\033[0m"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "host all  all    0.0.0.0/0  md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf

echo -e "$MSG_COLOR$(hostname): Restart PostgreSQL\033[0m"
sudo systemctl restart postgresql

# Check if dump.sql exists and import database schema
DUMP_FILE="/vagrant/provision/dump.sql"
if [ -f "$DUMP_FILE" ]; then
    echo -e "$MSG_COLOR$(hostname): Import database schema\033[0m"
    sudo -u postgres psql -d mydatabase -f "$DUMP_FILE"
else
    echo -e "\033[41m$(hostname): $DUMP_FILE not found, skipping import\033[0m"
fi

echo -e "\033[42m$(hostname): Database server setup completed\033[0m"
