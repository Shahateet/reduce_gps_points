# reduce_gps_points

this code will read a file containing GPS locations in latitude and longitude, split into different files, reduce the number of points, and remerge them again.

Structure:

reduceOBS_parallel.sh <FILE> <Nº OF CORES TO USE> <MINIMUM DISTANCE>

The main code reduceOBS_parallel.sh will launch the shellscrpts/split_file.sh to split the file into the desired number of parallelization. Subsequently, it will lauch the shellscrpts/reduceOBS.sh to reduce the number of gps points. 
