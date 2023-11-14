#!/bin/bash

# Program to reduce the thickness observations to the threshold.
# IMPORTANT: The first column must be Latitude and the scond Longitude. The other columns don't matter. LAT and LON in degrees.
# IMPORTANT: The input data must be without head.
# It can be disposed separeted csv's into the input data folder, but they must have the same structure.

# Author: Kaian Shahateet
# version: 1.0
# date: 2023/Feb/02

# if is used to check if the user properly sent the command
if (( $# == 3 ))

then
in_folder=$1 # loads the first argument as the input folder
cores=$2 # loads the second argument as the number of cores to be used
thr=$3 # distance threshold

data_tmp="data_tmp" # temporary directory to be used
data_out="data_out" # final directory to be used

# Checks the existence of data_tmp and remove if it does
if [ -d "$data_tmp" ]; then
	echo "$data_tmp exists. It will be erased"
	rm -r "$data_tmp"
fi
# Checks the existence of data_out and remove if it does
if [ -d "$data_out" ]; then
	echo "$data_out exists. It will be erased"
	rm -r "$data_out"
fi

mkdir "$data_tmp" # creates the data_tmp
mkdir "$data_out" # creates the data_out

# Checks the existence of data_in and abort if it doesn't
if test -d "$in_folder"; then
	echo "$in_folder exists."
else
	echo "$in_folder" "does not exist."
	exit
fi

cd data_in
cat *.csv > ../$data_tmp/all_together.csv # merges all the input files into one to be splitted
cd ../shellscripts

./split_file.sh ../$data_tmp/all_together.csv $cores # splits the merged file into different files (the number of cores)

rm ../$data_tmp/all_together.csv # removes the merged file

count=1 # counter to launch the parallelized files
for csvs in ../$data_tmp/*.csv # iterates the parallelized csv's
do
	terminal="${count}_result_terminal.txt" # creates the name of the file to save the output of the command
	./reduceOBS.sh ../$data_tmp/$csvs $thr > ../$data_tmp/$terminal & # call the reduceOBS command in background, saving the verbose
	let "count++" # increment the count variable
done

ps
echo "Reducing the observations of the partitioned files"
echo "...Working..."

wait # wait the jobs to finish

cat ../$data_tmp/*reduced* > ../$data_out/all_together_reduced_${thr}m.csv # it merges all the resulting files into one

echo "Finished! Thank you."

else
	# if the user didn't properly sent the command, this section explain it
	printf '%s\n' '#################################'
	printf '%s\n' '## Number of entries must be 3 ##'
	printf '%s\n' '#################################'
	printf '%s\n' ' '
	printf '%s\n' 'input method:'
	printf '%s\n' ' '
	printf '%s\n' './reduceOBS_parallel.sh <FOLDER> <NUMBER_OF_CORES> <DISTANCE_THRESHOLD>'
	printf '%s\n' ' '
	printf '%s\n' 'example:'
	printf '%s\n' ' '
	printf "%s\n" './reduceOBS_parallel.sh data_in 6 50'
	printf '%s\n' ' '


fi

