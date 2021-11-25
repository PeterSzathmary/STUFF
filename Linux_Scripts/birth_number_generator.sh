#!/bin/bash

# Example of how to run this program.
# ./u.sh 25 11 1999 M/Z

# . ./check_functions.sh

function main()
{
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

        if [[ $(($rr_w_l$mm$dd$j % 11)) -eq 0 ]]
        then
            echo "br: $rr$mm$dd/$j"
        fi
    done
}

function check_count_of_arguments()
{
    if [[ $1 -eq $2 ]]
    then
        return 0
    else
        echo "ERROR::Arguments should be equal to $2. (passing arguments: $1)"
        return 1
    fi
}



check_count_of_arguments "$#" 4
correct_count_of_arguments=$?
if [[ $correct_count_of_arguments -eq 0 ]]
then
    main "$@"
else
    #echo "ERROR::"
    :
fi
