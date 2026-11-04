#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

apt update
apt install wget ca-certificates gnupg debconf-utils

echo "Kontrollin, kas MySQL Server 8.0 on juba paigaldatud..."

if dpkg-query -W -f='${Version}' mysql-server-8.0 &>/dev/null | grep -q '^8\.0'; then
    echo "MySQL Server 8.0 on juba paigaldatud. Jätan paigaldamise vahele."

else
    echo "MySQL Server 8.0 puudub. Alustan paigaldamist..."

    # Laen alla ametliku Oracle MySQL APT konfiguratsiooni
    wget -O /tmp/mysql-apt-config_0.8.40-1_all.deb \
    https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb

    # Eelseadistan MySQL APT konfiguratsiooni
    debconf-set-selections <<EOF
mysql-apt-config mysql-apt-config/select-server select mysql-8.0
mysql-apt-config mysql-apt-config/select-tools select
mysql-apt-config mysql-apt-config/select-product select Ok
EOF

    # Paigaldan MySQL APT konfiguratsioonipaketi
    dpkg -i /tmp/mysql-apt-config_0.8.40-1_all.deb

    # Eelseadistan MySQL Serveri paigalduse
    debconf-set-selections <<EOF
mysql-server mysql-server/root_password password qwerty
mysql-server mysql-server/root_password_again password qwerty
mysql-server mysql-server/default-auth-override select Use Strong Password Encryption
EOF

    apt update
    apt install -y mysql-server

    echo "MySQL Server 8.0 paigaldamine lõpetatud."
fi

#__________________________
# MySQL teenuse käivitamine
#--------------------------


systemctl enable mysql
systemctl start mysql

# Root kasutaja konfiguratsioonifail
echo "Loon faili /root/.my.cnf..."

cat > /root/.my.cnf <<EOF
[client]
host=localhost
user=root
password=$MYSQL_ROOT_PASSWORD
EOF

chmod 600 /root/.my.cnf
mysql --version
systemctl is-active mysql
systemctl is-enabled mysql
ls -l /root/.my.cnf

# Apache2 kontroll enne paigaldamist
echo "Kontrollin, kas Apache2 on juba paigaldatud..."

if dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -q "install ok installed"; then
    echo "Apache2 on juba paigaldatud. Paigaldamist ei korrata."
else
    echo "Apache2 puudub. Alustan paigaldamist..."

    apt install -y apache2

    echo "Apache2 paigaldamine lõpetatud."
fi

# Apache2 teenuse käivitamine
echo "Seadistan Apache2 teenuse..."

systemctl enable apache2
systemctl start apache2

# Apache2 kontroll
echo "===== APACHE2 KONTROLL ====="

echo "Apache2 teenuse olek:"
systemctl is-active apache2

echo "Apache2 automaatne käivitamine:"
systemctl is-enabled apache2

echo "Apache2 versioon:"
apache2 -v

echo "Apache2 seadistamine lõpetatud!"

#-----------------------------------
# Apache2 paigaldamist
#-----------------------------------

echo "Kontrollin, kas Apache2 on juba paigaldatud..."

if dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -q "install ok installed"; then
    echo "Apache2 on juba paigaldatud. Paigaldamist ei korrata."
else
    echo "Apache2 puudub. Alustan paigaldamist..."

    apt install -y apache2

    echo "Apache2 paigaldamine lõpetatud."
fi

# Apache2 teenuse käivitamine
echo "Seadistan Apache2 teenuse..."

systemctl enable apache2
systemctl start apache2

# Apache2 kontroll
systemctl is-active apache2
systemctl is-enabled apache2
apache2 -v
echo "Apache2 seadistamine lõpetatud!"

# Apache vaikimisi veebilehe loomine

echo "Loon Apache veebilehe..."

INSTALL_DATE=$(date "+%Y-%m-%d %H:%M:%S")

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="et">
<head>
    <meta charset="UTF-8">
    <title>LAMP Server</title>
</head>
<body>
    <h1>LAMP server töötab!</h1>

    <p>Õpilane: Ricahrd p>
    <p>Grupp: ITS</p>
    <p>Paigaldatud: $INSTALL_DATE</p>
</body>
</html>
EOF

echo "Apache veebileht loodud!"


echo "_-_-_-_-_-_-_-_-_-_-_-_-_"
echo "Php paigaldus"
echo "-_-_-_-_-_-_-_-_-_-_-_-_-"


echo "Kontroll, kas PHP 8.x on juba paigaldatud..."

if dpkg-query -W -f='${Status}' php 2>/dev/null | grep -q "install ok installed"; then
    echo "PHP 8.2 on juba paigaldatud."
    php -v
else
    echo "PHP 8.2 puudub. Alustan paigaldamist..."

    apt install -y \
        php8.3 \
        php8.3-cli \
        php8.3-common \
        php8.3-mysql \
        libapache2-mod-php8.3

    echo "PHP 8.3 paigaldamine lõpetatud."
fi

# Apache2 taaskäivitamine
echo "Taaskäivitan Apache2 teenuse..."

systemctl restart apache2

# PHP testfaili loomine
echo "Loon PHP testfaili..."

cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

echo "PHP testfail loodud!"


echo "===== PHP KONTROLL ====="

echo "PHP versioon:"
php -v

echo "Apache2 teenuse olek:"
systemctl is-active apache2

echo "PHP seadistamine lõpetatud!"

#echo "_-_-_-_-_-_-_-_-_-_-_-_-_"
#echo "Lõpuraport"
#echo "-_-_-_-_-_-_-_-_-_-_-_-_-"


echo ""
echo "========== LAMP REPORT =========="

# Apache2
echo ""
echo "Apache2:"
echo "Version: $(apache2 -v | head -n 1)"
echo "Status: $(systemctl is-active apache2)"
echo "Autostart: $(systemctl is-enabled apache2)"

# PHP
echo ""
echo "PHP:"
echo "Version: $(php -v | head -n 1)"

# MySQL
echo ""
echo "MySQL:"
echo "Version: $(mysql --version)"
echo "Status: $(systemctl is-active mysql)"
echo "Autostart: $(systemctl is-enabled mysql)"

# Veebifailid
echo ""
echo "Apache default page:"
if [ -f /var/www/html/index.html ]; then
    echo "/var/www/html/index.html - olemas"
else
    echo "/var/www/html/index.html - puudub"
fi

echo ""
echo "PHP test page:"
if [ -f /var/www/html/info.php ]; then
    echo "/var/www/html/info.php - olemas"
else
    echo "/var/www/html/info.php - puudub"
fi

# MySQL konfiguratsioonifail
echo ""
echo "MySQL root configuration:"
if [ -f /root/.my.cnf ]; then
    echo "/root/.my.cnf - olemas"
else
    echo "/root/.my.cnf - puudub"
fi

echo ""
echo "================================="
echo "LAMP paigaldamine ja kontroll lõpetatud!"
