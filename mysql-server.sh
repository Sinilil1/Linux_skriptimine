#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

# Vajalikud paketid
apt update
apt install -y gnupg ca-certificates debconf-utils wget

# MySQL root parool
read -rsp "MySQL root parool: " MYSQL_ROOT_PASSWORD
echo

# MySQL APT konfiguratsioon
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-tools select Disabled" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-product select Ok" | debconf-set-selections

# MySQL root parool ja autentimine
echo "mysql-community-server mysql-community-server/root-pass password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-community-server mysql-community-server/re-root-pass password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

# MySQL APT pakett
wget -O /tmp/mysql-apt-config.deb https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb
dpkg -i /tmp/mysql-apt-config.deb

# MySQL Server paigaldamine
apt update
apt install -y mysql-server

# Teenuse käivitamine
systemctl enable --now mysql

# .my.cnf loomine
cat > /root/.my.cnf <<EOF
[client]
host=localhost
user=root
password=$MYSQL_ROOT_PASSWORD
EOF

chmod 600 /root/.my.cnf

unset MYSQL_ROOT_PASSWORD

# Kontroll
mysql -e "SELECT VERSION();"

echo "MySQL Server paigaldatud!"
