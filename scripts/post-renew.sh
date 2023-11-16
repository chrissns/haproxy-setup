#!/usr/bin/env bash

GREEN="\033[0;32m"

echo "${GREEN}[Script] Reloading bash"
source ~/.bashrc

echo "${GREEN}[Script] Restarting pm2"
{{pm2path}} restart all --update-env
{{pm2path}} save

echo "${GREEN}[Script] Creating proxy certificate"
bash -c "cat /etc/letsencrypt/live/{{mainDomain}}/fullchain.pem /etc/letsencrypt/live/{{mainDomain}}/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"

echo "${GREEN}[Script] Restarting proxy"
systemctl restart haproxy
