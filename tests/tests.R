#' Pas d'automatisation pour l'instant...

library(testthat)
library(ProjectTemplate)
library(data.table)
library(dplyr)
library(reshape2)
root.dir <- "/home/julien/stats//simulation-ligue1"
setwd(root.dir)

d <- data.frame(
    dom=c("A","C","A","B","D","C","B","D"),
    ext=c("B","D","C","D","A","B","A","C"),
    journee=c(1,1,2,2,3,3,4,4),
    result=c("dom","ext","nul","nul","dom","dom",NA,NA), 
    stringsAsFactors=FALSE)
d <- data.table(d)

table.probas(d)

table.probas(d, derniers=2)

table.probas(d, journee=2)

probas <- table.probas(d)

simulation.dbg(1, d, probas)

journee <- NULL
if (is.null(journee)) {
    sel <- is.na(d$result)
} else 
    sel <- d$journee > journee
current <- d
tmp <- current[sel,]
    
## Fusion des probabilités de victoire et défaite des
## différentes équipes
g.dom <- probas[tmp$dom,"prob.g.dom",with=FALSE]
p.dom <- probas[tmp$dom,"prob.p.dom",with=FALSE]
g.ext <- probas[tmp$ext,"prob.g.ext",with=FALSE]
p.ext <- probas[tmp$ext,"prob.p.ext",with=FALSE]
## Calcul des probas de victoire à domicile ou à l'extérieur
tmp$p.dom <- (g.dom + p.ext) / 2
tmp$p.ext <- (g.ext + p.dom) / 2
## Tirage au sort du résultat
alea <- runif(nrow(tmp))
tmp$result <- "nul"
tmp$result[alea<tmp$p.dom] <- "dom"
tmp$result[alea>(1-tmp$p.ext)] <- "ext"
## Fusion des résultats calculés et calcul des points
current$result[sel] <- tmp$result

calcule.points(current)
