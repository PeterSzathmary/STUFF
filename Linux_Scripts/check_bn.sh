#!/bin/bash

if [[ $# -eq 1 ]]
then
	re="^[0-9]{6}\/[0-9]{4}$"
	if [[ $1 =~ $re ]]
	then
		#echo "(: $1 is a correct birth number :)"
		#echo $1
		#echo "${$1//\/}"
		n=$(echo "$1" | sed 's/\///g')
		#echo $n
		if [[ $(($n % 11)) -eq 0 ]]
		then
			echo "(: $1 is a correct birth number :)"
		else
			echo "): \"$1\" is not divisible by 11 :("
		fi
	else
		echo "): \"$1\" is not a correct birth number :("
	fi
else
	echo "Number of arguments is not correct! Should be 1. ($#)"
fi
