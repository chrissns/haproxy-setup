#!/usr/bin/env bash

echo "[Oneline Installer] Using simple oneline setup process."

cd /tmp/
echo "[Oneline Installer] Checking if an old version of the installer is cached."
sudo rm -rf /tmp/haproxy-setup/

echo "[Oneline Installer] Checking git installation."
if ! command -v git &> /dev/null
then
    echo "[Oneline Installer] Git not found, installing..."
    sudo apt install git -y
else
    echo "[Oneline Installer] Git found."
fi

echo "[Oneline Installer] Cloning repository..."
git clone https://github.com/chrissns/haproxy-setup.git /tmp/haproxy-setup/
echo "[Oneline Installer] Repository cloned."

echo "[Oneline Installer] Running installation process..."
cd /tmp/haproxy-setup
bash /tmp/haproxy-setup/setup-haproxy.sh
echo "[Oneline Installer] Installation process completed."
