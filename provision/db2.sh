#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install PostgreSQL and Patroni dependencies\033[0m"
sudo apt-get install -y etcd postgresql-14 python3-pip
sudo pip3 install patroni[etcd]

echo -e "$MSG_COLOR$(hostname): Configure PostgreSQL\033[0m"
# Update pg_hba.conf
sudo bash -c "echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/14/main/pg_hba.conf"

# Update postgresql.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/14/main/postgresql.conf

echo -e "$MSG_COLOR$(hostname): Configure Patroni\033[0m"
cat <<EOF | sudo tee /etc/patroni.yml
scope: postgresql-ha
namespace: /service/
name: postgresql1

restapi:
  listen: 0.0.0.0:8008
  connect_address: 192.168.44.31:8008

etcd:
  hosts: 192.168.44.50:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        wal_level: replica
        hot_standby: "on"
        wal_keep_size: 8GB
        max_wal_senders: 10
        max_replication_slots: 10

  initdb:
  - encoding: UTF8
  - data-checksums

  users:
    postgres:
      password: password
    myuser:
      password: mypassword

  post_init: /etc/patroni_post_init.sh

  pg_hba:
  - host all all 0.0.0.0/0 md5

postgresql:
  listen: 0.0.0.0:5432
  connect_address: 192.168.44.31:5432
  data_dir: /var/lib/postgresql/14/main
  bin_dir: /usr/lib/postgresql/14/bin
  authentication:
    superuser:
      username: postgres
      password: password
    replication:
      username: replicator
      password: password
  parameters:
    unix_socket_directories: '/var/run/postgresql'
EOF

echo -e "$MSG_COLOR$(hostname): Create Patroni post-init script\033[0m"
cat <<EOF | sudo tee /etc/patroni_post_init.sh
#!/bin/bash
psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';"
psql -c "CREATE DATABASE mydatabase OWNER myuser;"
psql -c "GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;"
psql -d mydatabase -f /vagrant/provision/dump.sql
EOF

sudo chmod +x /etc/patroni_post_init.sh

echo -e "$MSG_COLOR$(hostname): Create Patroni systemd service file\033[0m"
cat <<EOF | sudo tee /etc/systemd/system/patroni.service
[Unit]
Description=Patroni
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/patroni /etc/patroni.yml
KillMode=process
TimeoutStopSec=30
Restart=on-failure
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo -e "$MSG_COLOR$(hostname): Enable and start Patroni\033[0m"
sudo systemctl daemon-reload
sudo systemctl enable patroni
sudo systemctl start patroni

echo -e "\033[42m$(hostname): Database server setup completed\033[0m"
