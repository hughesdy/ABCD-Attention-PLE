=======
A special thanks to Jinhan Zhu and Sarah E. Chang for contributing to these pipelines.

## Brainspan-pPGS-final.rmd
This markdown file contains many of the main polygenic score analyses from the project. Specifically, it contains models regressing our measures of psychotic-like experiences (i.e., PQ-BC) and attention (intra-individual variability) on whole-genome polygenic scores as well as polygenic scores partitioned by developmentally co-expressed modules of genes. It also generates Table 3, Figure 5, and Supplementary Figures 2 and 5 from the paper.

## table1_attPheno_onPQBC.rmd
This markdown file contains analyses related to attention phenotypes (which we define here as our measure of attentional variability - IIV - and our functional connectivity metrics). It generates Table 2 and Supplementary Table 3 from the paper

## needed-functions.R
There are two functions that I use throughout these files, called 'loopModThroughVars' and 'makeIntoTable'. I have included them in a separate file here (called needed-functions.R). Before running the markdown files, please load these functions in your environment. Alternatively, I have also made them accessible as a package that can be loaded into your environment with the document function from devtools. 
