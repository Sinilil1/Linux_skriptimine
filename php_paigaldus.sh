#!/bin/bash


#apt install php.8.3 libaapache2-mod-php8.3 php8.3-mysql


#konrollib kas käsk annab erroi ja tegutseb vastavalt.
if ! dpkg -s php8.3 &>/dev/null ; then

    echo "Paigaldame PHP ja vajalikud lisad"

#värskendab paketihalduri ja eemadab  terminali väljunidd
    apt-get update &>/dev/null
#installib php ja eemaldab terminal väljundid kasutadaes >/dev/null (kirjutab need musta auku)
    apt-get install -y php8.3 libapache2-mod-php8.3 php8.3-mysql >/dev/null

    echo "PHP on paigaldatud"

else
#vaatab mis php versioon on paigaltatud ja salvestab väljundi muutujasse
    phpv=$(php -v | grep -oP '^PHP \K[0-9]+\.[0-9]+\.[0-9]+')


    echo "Php on juba paigaltatud!"
    echo "Php versiooniks on php $phpv "
fi
