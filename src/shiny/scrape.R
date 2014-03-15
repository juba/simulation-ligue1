#' Scraping des données d'un championnat depuis l'url d'une page
#' "Calendrier" du site Maxifoot.fr

library(XML)

doc <- htmlParse(d.url, encoding="latin-1")
tableNodes <- getNodeSet(doc, "//table[@class='cd1']")
tables <- lapply(tableNodes, readHTMLTable)
for (i in 1:length(tables)) {
    names(tables[[i]]) <- c("eq.dom","eq.ext","score")
    tables[[i]]$journee <- i
}

d <- rbindlist(tables)

## Recodages

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