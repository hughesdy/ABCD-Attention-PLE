#!/bin/bash

subprocessid="-1"

while getopts j:p: flag
do
    case "${flag}" in
        j) joblogid=${OPTARG};;
        p) subprocessid=${OPTARG};;
    esac
done

if [[ "$subprocessid" -eq -1 ]]; then

	for i in {1..400}; do

		awk '{ count += gsub("cog-genomics.org", "") }
	END {
	print "The string appears " count " time in the file"
	}' joblogs/joblog.$joblogid.$i

	done

else

	awk '{ count += gsub("cog-genomics.org", "") }
	END {
	print "The string appears " count " time in the file"
	}' joblogs/joblog.$joblogid.$subprocessid

fi
	
