## Two important functions for the attention PLE scripts (i.e., for Chang et al. 2024)

# First, loopModThroughVars:
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

# -------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# -------------------------------------------------------

## Next, makeIntoTable:
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