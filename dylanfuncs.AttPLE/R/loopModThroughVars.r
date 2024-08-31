#' Function to loop through DVs and IVs and return results from lme4::lmer() models
#'
#' This function iterates through mixed effects models with a specified set of dependent and independent variables as well as covariates.
#' @param dvs A vector of characters corresponding to variables in your dataframe that represent dependent variables
#' @param ivs A vector of characters corresponding to your main predictors/independent variables
#' @param rownames Vector of characters specifying row names of the resultant table. These will correspond to your main predictors/IVs
#' @param colnames Vector of characters specifying column names of the resultant table. These correspond to your outcomes/DVs
#' @param covariates List of covariates (as characters) to include in the model. Note in the example below the syntax used for random effects (i.e., it's the same as the syntax you'd use for your lme4 models)
#' @param data Dataframe in which your variables live
#' @param na.omit If true, will first remove instances of NAs using the na.omit function. Defaults to FALSE.
#' @param timeInteraction If true, will interact main variable of interest with time and report interaction effects. Defaults to FALSE
#' @param silent If true, output will be silent. Otherwise you'll get a countdown for how many models are left (per IV/DV combo). Defaults to FALSE. Useful to turn on if you're using this in an rmarkdown.
#' @param cis If true, 95% confidence intervals around the estimates will be provided. Will only provide a CI around the estimate of the main independent variable. Defaults to FALSE. Increases run time marginally but noticeably.
#' @param tabMod If true, models will be printed as sjPlot::tab_models. Currently, any parameter edits you want to make have to be done from within the function.
#' @keywords loopMod loopThroughMod
#' @export
#' @examples
#' master <- read.csv('path/to/master/file')
#' all.dvs <- c('flanker','processingSpeed','dimChangeCard', 'DistressScoreSum')
#' cpbrain.pgs <- colnames(select(master, contains('z.CP_M')))
#' row.names=substr(cpbrain.pgs, start = 6, stop = nchar(cpbrain.pgs)) # picks the 6th through last character of each element of cpbrain.pgs
#' col.names = substr(all.dvs, start = 1, stop = 15) # picks 1st through 15th character of each element of all.dvs
#' covariates = c('z.pc1','z.pc2','z.pc3','z.pc4','z.pc5','interview_age_new','demo_sex_v2','(1|site_id_l/rel_family_id/subjectkey)')
#' cpbrainspan <- loopModThroughVars(dvs = all.dvs, ivs = cpbrain.pgs, rownames=row.names, colnames = col.names, covariates = covariates, data = master)


loopModThroughVars <- function(dvs, ivs, rownames, colnames, covariates, data, tstat = F, na.omit = F, timeInteraction = F, silent = F, cis = F, tabMod = F) {

  library(car)
  library(sjPlot)

  betas <- as.data.frame(matrix(nrow = length(ivs), ncol = length(dvs)))
  rownames(betas) = rownames
  colnames(betas) = colnames

  peas <- betas
  dimnames(peas) = dimnames(betas)

  teas <- betas
  dimnames(teas) = dimnames(betas)

  seas <- betas
  dimnames(seas) = dimnames(betas)

  ci.matrix <- betas
  dimnames(ci.matrix) = dimnames(betas)

  betas.interaction <- as.data.frame(matrix(nrow = length(ivs), ncol = length(dvs)))
  rownames(betas.interaction) = paste0(rownames, ":time")
  colnames(betas.interaction) = colnames

  peas.interaction <- as.data.frame(matrix(nrow = length(ivs), ncol = length(dvs)))
  dimnames(peas.interaction) = dimnames(betas.interaction)

  covar.model = paste(covariates, collapse = ' + ')

  dataALL = data

  tabModels = list()

  counter = 0
  for (iv in ivs) {
    rownum = which(ivs==iv)

    if (timeInteraction == T) {
      iv = paste0(iv, "*time.point")
    }

    for (dv in dvs) {
      data = dataALL

      colnum = which(dvs==dv)


      if ((dv == "iiv_composite_zscore" | dv == "nihtbx_flanker_uncorrected") & grepl("time", covar.model)) {
        data = data[!is.na(data[,dv]), ] %>%
          group_by(subjectkey) %>%
          mutate(size = length(subjectkey)) %>%
          ungroup() %>%
          filter(size > 1)
      }


      ### Adjust this model accordingly
      model.char = paste0("lmer(", dv," ~ ", iv, ' + ', covar.model,',data)')
      model <- eval(parse(text = model.char))


      ## Print Tab Model ---------------------
      ## --- Edit parameters as needed below
      if (tabMod == T) {

        tabmod <- tab_model(model)

        tabModels = append(tabModels, tabmod)

        print(tabmod)

      }
      # -------------------------------------_


      summ = summary(model)$coefficients

      betas[rownum, colnum] = summ[2,1]
      peas[rownum, colnum] = summ[2,5]
      teas[rownum, colnum] = summ[2,4]
      seas[rownum, colnum] = summ[2,2]

      if (cis == T) {
        ci = confint(model, parm = iv)
        ciToPaste = paste(round(ci[1], 3), round(ci[2],3), sep = " - ")
        ci.matrix[rownum, colnum] = ciToPaste
      }

      if (timeInteraction == T) {
        lookFor <- which(grepl(sub("*", ":", iv, fixed = T), rownames(summ)))
        betas.interaction[rownum, colnum] = summ[lookFor, 1]
        peas.interaction[rownum, colnum] = summ[lookFor, 5]
      }

      counter=counter+1

      if (silent == F) {
        print((length(ivs) * length(dvs)) - counter)
      }

    }
  }

  ## Create fdr adjusted p
  fdr=c()
  fdr <- sapply(peas, function(x) append(fdr, x))
  fdr <- p.adjust(fdr, method = 'fdr')

  fdr.df = as.data.frame(matrix(fdr, ncol = ncol(peas)))
  dimnames(fdr.df) = dimnames(peas)

  if (timeInteraction == T) {
    return.list = list('betas' = betas, 'peas' = peas, 'fdr' = fdr.df, "betas.int" = betas.interaction, "peas.int" = peas.interaction, "tabModels" = tabModels)
  } else if (tstat == T) {
    return.list = list('betas' = betas, 'peas' = peas, 'fdr' = fdr.df, 'teas' = teas, 'seas' = seas, "tabModels" = tabModels)

    if (cis == T) {
      return.list = list("betas" = betas, "peas"= peas, "fdr" = fdr.df, "teas" = teas, "cis" = ci.matrix, "tabModels" = tabModels)
    }

  } else if (cis == T) {
    return.list = list("betas" = betas, "peas"= peas, "fdr" = fdr.df, "cis" = ci.matrix, "tabModels" = tabModels)
  } else {
    return.list = list('betas' = betas, 'peas' = peas, 'fdr' = fdr.df, 'seas' = seas, "tabModels" = tabModels)
  }

  return(return.list)
}
