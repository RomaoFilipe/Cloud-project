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
sudo mkdir -p /etc/consul.d
sudo mkdir -p /opt/consul
cat <<EOF | sudo tee /etc/consul.d/config.json
{
  "datacenter": "dc1",
  "node_name": "consul-server",
  "server": true,
  "bootstrap_expect": 1,
  "bind_addr": "192.168.44.15",
  "client_addr": "0.0.0.0",
  "data_dir": "/opt/consul",
  "log_level": "INFO",
  "enable_script_checks": true,
  "leave_on_terminate": true,
  "skip_leave_on_interrupt": true,
  "ui": true
}
EOF

echo -e "$MSG_COLOR$(hostname): Create systemd service for Consul\033[0m"
cat <<EOF | sudo tee /etc/systemd/system/consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/
After=network.target

[Service]
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo -e "$MSG_COLOR$(hostname): Enable and start Consul service\033[0m"
sudo systemctl enable consul
sudo systemctl start consul

echo -e "\033[42m$(hostname): Finished!\033[0m"
