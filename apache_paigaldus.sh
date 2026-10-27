#!/bin/bash


faili_olemasolu=$(dpkg-query -W -f='${Status}' apache2 | grep -c 'ok')
if [ $faili_olemasolu -eq 0 ]; then
	read -p "kas paigaldan apache2: " kas
	if [ "$kas" = "y" ]; then
		echo "Paigaldan apache2."
		sudo apt install apache2
	else
		echo "apache2 paigaldus tühistati"
	fi
elif [ $faili_olemasolu -eq 1 ]; then
	echo "Apache2 on olemas. Käivitan apache2."
	service apache2 start
	service apache2 status
fi
