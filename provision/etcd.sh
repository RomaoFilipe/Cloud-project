#!/bin/bash
sudo apt-get update
sudo apt-get install -y etcd

cat <<EOF | sudo tee /etc/default/etcd
ETCD_NAME="etcd0"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.44.50:2379"
EOF

sudo systemctl enable etcd
sudo systemctl start etcd
