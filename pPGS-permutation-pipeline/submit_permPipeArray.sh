#### submit_arrayjob.sh START ####
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o joblog.$JOB_ID.$TASK_ID
#$ -j y
## Edit the line below as needed:
#$ -l h_rt=23:00:00,h_data=20G
## Modify the parallel environment
## and the number of cores as needed:
#$ -pe shared 1
# Email address to notify
#$ -M dylanhughes@mednet.ucla.edu
# Notify when
#$ -m bea
#$ -t 1-200:1

# echo job info on joblog:
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh

echo '/usr/bin/time -v /u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/scripts/call_permPipe_array.sh'
/usr/bin/time -v /u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/scripts/call_permPipe_array.sh

# echo job info on joblog:
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
#### submit_arrayjob.sh STOP ####


