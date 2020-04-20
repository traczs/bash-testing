#!/bin/bash

	## Flag and Command Definitions:
	## echo: displays a line output of text
	## grep: searches for the pattern within the given files
	## cut: cuts sectioins from the lines of the given file and writes output to stdout
	## -d: delimiter flag for the cut command
	## -c: flag to specify the number of lines the match was found in and suppresses normal output
	## -f: flag for filename
	## -f2: flag to extract the 2 first fields from each line in the file, the fields being represented with the delimeter used with -d
	## -w: word regex 

N_FILES_PROCESSED=0
N_PASSES_FOUND=0
N_FAILS_FOUND=0
FILE_SCORE_TOTAL=0.0

for filename in "$@"
do
	FILE_SCORE=0.0
	if [ -f ${filename} ]
	then
		if
			## search, printing a count, and extract the second field
			N_PASSES_FOUND_TEMP=$(grep -w -c PASS ${filename} | cut -d: -f2)
			N_FAILS_FOUND_TEMP=$(grep -w -c FAIL ${filename} | cut -d: -f2)
		then
			echo "${N_PASSES_FOUND_TEMP} passes found in ${filename}"
			echo "${N_FAILS_FOUND_TEMP} fails found in ${filename}"
			if [ ${N_FAILS_FOUND_TEMP} -gt 0 ]
			then
				echo "Fails on lines : "
				echo "$(grep -w -n FAIL ${filename}| cut -d: -f1)"
			fi
			#do the math things
			FILE_SCORE="1.25*${N_PASSES_FOUND_TEMP}+(-1.50)*${N_FAILS_FOUND_TEMP}"
			printf "${filename} score: "
			echo "${FILE_SCORE}" | bc
			
			if (( $(echo $FILE_SCORE'>='0 | bc) ))
			then
				echo -e "\e[32m PASS \e[0m"
			else
				echo -e "\e[31m FAIL \e[0m"
			fi
			
		else
			## print a warning to standard error
			echo "warning: search failed" >&2
		fi
		N_FILES_PROCESSED=$((N_FILES_PROCESSED + 1))
		N_PASSES_FOUND=$((N_PASSES_FOUND + N_PASSES_FOUND_TEMP))
		N_FAILS_FOUND=$((N_FAILS_FOUND + N_FAILS_FOUND_TEMP))
		FILE_SCORE_TOTAL="${FILE_SCORE}+${FILE_SCORE_TOTAL}"

	fi
	echo "" #added to make output more legible
done

echo "${N_PASSES_FOUND} total passes found"
echo "${N_FAILS_FOUND} total fails found"
echo "In total, ${N_FILES_PROCESSED} files were processed"
printf "In total, the test score is "
echo "${FILE_SCORE_TOTAL}"|bc
if (( $(echo $FILE_SCORE'>='0 | bc) ))
then
	echo -e "\e[32m OVERALL PASS \e[0m"
else
	echo -e "\e[31m OVERALL FAIL \e[0m"
fi
