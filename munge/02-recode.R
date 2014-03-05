## Recodage des données récupérées

library(ProjectTemplate)
load.project()
load("cache/d.RData")

d <- within(d, {
    ## Matchs à venir
    score[score=="-"] <- NA
    score[!grepl("-", score)] <- NA
    ## Extraction score
    buts.dom <- gsub("-[0-9]+$","",score)
    buts.ext <- gsub("^[0-9]+-","",score)
    ## Recodage résultat
    result <- NA
    result[buts.dom > buts.ext] <- "eq.dom"
    result[buts.dom < buts.ext] <- "eq.ext"
    result[buts.dom == buts.ext] <- "nul"
})

cache("d")
