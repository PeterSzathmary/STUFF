#!/bin/bash

clear

# Example of how to run this program.
# ./birth_number_generator.sh 25 11 1999 M/Z

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
    stop=1
    for j in {0000..9999..1}
    do
        if [[ $stop -eq 0 ]]
        then
            break
        fi

        br="$rr$mm$dd$j"

        if [[ $(($rr_w_l$mm$dd$j % 11)) -eq 0 ]]
        then
            echo "br: $rr$mm$dd/$j"
            if [[ $i -le 10 ]]
            then
                i=$i+1
            else
                stop=0
            fi
        fi
    done
}


function check_count_of_arguments()
{
    if [[ $1 -eq $2 ]]
    then
        return 0
    else
        echo "ERROR::Arguments should be equal to $2. (getting: $1)"
        return 1
    fi
}

function check_gender()
{
    if [[ $1 == "M" ]] || [[ $1 == "Z" ]]
    then
        return 0
    else
        echo "ERROR::Please choose as gender either M, or Z. (getting: $1)"
        return 1
    fi
}

# This function will work like this:
# Example: is_in_between number_to_check min max
# Explanation:
# if the first argument will be between the second and the third argument (both included) -> return 0
# otherwise -> return 1
function is_in_between()
{
    #echo "number of arguments given: $#"
    #echo "\$1: $1"
    #echo "\$2: $2"
    #echo "\$3: $3"
    if [[ $1 -ge $2 ]] && [[ $1 -le $3 ]]
    then
        return 0
    else
        echo "ERROR::The argument should be an integer and between the range $2 - $3. (getting: $1)"
        return 1
    fi
}

function check_arguments()
{
    check_count_of_arguments "$#" 4
    if [[ $? -eq 0 ]]
    then
        #is_in_between $(sed 's/^0*//' <<< $1) 1 31
        is_in_between $1 1 31
        d=$?

        #is_in_between $(sed 's/^0*//' <<< $2) 1 12
        is_in_between $2 1 12
        m=$?

        is_in_between $3 1901 $(date +"%Y")
        y=$?

        check_gender $4
        g=$?

        if [[ $d -eq 0 && $m -eq 0 && $y -eq 0 && $g -eq 0 ]]
        then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

check_arguments "$@"
correct=$?

if [[ $correct -eq 0 ]]
then
    main "$@"
fi
