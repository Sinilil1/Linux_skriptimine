#!/bin/bash


#read -p "Sisesta sihtkausta nimi täielik aadress: " sihtkaust
#read -p "Kuhu soovid backupi salvestusasukoha täielik aadress: " salvestuskoht
salvestuskoht="/home_bcp"

kuupaev=$(date +%d.%m.%Y)


#tar -czvf "$salvestuskoht/backup.$kuupaev.tar.gz" -C "$sihtkaust" .


for sihtkaust in /home/*; do
    if [ -d "$sihtkaust" ]; then
        nimi=$(basename "$sihtkaust")

        echo "Teen backupi kaustast: $nimi"

        tar -czf "$salvestuskoht/$nimi-backup.$kuupaev.tar.gz" \
            -C /home "$nimi"
    fi
done

