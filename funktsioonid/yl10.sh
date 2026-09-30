#!/bin/bash

#@ kõik funktsioonile antud argumendid

naita() {
 	echo "Funktsioonile anti:"

 	for argument in "$@"
 	do
     	echo "$argument"
	done
}

naita "üks" "kaks" "kolm"
