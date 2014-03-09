## Récupère les informations des résultats des matchs passés
## et du calendrier des matchs à venir depuis le site maxiffot.fr

library(ProjectTemplate)
load.project()
library(XML)

url <- "http://www.maxifoot.fr/calendrier-ligue1.php"
doc <- htmlParse(url)
tableNodes <- getNodeSet(doc, "//table[@class='cd1']")
tables <- lapply(tableNodes, readHTMLTable)
for (i in 1:length(tables)) {
    names(tables[[i]]) <- c("eq.dom","eq.ext","score")
    tables[[i]]$journee <- i
}

d <- rbindlist(tables)

cache("d")

