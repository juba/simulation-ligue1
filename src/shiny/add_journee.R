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
    source("src/shiny/scrape.R", local=TRUE)
    cat("--- Running simulations ---\n")
    source("src/shiny/run.R", local=TRUE)
}

## Ajout d'une nouvelle journée


add.journee("Ligue 1", "2013-2014", 35, 5000)

add.journee("Ligue 2", "2013-2014", 34, 5000)

add.journee("National", "2013-2014", 29, 5000)
