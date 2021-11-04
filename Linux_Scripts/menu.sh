 #!/bin/bash

 . ./colors.sh

 # Read a file of all options and store it in variable 'options' as array.
 readarray -t options < options.txt

 # Return the length of the array.
 # echo -e "Length of the array: ${#options[@]}\n"

 # Return the length of the first element in the array.
 # echo "Length of the first element ${options[3]} is ${#options[3]}"
 # First element in the array.
 # echo -e "\n${options[0]}"

 # Last element.
 # echo "Last element in the array is: ${options[-1]}"

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

 # Debugging.
 #echo $user_options
 #echo "# of arguments: ${#user_options[@]}"
 #echo "0th element: ${user_options[0]}"

 # This function will check if all elements in given array are positive integers.
 function all_positive_integers_in_array()
 {
     arr=("$@")

     # Debugging.
     #echo "${arr[0]}"
     #echo "${arr[1]}"
     #echo "arr length: ${#arr[@]}"

     is_pos_int=0

     # Regex pattern for positive integers.
     re='^[0-9]+$'

     for i in "${arr[@]}"
     do
         #echo $i
         # If the element doesn't match regex pattern,
         # print error message and exit the function
         # with code 1.
         if [[ ! $i =~ $re  ]]
         then
             echo -e "${red}$i is not a positive integer!!!${no_color}"
             #return 1
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
             #echo $i
             if [[ $i -ne 14 ]]
             then
                 echo -e "${red}$i is not in range !!!${no_color}"
             fi
             in_range=1
             #return 1
         fi
     done

     # If everything was okay, exit the function with code 0.
     return $in_range
 }

 all_positive_integers_in_array "${user_options[@]}"
 res1=$?
 #echo "res1: $res1"

 is_option_in_range ${user_options[@]}
 res2=$?
 #echo "res2: $res2"

 function only_all()
 {
     arr=("$@")
     #echo "arguments: ${#arr[@]}"
     if [[ ${arr[0]} -eq 14 && ${#arr[@]} -eq 1 ]]
     then
         return 0
     else
         echo -e "${red}If you want to download all, please choose only 'all' option.${no_color}"
         return 1
     fi
 }

 only_all ${user_options[@]}
 res3=$?
 #echo "res3: $res3"

 # 1. All user's options have to be less than all available options.
 # 2. All user's options have to be positive integers.
 # 3. All user's options have to be in range.
 #echo "DEBUGGING"
 #echo ${#user_options[@]}
 #echo ${user_options[0]}
 #echo "END DEBUGGING"
 if [[ ${#user_options[@]} -lt $((${#options[@]}+1)) && $res1 -eq 0 && $res2 -eq 0 ]] || [[ $res3 -eq 0 ]]
 then
     echo -e "${green}OK${no_color}"
     # Install selected "packages."
     # Loop through the options the user has choosed and print them.
     for i in "${arr[@]}"
     do
         if [[ $i -ne 14  ]]
         then
             echo -e "Option selected: $i ${green}${options[$((i-1))]}${no_color}"
         else
             echo -e "Option selected: $i ${green}all${no_color}"
         fi
     done

 else
     echo -e "${red}NOK${no_color}"
     # Abort the process.
 fi

 #echo -e "${red}test${no_color}"
