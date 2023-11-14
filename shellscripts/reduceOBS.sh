#!/bin/bash

# This program reduce the observations of a csv file.
# IMPORTANT: It must be a file that each element (e.g. lat, lon, thickness, etc) is separeted by comma.
# IMPORTANT: It must be latitude and longitude coordinates in the first and second columns, respectvely
# There are 2 entries. Firstly the target file and secondly the threshold. The Threshold cannot be too large, because it is assumed flat earth and also the correction to longitude is done as the first points as reference.

# Author: Kaian Shahateet
# version: 1.0
# date: 2023/Jan/31


echo " "
printf '%s\n' '#########################################'
echo "#      Starting reduce observation      #"
printf '%s\n' '#########################################'
echo " "

# if is used to check if the user properly sent the command
if (( $# == 2 ))
then

	file=$1 # takes the first input as the target file
	thr=$2 # takes the second argument as the threshold

	old_IFS="$IFS" #remembers the IFS

	lat_1=0.00000000 #first lat to save the first point
	lon_1=0.00000000 #first lon to save the first point
	circ_earth=40008182.44 # circunference of Earth
	grad_to_meter=$(echo "$circ_earth/360" | bc )

	n_removed=0 # variable to count the number of points removed
	unset exit_array # erases the variable that will be appended as the final result

	name_simple=${file//.csv/} # take the name of the target file to append the number of the new file
	name_exit=$(echo ${name_simple}_reduced_${thr}m.csv) # name of the exit file

	number_of_lines=$(cat $file | wc -l) # total number of lines of the target file

	# Section to print the total number of lines of the target file to the user
	echo "The total number of lines in the file $file is:"
	echo $number_of_lines
	echo " "

	var_file=$(cat $file) # load the file into a variable. This is for optimization
 	
	
	while IFS= read -r line # Read a line
    	do		
		IFS="," # IFS changed to take lat and lon using comma as the delimiter
		line_2=( $line ) # changes the variable to an array
		lat_2=${line_2[0]} # take the latitude of the point to be evaluated
		lon_2=${line_2[1]} # take the longitude of the point to be evaluated

		dist=$(echo "scale=4 ; lat_1_rad= $lat_1 / 360 * (2*3.1415926532) ; dist_lat=$lat_1 - $lat_2 ; dist_lon=$lon_1 - $lon_2 ; dist_y= dist_lat * grad_to_meter ; dist_x=dist_lon * grad_to_meter * c(lat_1_rad) ; dist_float=sqrt( dist_x^2 + dist_y^2) ; scale=0; dist_float/1" | bc -l) # concatenated to be faster

		# if condition to check if the distance between the points are greater then the threshold
		if (( dist >= $thr ))
		then
			#exit_array=$(printf '%s\n' "${line}")
			exit_array=$(printf '%s\n%s' "$exit_array" "$line" ) # It appends the new line to the array
			lat_1=$lat_2 # the evaluated point becomes the reference
			lon_1=$lon_2 # the evaluated point becomes the reference
		else #else that increments the counting variable
			let "n_removed++" # increments n_removed
		fi
		
    	done < <(printf '%s\n' "$var_file") # send the variable to be read

	printf '%s\n' "$exit_array" >> 1.csv # prints to a temporary file
	tail -n +2 1.csv > $name_exit # removes the first line and save the final file
	rm 1.csv # removes the temporary file

	echo "It was removed $n_removed points"	
	
	echo " "
	printf '%s\n' '##########################################'
	echo "# Thank you for using reduce observation #"
	printf '%s\n' '##########################################'
	echo " "

else
	# if the user didn't properly sent the command, this section explain it
	printf '%s\n' '#################################'
	printf '%s\n' '## Number of entries must be 2 ##'
	printf '%s\n' '#################################'
	printf '%s\n' ' '
	printf '%s\n' 'input method:'
	printf '%s\n' ' '
	printf '%s\n' 'reduce_obs <FILE> <DISTANCE_THRESHOLD>'
	printf '%s\n' ' '
	printf '%s\n' 'example:'
	printf '%s\n' ' '
	printf "%s\n" 'split_file test.csv 50'
	printf '%s\n' ' '


fi
