#!/bin/bash


nimi="Ants"

echo "$nimi"
test() {
 	local nimi="Mari"
 	echo "$nimi"
}

test
echo "$nimi !"

