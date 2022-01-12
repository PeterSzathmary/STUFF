#!/bin/bash

function main()
{
	how_many=$1
	found=0
	j=1
	counter=1
	declare -a primes=()

	while [[ $found -lt $how_many ]]
	do
		is_prime $j
		res=$?
		if [[ $res -eq 0 ]]
		then
			printf '%s\t%s\n' "$counter:" "$j"
			primes[${#primes[@]}]=$j
			found=`expr $found + 1`
			counter=`expr $counter + 1`
		fi
		j=`expr $j + 1`
	done
}

function is_prime()
{
	num=$1
	i=2

	# flag variable
	f=0

	# running a loop from 2 to number/2
	while [[ $i -le `expr $num / 2` ]] 
	do

		# checking if i is factor of number
		if test `expr $num % $i` -eq 0 
		then
			f=1
		fi

		# increment the loop variable
		i=`expr $i + 1`
	done

	if test $f -eq 1 
	then
		#echo "$num is NOT prime number"
		return 1
	else
		#echo "$num IS prime number"
		return 0
	fi
}

main $1
