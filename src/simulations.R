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


## Visualisation des résultats

tab <- table15

moy <- tab %.% group_by(eq) %.% summarize(moyenne=mean(points))
moy <- moy[order(moy$moyenne, decreasing=TRUE),]
moy

tab$eq <- factor(tab$eq, levels=rev(moy$eq))
ggplot(data=tab) +
    geom_boxplot(aes(x=eq,y=points)) +
    scale_x_discrete("Équipe") +
    scale_y_continuous("Nombre de points") +
    coord_flip()


library(questionr)
library(knitr)
tapply(tab$classement, tab$eq, freq, exclude=NA)

