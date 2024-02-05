#!/bin/bash

module load R/4.0.2
module load gcc/4.9.5
module load python
module load nlopt
module load cmake

nperm=1

python /u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/scripts/perm_test.py --nperm $nperm
