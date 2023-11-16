#!/usr/bin/env bash

# Renew the certificate
certbot renew --dns-cloudflare --dns-cloudflare-credentials /opt/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 30
