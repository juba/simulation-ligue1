## Test

library(foreach)
library(doParallel)
cl <- makeCluster(6)
registerDoParallel(cl)

library(ProjectTemplate)
load.project()
load("cache/d.RData")


## Méthode 1 : probas sur toutes les journées précedentes

nb.rep <- 1000
probas <- table.probas(d)
resultats <- foreach(1:nb.rep) %dopar%
    simulation(probas)    

table.all <- rbindlist(resultats)
cache("table.all")

## Méthode 2 : probas sur les 15 dernières journées

nb.rep <- 1000
probas <- table.probas(d, derniers=15)
resultats <- foreach(1:nb.rep) %dopar%
    simulation(probas)    

table15 <- rbindlist(resultats)
cache("table15")


