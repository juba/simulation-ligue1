#' Scraping des données d'un championnat depuis l'url d'une page
#' "Calendrier" du site Maxifoot.fr

library(XML)

if (championnat != "National") {
    doc <- htmlParse(d.url, encoding="latin-1")
    tableNodes <- getNodeSet(doc, "//table[@class='cd1']")
    tables <- lapply(tableNodes, readHTMLTable)
    for (i in 1:length(tables)) {
        names(tables[[i]]) <- c("eq.dom","eq.ext","score")
        tables[[i]]$journee <- i
    }
}

## Scraping du calendrier de National par @jpdarky
if (championnat == "National") {
    tables<-list()
    for (day in 1:34) {
        cat("Scraping", day, "\n")
        url<-sprintf("http://www.sports.fr/football/national/2014/resultats/%de-journee.html",day)
        doc <- htmlParse(url)
        tableNodes<-getNodeSet(doc, "//*[@id='main-content']/div")
        temptable <- lapply(tableNodes, readHTMLTable)[[1]]
        temptable=temptable[-1,]
        temptable$V5=gsub("Parier\\?","-",temptable$V5)
        drops<-c("V1","V2","V3","V7")
        temptable<-temptable[,!(names(temptable) %in% drops)]
        names(temptable) <- c("eq.dom","score","eq.ext")
        temptable$journee <- day
        tables[[day]]<-temptable
    }
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