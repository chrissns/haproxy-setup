#!/usr/bin/env bash

echo "[Script] Reloading bash"
source ~/.bashrc

echo "[Script] Restarting pm2"
{{pm2path}} restart all --update-env
{{pm2path}} save

echo "[Script] Creating proxy certificate"
bash -c "cat /etc/letsencrypt/live/{{mainDomain}}/fullchain.pem /etc/letsencrypt/live/{{mainDomain}}/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"

echo "[Script] Restarting proxy"
systemctl restart haproxy
