#!/bin/bash

# If you make any changes to this script in Windows, you must
# run dos2unix on it before running. 

# Place this script in the same directory as your source
# files. In this directory there should be a `sample_input`
# directory and an `expected_output` directory, both of
# which can be found on Canvas.
# Create an empty directory called `my_output`. This can be
# done by running the command `mkdir my_output`.
# Run this script my typing `bash compare_output.sh`

# If you would like the script to compile your program, 
# uncomment the following 3 lines and change the file names
# to the correct format specified in Canvas.
# Otherwise, make sure your executable is named `a.out`
# or update the first line in the for loop.
flex ekstromn.l
bison ekstromn.y
g++ ekstromn.tab.c -o mfpl_parser

test_files=`ls ./sample_input`
diff_files=0
echo > comparison.txt

for file in $test_files; do
	mfpl_parser.exe < ./sample_input/$file > ./my_output/$file.out
	
    diff_lines=`diff ./my_output/$file.out \
					./expected_output/$file.out \
					--ignore-space-change --ignore-case  | egrep -c "^<|^>"`
					
	if [ $diff_lines == 0 ]
	then
		echo $file matches. >> comparison.txt
	else
		diff_files=$((diff_files+1))
		echo $file does not match. There are $diff_lines differences. >> comparison.txt
	fi
done

echo >> comparison.txt
echo "Number of different input files: $diff_files" >> comparison.txt
echo >> comparison.txt
