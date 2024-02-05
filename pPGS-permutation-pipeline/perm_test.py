import subprocess
import pandas as pd
import random
import time
import argparse
import sys

## Updated 01/26/2024 to re-do permutations with corrected SNP effects (i.e., using phi = 0.02 when necessary) and using the correct reference population (i.e., ref matches discovery set)

## It's clunky, but everytime you run this you should edit this file directly to specify new summary statistics to load (just have to uncomment certain lines)

parser = argparse.ArgumentParser(description = 'Brainspan Module Null Distributions via Permutations')

parser.add_argument('--nperm', type=int, help='Integer defining the number of permutations')
parser.add_argument('--batchNum', type=int, default=-1, help='Integer value to pass to a hoffman submission script, which will take on the value of $SGE_TASK_ID. Otherwise, the default is -1, which indicates that the script is not a batch submission jobs and will allow you to run locally')

args = parser.parse_args()

print(args.batchNum)

start_time = time.time()


n_perm=args.nperm

if n_perm is None:

	sys.exit('Please provide number of permutations with the --nperm flag')


batchNum = args.batchNum

### Load summary statistics/snp posterior effects (prscs) -------------

# CP

## EUR; completed 10/23/2023; not updated 01/26/2024 because this uses prscs-auto
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/CP/CPEUR_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/CP/brainspan/CPEUR_Brainspan_SNPcounts.csv'

#disorder_name = 'CPEUR'

#modulesToTest = (1,4,7,11,13,15,16,17,18)
# --

## AMR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/CP/CPAMR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/CP/brainspan/CPAMR02_Brainspan_SNPcounts.csv'

#disorder_name = 'CPAMR'

#modulesToTest = (4,7,15)
# --

## AFR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/CP/CPAFR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/CP/brainspan/CPAFR02_Brainspan_SNPcounts.csv'

#disorder_name = 'CPAFR'

#modulesToTest = (8,10)
# -----------------------------------------

# ADHD

## EUR; complete 10/22/23; not updated 01/26/2024 because this uses prscs-auto
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/ADHD/ADHDEUR_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/ADHD/brainspan/ADHDEUR_Brainspan_SNPcounts.csv'

#disorder_name = 'ADHDEUR'
# --

## AMR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/ADHD/ADHDAMR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/ADHD/brainspan/ADHDAMR02_Brainspan_SNPcounts.csv'

#disorder_name = 'ADHDAMR'

#modulesToTest = (14,16)
# --

## AFR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/ADHD/ADHDAFR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/ADHD/brainspan/ADHDAFR02_Brainspan_SNPcounts.csv'

#disorder_name = 'ADHDAFR'

#modulesToTest = (2,6,7)
# ----------------------------------------------

# SCZ

## EUR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/SCZ/SCZEUR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/SCZ/brainspan/SCZEUR02_Brainspan_SNPcounts.csv'	

#disorder_name = 'SCZEUR'

#modulesToTest = (9,10,11,15)
# --

## AMR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/SCZ/SCZAMR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/SCZ/brainspan/SCZAMR02_Brainspan_SNPcounts.csv'	

#disorder_name = 'SCZAMR'

#modulesToTest = (2,11)
# --

## AFR - NO SIGNIFICANT MODULES OBSERVED SO OMIT THIS; updated/confirmed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/SCZ/SCZAFR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/SCZ/brainspan/SCZAFR02_Brainspan_SNPcounts.csv'	

#disorder_name = 'SCZAFR'

#modulesToTest = NA

# --------------------------------------------------

# NDV

## EUR; completed 01/27/24
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/NDV/NDVEUR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/EUR/NDV/brainspan/NDVEUR02_Brainspan_SNPcounts.csv'

#disorder_name = 'NDVEUR' 

#modulesToTest = (1,5,7,11,12,14,15,16,17,18)
# --

