#!/bin/bash

# Program to split a long file such as csv or txt into different files
# Author: Kaian Shahateet
# version: 1.0
# date: 2023/Jan/30

echo " "
printf '%s\n' '#################################'
echo "#      Starting Split File      #"
printf '%s\n' '#################################'
echo " "

file=$1 # takes the first input as the target file
division=$2 # takes the second argument as the number of files to generate

size_prev=0 # variable to be used in the for loop. It is used to remember the size of the previous splitting
name_simple=${file//.csv/} # take the name of the target file to append the number of the new file

number_of_lines=$(cat $file | wc -l) # total number of lines of the target file
size_frac=$(echo "scale=4; $number_of_lines/$division" | bc) # the fractional division of the target file into different files

# if is used to check if the user properly sent the command
if (( $# == 2 ))
then

	# Section to print the total number of lines of the target file to the user
	echo "The total number of lines in the file $file is:"
	echo $number_of_lines
	echo " "

	# Section to print the fractional division to the user
	echo "The division results in:"
	echo $size_frac
	echo " "
 	
	# loop to generate the different files from the target file
	for (( n=1; n<=$division; ++n ))
	do       
		echo "Working on file $n of $division" # prints the number of the file that the program is working
		size=$(echo " ( $number_of_lines - $size_prev ) / ( $division - ( $n - 1 ) ) " | bc) # number of lines of the new n new file
		size_prev=$(echo "$size + $size_prev" | bc) # pass the number of lines of the new n file to the next iteration and it is also used to know the head
		
		new_name=${name_simple}_$n.csv # creates a new name for the file

		echo "The size of the file $new_name is $size lines" # prints the number of lines of the new file	

		head -n $size_prev $file | tail -n $size > $new_name # core of the program where it selects the sections to be taken

	done # for ends here

	echo " "
	printf '%s\n' '##################################'
	echo "# Thank you for using Split File #"
	printf '%s\n' '##################################'
	echo " "

else
	# if the user didn't properly sent the command, this section explain it
	printf '%s\n' '#################################'
	printf '%s\n' '## Number of entries must be 2 ##'
	printf '%s\n' '#################################'
	printf '%s\n' ' '
	printf '%s\n' 'input method:'
	printf '%s\n' ' '
	printf '%s\n' 'split_file <FILE> <NUMBER_OF_DIVISIONS>'
	printf '%s\n' ' '
	printf '%s\n' 'example:'
	printf '%s\n' ' '
	printf "%s\n" 'split_file teste.csv 5'
	printf '%s\n' ' '


fi
