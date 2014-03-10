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
    result[buts.dom > buts.ext] <- "dom"
    result[buts.dom < buts.ext] <- "ext"
    result[buts.dom == buts.ext] <- "nul"
    ## Recodage équipes
    dom <- as.character(eq.dom)
    ext <- as.character(eq.ext)
})

d <- d[,list(dom,ext,journee,result)]

cache("d")
