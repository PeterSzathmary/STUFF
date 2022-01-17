#!/bin/bash

function main()
{
	check_arg_count $2
	res=$?
	if [[ $res -ne 0 ]]
	then
		echo "Argument count is not correct!"
	else
		:
		is_integer $1
		res=$?
		if [[ $res -ne 0 ]]
		then
			echo "Not a number!"
		else
			num=$(echo $1 | sed 's/^0*//')
			is_odd $num
			res=$?
			if [[ $res -eq 0 ]]
			then
				#echo "$num is odd"
				# if odd, print decrementing --> 0
				print_seq $res $num
			else
				# if even, print incrementing --> 1
				#echo "$num is even"
				print_seq $res $num
			fi
		fi
	fi	
}

function check_arg_count()
{
	if [[ $1 -ne 1 ]]
	then
		return 1
	else
		return 0
	fi
}

function is_integer()
{
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]]
	then
		return 1
	else
		return 0
	fi	
}

function is_odd()
{
	num=$1
	if [[ $((num%2)) -eq 0 ]]
	then
		return 1
	else
		return 0
	fi
}

function print_seq()
{
	# 0 - decrementing
	# 1 - incrementing
	order=$1
	num=$2

	if [[ $order -eq 0 ]]
	then
		:
		for ((i=$num; i>0; i--))
		do
			echo -n "$i "
		done
	else
		:
		for ((i=1; i<=$num; i++))
		do
			echo -n "$i "
		done
	fi
	echo
}

main $1 $#
