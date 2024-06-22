#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL\033[0m"
sudo apt-get install -y postgresql-14

# Temporarily set PostgreSQL to trust authentication for local connections
echo -e "$MSG_COLOR$(hostname): Temporarily set PostgreSQL to trust authentication for local connections\033[0m"
sudo sed -i "s/local\s*all\s*all\s*peer/local all all trust/" /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/host\s*all\s*all\s*127.0.0.1\/32\s*scram-sha-256/host all all 127.0.0.1\/32 trust/" /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/host\s*all\s*all\s*::1\/128\s*scram-sha-256/host all all ::1\/128 trust/" /etc/postgresql/14/main/pg_hba.conf

sudo service postgresql restart

echo -e "$MSG_COLOR$(hostname): Create a new PostgreSQL user and database\033[0m"
sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';" || true
sudo -u postgres psql -c "CREATE DATABASE mydatabase OWNER myuser;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

echo -e "$MSG_COLOR$(hostname): Import dump.sql and set user privileges\033[0m"
sudo -u postgres psql -d mydatabase -f /vagrant/provision/dump.sql
sudo -u postgres psql -d mydatabase -c "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE messages TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT USAGE, SELECT, UPDATE ON SEQUENCE messages_id_seq TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

# Revert pg_hba.conf back to md5 authentication
echo -e "$MSG_COLOR$(hostname): Revert pg_hba.conf back to md5 authentication\033[0m"
sudo sed -i "s/local\s*all\s*all\s*trust/local all all md5/" /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/host\s*all\s*all\s*127.0.0.1\/32\s*trust/host all all 127.0.0.1\/32 md5/" /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/host\s*all\s*all\s*::1\/128\s*trust/host all all ::1\/128 md5/" /etc/postgresql/14/main/pg_hba.conf

sudo service postgresql restart

echo -e "$MSG_COLOR$(hostname): View users and databases in PostgreSQL\033[0m"
sudo -u postgres psql -c "\du"
sudo -u postgres psql -c "\list"
sudo -u postgres psql -d mydatabase -c "\dt"

echo -e "\033[42m$(hostname): Finished!\033[0m"
