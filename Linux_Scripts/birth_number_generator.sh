#!/bin/bash

# ./u.sh 25 11 1999 M/Z

###############################
#                             #
#          VARIABLES          #
#                             #
###############################

# Day
dd=$1

# Month
mm=$2

rr=$3
# Get last two digits from the year.
rr=${rr: -2}

# Male or female?
male_female=$4

################################
################################
################################

if [[ $male_female == "Z" ]]
then
    mm=$(($mm+50))
fi

# Year without leading zeroes. If there aren't any, this line will not do anything.
rr_w_l=$(sed 's/^0*//' <<< $rr)

i=1
for j in {0000..9999..1}
do
    br="$rr$mm$dd$j"


    #rr_w_l_zeroes=$(sed 's/^0*//' <<< $rr)

    if [[ $(($rr_w_l$mm$dd$j % 11)) -eq 0 ]]
    then
        echo "br: $rr$mm$dd/$j"
    fi
done

for i in {0..100..11}
do
    #echo $i
    :
done
