#!/bin/bash

echo "$1"
input=$1

while IFS= read -r line || [[ -n "$line" ]]
do
	#echo "$line"
	re="^[0-9]{2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3} \[(ERROR|DEBUG|INFO)\] .+$"
	if [[ $line =~ $re ]]
	then
		echo "This line is CORRECT!"
		echo $line
	else
		echo "This line is NOT correct!"
		echo $line
	fi
done < "$input"
