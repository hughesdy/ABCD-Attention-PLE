=======
A special thanks to Jinhan Zhu and Sarah E. Chang for contributing to these pipelines.

## pPGS-permutation/
Home to the scripts used to shuffle SNP effects and generate permuted, null distributions against which observed effects (of a polygenic score partitioned by a theoretically meaningful set of SNPs) can be compared. See folder for more information about the specific scripts. Here's a brief attempt at describing the importance of permutations: 
> 1. Say we test a schizophrenia polygenic score and find that there is a significant relationship between this score (a whole-genome score) and an outcome of interest
> 2. Now lets say we are interested in partitioning that whole-genome schizophrenia score by a set of 100 genes
> 3. Each gene consists of 10 SNPs and let's pretend we have information (effect sizes) about each SNPs effect on schizophrenia diagnosis from a GWAS
> 4. Therefore, our polygenic score would represent the sum of SNP effects across 10,000 SNPs (100 genes x 10 SNPs/gene)
> 5. If we find that our partitioned score significantly associates with our outcome of interest, how do we know if we are finding this association because we are just sampling a large number of SNPs from a whole-genome score which associates significantly with our outcome?
> 6. Our question is "Does this set of 100 genes play a unique role in the whole-genome signal we're seeing?" and NOT "Does a random selection of 10,000 SNPs from the whole-genome signal we're seeing also associate with our outcome?"
> 7. Excitingly, this is a super testable distinction to make. How do we do it?
> 8. Permutations! woo!

## Brainspan-pPGS-final.rmd
This markdown file contains many of the main polygenic score analyses from the project. Specifically, it contains models regressing our measures of psychotic-like experiences (i.e., PQ-BC) and attention (intra-individual variability) on whole-genome polygenic scores as well as polygenic scores partitioned by developmentally co-expressed modules of genes. It also generates Table 3, Figure 5, and Supplementary Figures 2 and 5 from the paper.

## table1_attPheno_onPQBC.rmd
This markdown file contains analyses related to attention phenotypes (which we define here as our measure of attentional variability - IIV - and our functional connectivity metrics). It generates Table 2 and Supplementary Table 3 from the paper

## needed-functions.R
There are two functions that I use throughout these files, called 'loopModThroughVars' and 'makeIntoTable'. I have included them in a separate file here (called needed-functions.R). Before running the markdown files, please load these functions in your environment. Alternatively, I have also made them accessible as a package that can be loaded into your environment with the document function from devtools. 

## dylanfuncs.AttPLE/
This is just the needed-functions stored into a package. You can download this folder and then from R, run devtools::document("/path/to/dylanfuncs.AttPLE") and the functions will load into your environment. The advantage of this method is being able to add that one line of code (i.e., using devtools) to your script and avoid having to open needed-functions.R everytime and running it to load the functions. Also, you can access the documentation for the individual functions after loading this package by running: ?loopModThroughVars or ?makeIntoTable

