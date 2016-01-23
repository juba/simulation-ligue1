#' Ajoute les simulations d'une nouvelle journée aux données existantes

## Init
root.dir <- "/home/julien/stats/simulation-ligue1"
setwd(root.dir)
library(ProjectTemplate)
load.project()

## Fonction lançant le scraping et les simulations
add.journee <- function(championnat, saison, journee, nb.rep=5000) {
    championnat <- championnat
    journee <- journee
    saison <- saison
    nb.rep <- nb.rep
    ## Liste des urls par championnat
    urls <- list("Ligue 1"="http://www.maxifoot.fr/calendrier-ligue1.php",
                 "Ligue 2"="http://www.maxifoot.fr/calendrier-ligue2.php",
                 "National"="")
    
    d.url <- urls[[championnat]]
    cat("--- Scraping ---\n")
    source("src/shiny_2015-2016/scrape.R", local=TRUE)
    cat("--- Running simulations ---\n")
    source("src/shiny_2015-2016/run.R", local=TRUE)
}

## Ajout d'une nouvelle journée

add.journee("Ligue 1", "2015-2016", 21, 5000)

add.journee("Ligue 2", "2015-2016", 21, 5000)

add.journee("National", "2015-2016", 18, 5000)


# for (i in 21:26) {
#     cat(paste("\n\n---",i,"---\n"))
#     add.journee("Ligue 1", "2015-2016", i, 5000)
# }
# 
# for (i in 20:25) {
#     cat(paste("\n\n---",i,"---\n"))
#     add.journee("Ligue 2", "2015-2016", i, 5000)
# }
# 
# for (i in 19:23) {
#     cat(paste("\n\n---",i,"---\n"))
#     add.journee("National", "2015-2016", i, 5000)
# }

#championnat <- "Ligue 1"
#journee <- 25
#saison <- "2015-2016"
#nb.rep <- 2000
