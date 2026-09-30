#!/bin/bash

triip(){
	echo "============================"
}

info_kiri(){
	triip
	echo "SÜSTEEMI INFO"
	triip

	hostname
	uname -r
	whoami
}

info_kiri
info_kiri
