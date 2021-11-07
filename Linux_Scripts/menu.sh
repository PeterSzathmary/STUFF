 #!/bin/bash

 . ./colors.sh

 # Read a file of all options and store it in variable 'options' as array.
 readarray -t options < options.txt

 # Loop through the 'options' array and display all possible options.
 function show_options()
 {
     i=0
     for option in "${options[@]}"
     do
         i=$((i+1))
         if [[ $i -lt 10 ]]
         then
             i=" $i"
         fi
         echo "$i) $option"
         if [[ $i -eq ${#options[@]} ]]
         then
             echo "$((i+1))) all"
         fi
     done
 }

 # Display options.
 show_options

 # Now let's ask the user what options he chooses.
 echo -n "Choose any option separated by space (1-${#options[@]}) or only $((${#options[@]}+1)) : "
 # Store user's options to a new array variable 'user_options'.
 read -a user_options

 # This function will check if all elements in given array are positive integers.
 function all_positive_integers_in_array()
 {
     arr=("$@")

     is_pos_int=0

     # Regex pattern for positive integers.
     re='^[0-9]+$'

     for i in "${arr[@]}"
     do
         # If the element doesn't match regex pattern,
         # print error message and exit the function
         # with code 1.
         if [[ ! $i =~ $re  ]]
         then
             echo -e "${red}$i is not a positive integer!!!${no_color}"
             is_pos_int=1
         fi
     done

     # After all numbers have been checked successfully, exit with code 0.
     return $is_pos_int
 }


 # User's option has to be in range of options.
 function is_option_in_range()
 {
     arr=("$@")
     in_range=0

     # Loop through the array and check if every element is in range.
     for i in "${arr[@]}"
     do
         # If the element is NOT in range, exit the function with code 1.
         if [[ $i -gt ${#options[@]} ]] || [[ $i -le 0 ]]
         then
             if [[ $i -ne 14 ]]
             then
                 echo -e "${red}$i is not in range !!!${no_color}"
             fi
             in_range=1
         fi
     done

     # If everything was okay, exit the function with code 0.
     return $in_range
 }

 function only_all()
 {
     arr=("$@")
     if [[ ${arr[0]} -eq 14 && ${#arr[@]} -eq 1 ]]
     then
         return 0
     else
         echo -e "${red}If you want to download all, please choose only 'all' option.${no_color}"
         return 1
     fi
 }
