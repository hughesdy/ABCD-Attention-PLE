# ABCD-Attention-PLE

<<<<<<< HEAD
Contained in this repository are the scripts necessary to generate 
distributions of shuffled, partitioned polygenic scores to which observed 
pPGS effects can be compared. These scripts accompany Chang et al. 
(https://www.medrxiv.org/content/10.1101/2024.02.19.24303048v1) 
manuscript.

perm_test.py: the main script which shuffles SNP effects and generates 
'null' partitioned polygenic scores (pPGS) of equal size to the main pPGS 
tested in the manuscript. Of note, in the manuscript, pPGS were generated 
for 4 psychiatric disorders (cognitive performance, ADHD, SCZ, and 
Neurodev) across 3 genetic ancestry groups (European, American, and 
African). For each iteration, a certain chunk towards the beginning of 
perm_test.py must be manually edited. See script for details.

getStats_4perms.R: this script is called within perm_test.py and reads 
in 
the 'null' pPGS, tests their association with an outcome of choice (e.g., 
PQB Distress in Chang et al), and outputs results into files that can be 
processed via concatenate_stats_output.r

concatenate_stats_output.r: this is NOT called by perm_test.py, but 
instead is run by the user after completing the shuffling process to 
concatenate the results in order to plot the distribution of effects

call_permPipe.sh: user will set the number of permutations and then can 
run "bash call_permPipe.sh" to start permutation process

call_permPipe_array.sh: same as call_permPipe.sh but is compatible with 
batch processing (preferred method because this is fairly computationally 
intensive)

submit_permPipeArray.sh: this is just an example of how to submit 
call_permPipeArray.sh (shown for UCLA servers - i.e., hoffman)

removePreviousPermResults.sh: this just clears up any results from 
previous iterations. for example, if you're now running the EUR, ADHD and 
want to get rid of the AMR, SCZ results, you can run this script


=======
A special thanks to Jinhan Zhu and Sarah E. Chang for contributing to these pipelines.
>>>>>>> origin
