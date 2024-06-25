#!/bin/bash

NODE_ID=$1
IP="192.168.44.3${NODE_ID}"
ETCD_INITIAL_CLUSTER="database1=http://192.168.44.31:2380,database2=http://192.168.44.32:2380,database3=http://192.168.44.33:2380"

# Install dependencies
sudo apt-get update
sudo apt-get install -y etcd postgresql postgresql-contrib python3-pip python3-psycopg2
sudo pip3 install patroni[etcd]

# Configure etcd
cat <<EOF | sudo tee /etc/default/etcd
ETCD_LISTEN_PEER_URLS="http://${IP}:2380"
ETCD_LISTEN_CLIENT_URLS="http://${IP}:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${IP}:2380"
ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER}"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_ADVERTISE_CLIENT_URLS="http://${IP}:2379"
EOF

sudo systemctl restart etcd

# Configure Patroni
cat <<EOF | sudo tee /etc/patroni.yml
scope: postgres
namespace: /db/
name: database${NODE_ID}

restapi:
  listen: ${IP}:8008
  connect_address: ${IP}:8008

etcd:
  host: ${IP}:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
        max_connections: 100
        max_locks_per_transaction: 64
        max_worker_processes: 8
        wal_level: replica
        hot_standby: "on"
        wal_keep_segments: 8
        max_wal_senders: 5
        max_replication_slots: 5
  initdb:
  - encoding: UTF8
  - locale: en_US.UTF-8

postgresql:
  listen: ${IP}:5432
  connect_address: ${IP}:5432
  data_dir: /var/lib/postgresql/12/main
  bin_dir: /usr/lib/postgresql/12/bin
  authentication:
    replication:
      username: replica
      password: password
    superuser:
      username: postgres
      password: password
  parameters:
    unix_socket_directories: '/var/run/postgresql'

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
EOF

# Create systemd service for Patroni
cat <<EOF | sudo tee /etc/systemd/system/patroni.service
[Unit]
Description=Patroni PostgreSQL Cluster Manager
After=network.target

[Service]
Type=simple
User=postgres
ExecStart=/usr/local/bin/patroni /etc/patroni.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Patroni service
sudo systemctl daemon-reload
sudo systemctl enable patroni
sudo systemctl start patroni