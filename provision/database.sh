#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL\033[0m"
sudo apt-get install -y postgresql-14

# Change to /tmp directory since the next commands will run as "postgres" user
# to avoid could not change directory to "/home/vagrant": Permission denied
cd /tmp

echo -e "$MSG_COLOR$(hostname): Create a new PostgreSQL user and database\033[0m"
sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';"
sudo -u postgres psql -c "CREATE DATABASE mydatabase OWNER myuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

sudo service postgresql restart

echo -e "$MSG_COLOR$(hostname): Import dump.sql and set user privileges\033[0m"
sudo -u postgres psql -d mydatabase -f /vagrant/provision/dump.sql
sudo -u postgres psql -d mydatabase -c "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE messages TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT USAGE, SELECT, UPDATE ON SEQUENCE messages_id_seq TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myuser;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"

echo -e "$MSG_COLOR$(hostname): View users and databases in PostgreSQL\033[0m"
sudo -u postgres psql -c "\du"
sudo -u postgres psql -c "\list"
sudo -u postgres psql -d mydatabase -c "\dt"

echo -e "\033[42m$(hostname): Finished!\033[0m"
