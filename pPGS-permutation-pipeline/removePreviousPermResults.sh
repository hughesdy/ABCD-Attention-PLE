#!/bin/bash

cd /u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/

for i in {1..18}; do
	
	rm snpeff/M$i/*

	rm pgs/M$i/*

	rm stats/M$i/*
	rm stats/M$i/allStats/*

	printf $i

done
	
