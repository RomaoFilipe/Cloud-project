#!/bin/bash
MSG_COLOR="\033[41m"

echo -e "$MSG_COLOR$(hostname): Update package lists\033[0m"
sudo apt-get update

echo -e "$MSG_COLOR$(hostname): Install necessary packages\033[0m"
sudo apt-get install -y unzip curl

echo -e "$MSG_COLOR$(hostname): Install Consul\033[0m"
wget https://releases.hashicorp.com/consul/1.10.1/consul_1.10.1_linux_amd64.zip
unzip consul_1.10.1_linux_amd64.zip
sudo mv consul /usr/local/bin/
rm consul_1.10.1_linux_amd64.zip

echo -e "$MSG_COLOR$(hostname): Configure Consul\033[0m"
sudo mkdir /etc/consul.d
cat <<EOF | sudo tee /etc/consul.d/config.json
{
  "datacenter": "dc1",
  "node_name": "consul-server",
  "server": true,
  "bootstrap_expect": 1,
  "bind_addr": "192.168.44.11",
  "client_addr": "0.0.0.0",
  "data_dir": "/opt/consul",
  "log_level": "INFO",
  "enable_script_checks": true,
  "leave_on_terminate": true,
  "skip_leave_on_interrupt": true
}
EOF

echo -e "$MSG_COLOR$(hostname): Start Consul\033[0m"
sudo consul agent -config-dir=/etc/consul.d &

echo -e "\033[42m$(hostname): Finished!\033[0m"
