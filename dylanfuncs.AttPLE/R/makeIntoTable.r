#' Make table output from loopModThroughVars() function into a pretty table
#'
#' This function takes output from dylanfuncs::loopModThroughVars() and makes it into a pretty table. not much else. You can also manually provide a table of betas, p-vals, and corrected p-vals with the same dimensions.
#' @param obj An object returned from loopModThroughVars() containing beta values, raw p-vals, and corrected p-vals. Defaults to NULL so you have the choice of providing your own values (i.e., not generated via the loopMod.. func)
#' @param betas Matrix of betas. Defaults to NULL. If you're using this function to process output from loopModThroughVars(), you can ignore this argument as well as peas and fdr arguments.
#' @param peas Matrix of raw p-values. Defaults to NULL. See note above (under betas argument description).
#' @param fdr Matrix of corrected p-values. Defaults to NULL. See note above (under betas argument description).
#' @keywords loopMod loopThroughMod makeIntoTable makePretty
#' @export
#' @examples
#' master <- read.csv('path/to/master/file')
#' all.dvs <- c('flanker','processingSpeed','dimChangeCard', 'DistressScoreSum')
#' cpbrain.pgs <- colnames(select(master, contains('z.CP_M')))
#' row.names=substr(cpbrain.pgs, start = 6, stop = nchar(cpbrain.pgs)) # picks the 6th through last character of each element of cpbrain.pgs
#' col.names = substr(all.dvs, start = 1, stop = 15) # picks 1st through 15th character of each element of all.dvs
#' covariates = c('z.pc1','z.pc2','z.pc3','z.pc4','z.pc5','interview_age_new','demo_sex_v2','(1|site_id_l/rel_family_id/subjectkey)')
#' cpbrainspan <- loopModThroughVars(dvs = all.dvs, ivs = cpbrain.pgs, rownames=row.names, colnames = col.names, covariates = covariates, data = master)
#' makeIntoTable(obj = cpbrainspan)


makeIntoTable <- function(obj=NULL, betas=NULL, peas = NULL, fdr = NULL) {
  if (is.null(betas)) {
    betas = obj$betas
    peas= obj$peas
    fdr.df = obj$fdr
  }

  flag.num = ncol(betas) - 1
  table <- as.data.frame(matrix(ncol = ncol(betas), nrow = nrow(betas)))
  dimnames(table) = dimnames(betas)

  for (i in c(1:ncol(table))) {
    for (a in c(1:nrow(table))) {

      eff = betas[a,i]
      p = peas[a,i]
      fdr = fdr.df[a,i]

      if (abs(eff) > 0.0005) {
        eff=round(eff,3)
      } else {
        eff = sprintf("%.2e", eff)
      }

      if (fdr < 0.05) {
        eff = paste0(eff, '**')
      } else if (p < 0.05) {
        eff = paste0(eff, '*')
      } else {
        eff = paste0(eff)
      }

      table[a,i] = eff
    }
  }

  bold.rows = c()
  for (i in c(1:nrow(table))) {
    if (length(which(grepl('\\*',table[i,]))) >= flag.num & grepl('\\*', table[i,ncol(betas)])) {
      bold.rows = append(i, bold.rows)
    } else {
      next
    }
  }

  if (is.null(bold.rows)) {
    gtobj <- gt(table, rownames_to_stub = T) %>%
      tab_style(style = list(cell_text(weight = 'bold')), locations = cells_column_labels()) %>%
      tab_style(style = list(cell_text(weight = 'bold')), locations = cells_stub())
  } else {
    gtobj <- gt(table, rownames_to_stub = T) %>%
      tab_style(style = list(cell_text(weight = 'bold')), locations = cells_column_labels()) %>%
      tab_style(style = list(cell_text(weight = 'bold')), locations = cells_stub()) %>%
      tab_style(style = list(cell_text(weight = 'bold')), locations = cells_body(rows = bold.rows))
  }


  return.list = list('raw.table' = table, 'pretty.table' = gtobj)
}