## AMR; completed 10/24/2023; check 01/27/24 - apparently no significant modules. but need to double check
#summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/NDV/NDVAMR02_allBrainspan_snpeff.txt'

#snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AMR/NDV/brainspan/NDVAMR02_Brainspan_SNPcounts.csv'

#disorder_name = 'NDVAMR' 

#modulesToTest = (7,13)
# --

## AFR; completed 10/24/2023
summary_statistics = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/NDV/NDVAFR02_allBrainspan_snpeff.txt'

snpcount = '/u/project/cbearden/hughesdy/abcd/genetics/PGS/ancestryViaGenesis/AFR/NDV/brainspan/NDVAFR02_Brainspan_SNPcounts.csv'

disorder_name = 'NDVAFR' 

modulesToTest = (6,7)
# -----------------------------------------------------------------

sum_stats = pd.read_csv(summary_statistics, sep ='\t', header = None)
sum_stats = pd.DataFrame(sum_stats)

#numrow = sum_stats.shape[0] # number of rows in total snp effects file

snpcount = pd.read_csv(snpcount) # number of SNPs per module


## Input modules to test. If you want to test all of them, use the range(1,19) line. Otherwise, specify manually the modules to test in modulesToTest variable

#modulesToTest = range(1,19)
#modulesToTest = (1,4,7,11,13,15,16,17,18)


for mod in modulesToTest:
	
	module = "M" + str(mod)
	
	module_row = snpcount[snpcount["V3"] == module].index.tolist()
	
	num_snp = int(snpcount.iloc[module_row, 1])
	
	og_pgs = 'z.' + disorder_name + '_' + module
	for i in range(1,(n_perm+1)):

		newfile = sum_stats.sample(n=num_snp)
		newfile = newfile.sort_values(0)


		if batchNum == -1: 
			sampleName = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/snpeff/snpeff.txt'

			scoreName = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/pgs/abcd_brainspan_perm'

			statstemp = '/u/project/cbearden/hughesdy/genetics/stats/' + module + '/stats_out.csv'

			final_name = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/stats/' + module + '/allStats/allStats_' + module + '.csv'

##### ***** Change this part if doing round 2 for incompletes (add round2_forIncompletes after brainspain_permutation_pipeline/ e.g., /u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/round2_forIncompletes/snpeff/)

		else:
			sampleName = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/snpeff/' + module + '/' + module + '_snpeff_batch' + str(batchNum) + '.txt'  

			scoreName = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/pgs/' + module + '/' + module + '_pgs_batch' + str(batchNum)

			statstemp = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/stats/' + module + '/stats_out_' + str(batchNum) + '.csv'

			final_name = '/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/stats/' + module + '/allStats/allStats_' + module + '_batch' + str(batchNum) + '.csv'


		newfile.to_csv(sampleName, sep = '\t', index = False, header = False)

## plink score call
		subprocess.call(['/u/project/cbearden/hughesdy/software/plink2', '--pfile', '/u/project/cbearden/hughesdy/abcd/genetics/imputed_byABCD/postImpQC_04/sibsGENESIS/AMR/pfile/AMRonly_wSibs_qcd', '--score', sampleName, '2', '4', '6', 'no-mean-imputation','--out', scoreName])

## Rscript call
		scoreNameSS = scoreName + '.sscore'
		
		subprocess.call(['Rscript','/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/scripts/getStats_4perms.R',scoreNameSS, og_pgs, statstemp])
		
## Read output from rscript and concatenate with previous iterations
		stats = pd.read_csv(statstemp)
		stats = pd.DataFrame(stats)
		
		if i == 1:
			final_stats = stats
		else:
			final_stats = pd.concat([final_stats, stats], ignore_index=True)
		
		## End permutation for Loop ----------------

	final_stats.to_csv(final_name, index = False, header = True)

	## End module for loop ----------------------------------------

end_time = time.time()

final_time = end_time - start_time

print(final_time)
