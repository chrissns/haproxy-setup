clear
echo "Before you continue, gather all important information."
echo " -> Your E-Mail"
echo " -> Your Domain names"
echo " -> Your Cloudflare token"
echo ""
echo "If you have all this information gathered,"
read -p "Press [Enter] key to start setup..."
echo ""
echo ""

echo "############################################################################"
echo "Update apt"
sudo apt update && sudo apt upgrade -y

echo "############################################################################"
echo "Install cron"
apt install cron -y

echo "############################################################################"
echo "Install Certbot, pip3 and Cloudflare for Certbot"
apt update
apt install certbot python3-pip -y
apt install python3-certbot-dns-cloudflare
# /usr/bin/python3 -m pip install certbot-dns-cloudflare

echo "############################################################################"
echo "Install wget, vim, haproxy, rsync"
sudo apt -y install wget vim haproxy rsync

echo "############################################################################"
echo "Install nvm"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

echo "############################################################################"
echo "Reloading bash"
source ~/.bashrc

echo "############################################################################"
echo "Reloading nvm"
source ~/.nvm/nvm.sh

echo "############################################################################"
echo "Setting up nvm"
nvm install --lts

echo "############################################################################"
echo "Install pm2"
npm i -g pm2

echo "############################################################################"
echo "Install yarn"
npm i -g yarn

echo "############################################################################"
echo "Reloading bash"
source ~/.bashrc

pm2path=$(command -v pm2)
echo "pm2 path is ${pm2path}"

echo "############################################################################"
echo "Removing old config files"
sudo rm /etc/letsencrypt/cli.ini
sudo rm /etc/cron.d/certbot
sudo rm /etc/haproxy/haproxy.cfg

echo "############################################################################"
echo "Creating config directories"
sudo mkdir -p /etc/letsencrypt/
sudo mkdir -p /etc/letsencrypt/live
sudo mkdir -p /etc/ssl/haproxycert/
sudo mkdir -p /etc/haproxy/
sudo mkdir -p /opt/.secrets/certbot/

echo "############################################################################"
echo "Creating config files"
sudo touch /opt/.secrets/certbot/cloudflare.ini
chown -R $USER /opt/.secrets/
chmod 600 /opt/.secrets/certbot/cloudflare.ini
sudo cp ./configs/certbot /etc/cron.d/
sudo cp ./configs/cli.ini /etc/letsencrypt/
sudo cp ./configs/haproxy.cfg /etc/haproxy/

mkdir /etc/haproxy/errors
touch /etc/haproxy/errors/400.http
touch /etc/haproxy/errors/403.http
touch /etc/haproxy/errors/408.http
touch /etc/haproxy/errors/500.http
touch /etc/haproxy/errors/502.http
touch /etc/haproxy/errors/503.http
touch /etc/haproxy/errors/504.http

echo "############################################################################"
echo "Install mustache"
curl -sSL https://git.io/get-mo -o mo
. "./mo"
echo "Mustache was installed successfully" | mo

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

echo "Before you continue check for errors above!"
read -p "Press [Enter] key to continue..."
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

echo "############################################################################"
clear
echo "Enter your configuration."

read -p 'Which email do you want to use for ssl certificates? > ' certbotMail
read -p 'Which domains should be configured? (seperated by spaces) > ' domains

echo ""

echo "Your certbot mail address: ${certbotMail}"
echo "Your domains: ${domains}"

echo "############################################################################"
clear
echo "Setting up Cloudflare Certbot..."
echo "Please create a restricted token with the \"Zone:DNS:Edit\" permissions"
read -p 'Enter your cloudflare token > ' cloudflareToken
echo "Token will be saved to ~/.secrets/certbot/cloudflare.ini"
echo "dns_cloudflare_api_token = ${cloudflareToken}" > /opt/.secrets/certbot/cloudflare.ini

echo "############################################################################"
echo "Registering following domains:"
domainsArr=($domains)
mainDomain=${domainsArr[0]}
certbotCmd="sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /opt/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 30 --email ${certbotMail} --agree-tos"
for x in "${domainsArr[@]}"
do
    echo "$x"
    certbotCmd+=" -d $x"
done

mkdir -p /etc/letsencrypt/live/${mainDomain}/
echo "export CERTS_DIR=\"/etc/letsencrypt/live/${mainDomain}/\"" >> ~/.bashrc

echo "############################################################################"
echo "Creating post renew hook"
sudo touch /opt/post-renew.sh
sudo chown $USER /opt/post-renew.sh
sudo cat ./scripts/post-renew.sh | mo > /opt/post-renew.sh

echo "############################################################################"
echo "Configuring certbot"
echo "Setting up with main domain ${mainDomain}"
$certbotCmd

echo "############################################################################"
echo "Reloading HAProxy"
systemctl restart haproxy

echo "############################################################################"
echo "To make sure all your backends are getting started on boot please follow those steps:"
pm2 startup

echo "############################################################################"
echo "Generating ssh-key for GitHub actions"
mkdir -p ~/.ssh/
ssh-keygen -m PEM -t rsa -b 4096 -f ~/.ssh/github-actions
touch ~/.ssh/authorized_keys
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys

echo ""
echo ""
echo "Install and setup is done. Check for any errors above."
echo "Use env var \$CERTS_DIR in your backends to use outgoing ssl and firewall rules or use the proxy to expose your backends."
echo "Use \"sudo certbot renew --dry-run\" verify the certbot configuration."
echo ""
echo "Please also be aware that changing your default node version will also require you to change the deploy hooks for pm2 restart to work."
echo ""
echo ""
echo "Use the following command to view the ssh private key for rsync GitHub action deployments:"
echo "cat ~/.ssh/github-actions"
echo ""
echo ""
