#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL\033[0m"
sudo apt-get install -y postgresql-14

echo -e "$MSG_COLOR$(hostname): Create a new PostgreSQL user and database\033[0m"
sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';"
sudo -u postgres psql -c "CREATE DATABASE mydatabase OWNER myuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

echo -e "$MSG_COLOR$(hostname): Update pg_hba.conf for md5 authentication\033[0m"
sudo bash -c 'echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/14/main/pg_hba.conf'

echo -e "$MSG_COLOR$(hostname): Update postgresql.conf to listen on all addresses\033[0m"
sudo sed -i "s/^#listen_addresses = .*/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf

echo -e "$MSG_COLOR$(hostname): Restart PostgreSQL\033[0m"
sudo systemctl restart postgresql

echo -e "$MSG_COLOR$(hostname): Import dump.sql and set user privileges\033[0m"
sudo -u postgres psql -d mydatabase -f /vagrant/provision/dump.sql
sudo -u postgres psql -d mydatabase -c "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE messages TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT USAGE, SELECT, UPDATE ON SEQUENCE messages_id_seq TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

echo -e "$MSG_COLOR$(hostname): Install Redis\033[0m"
sudo apt-get install -y redis-server

echo -e "$MSG_COLOR$(hostname): Configure Redis to bind to all interfaces\033[0m"
sudo sed -i "s/^bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf
sudo sed -i "s/^protected-mode yes/protected-mode no/" /etc/redis/redis.conf

echo -e "$MSG_COLOR$(hostname): Restart Redis\033[0m"
sudo systemctl restart redis-server

echo -e "$MSG_COLOR$(hostname): Finished provisioning database and Redis!\033[0m"
