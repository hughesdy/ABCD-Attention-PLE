## Read in results from permutations

## Each time you run it, you should only have to change stuff below lines 42

setwd('/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/stats')

resultsList = list()
notYets = c()
nrows = c()

count = 0

existing = c()

for (mod in paste0('M', c(1:18))) {

  allData = NULL

  for (i in c(1:200)) { ## 200 = batch num
    file = paste0(mod, '/allStats/', 'allStats_', mod, '_batch', i, '.csv')

    if (file.exists(file)) {

	  existing = append(mod, existing)

      data = read.csv(file)
      
      if (nrow(data)<50) { ## nperm
        nrows = append(file, nrows)
      }


	  if (i == 1) {
        allData = data
      } else {
        allData = rbind(allData, data)
      }

      
    } else {
      next
    }
    
  }

  if (!is.null(allData)) {

	resultsList[[mod]] = allData

	print(paste0(mod, " exists"))

  }
  
  count=count+1
  print(count)
}
## --------------------------------------------

# ----------- Edit below depending on which set you just ran ------
pgs = "NDV"
pop = "AFR"



workDir = paste0("/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/", pgs, "_Results/vsBrainspanSNPs/", pop,"/phi02_refCorrected")

setwd(workDir)

## This is in case your jobs were terminated before they were completed. for some reason, instead of making a dataframe with <10k rows for incomplete modules, it will just duplicated the last rows. We will get rid of duplicated rows and save the resulting dataframes into csvs in case the original outputs (which are being saved into csvs now) are overwritten
for (i in existing) {
  df <- resultsList[[i]]
  if (length(which(duplicated(df$IIV.P)))!=0) {
    print(paste0('Module ', i, ' has duplicates. Removing them..'))
    df <- dplyr::filter(df, !duplicated(IIV.P))
    resultsList[[i]] = df
  }
}

for (mod in existing) {
  write.csv(resultsList[[mod]], paste0(mod, '_', pgs,pop,'02Results_BrainspanSNPs.csv'), row.names=F)
}


