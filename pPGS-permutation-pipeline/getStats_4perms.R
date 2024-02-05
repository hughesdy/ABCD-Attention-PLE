args = commandArgs(trailingOnly = T)
## First argument is the name of the .profile output from plinks --score
## Second argument is the name of the original PGS
## Third argument is the output name

print(args[1])
print(args[2])
print(args[3])

newdata <- read.table(args[1], header=F)
pgsname = args[2]
output = args[3]



############ Code copied from Chat-GPT:
# List of required packages
required_packages <- c("dplyr", "lme4", "lmerTest")

# Loop through the list and require each package
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}
################### --- End Chat-GPT portion

system.time({
  
fulldata <- readRDS('/u/project/cbearden/hughesdy/genetics/brainspan_permutation_pipeline/data/PLE_ATTENTION_DATA.rds') %>%
  left_join(.,newdata, by = c('subjectkey' = 'V1'))
fulldata$z.score = as.numeric(scale(fulldata$V5))

#correlation <- cor(fulldata[,pgsname], fulldata$z.score, use = 'complete.obs')

p.difference = t.test(fulldata[,pgsname], fulldata$z.score)$p.value

model.distress <- lmer(DistressScoreSum ~ z.score + PC1 + PC2 + PC3 + PC4 + PC5 + interview_age_new + demo_sex_v2 + (1|site_id_l/rel_family_id/subjectkey), fulldata)
distress.coef <- summary(model.distress)$coefficients


model.cognition <- lmer(iiv_composite_zscore ~ z.score + PC1 + PC2 + PC3 + PC4 + PC5 + interview_age_new + demo_sex_v2 + (1|site_id_l/rel_family_id/subjectkey), fulldata)
cognition.coef <- summary(model.cognition)$coefficients


#final <- as.data.frame(matrix(c(correlation, p.difference, distress.coef[2,1], distress.coef[2,5], cognition.coef[2,1], cognition.coef[2,5]), ncol = 6))
#colnames(final) = c('Corr.wOG','Ttest.P.wOG','PQB.Beta','PQB.P','IIV.Beta','IIV.P')

final <- as.data.frame(matrix(c(p.difference, distress.coef[2,1], distress.coef[2,5], cognition.coef[2,1], cognition.coef[2,5]), ncol = 5))
colnames(final) = c('Ttest.P.wOG','PQB.Beta','PQB.P','IIV.Beta','IIV.P')

write.csv(final, output, row.names=F)

})
