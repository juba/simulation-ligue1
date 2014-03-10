## Test

library(parallel)
options(mc.cores=detectCores())

library(ProjectTemplate)
load.project()
load("cache/d.RData")

nb.rep <- 1000

## Méthode 1 : probas sur toutes les journées précedentes

probas <- table.probas(d)
resultats <- mclapply(1:nb.rep, simulation, probas)

table.all <- rbindlist(resultats)
cache("table.all")


## Méthode 2 : probas sur les 15 dernières journées

probas <- table.probas(d, derniers=15)

resultats <- mclapply(1:nb.rep, simulation, probas)

table15 <- rbindlist(resultats)
cache("table15")


## Méthode 3 : probas sur les 5 dernières journées

probas <- table.probas(d, derniers=5)

resultats <- mclapply(1:nb.rep, simulation, probas)

table15 <- rbindlist(resultats)
cache("table15")


