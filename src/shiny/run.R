#' Script appelé par add_journee.R. Exécute les simulations.

## INIT ----------------------------------------------------------------

library(ggplot2)
library(scales)
library(parallel)
options(mc.cores=detectCores())

## Création du répertoire de stockage des images et données
file.base <- gsub(" ","_", paste(championnat, saison, sep="/"))
file.base <- file.path("src/shiny/app/www/data/", file.base)
dir.create(file.base, recursive=TRUE)


## FONCTIONS -----------------------------------------------------------

#' Réordonne le tableau des résultat selon le nombre moyen de
#' points obtenus
reorder.tab <- function(tab) {
    moy <- tab %.% group_by(eq) %.% summarize(moyenne=mean(points))
    moy <- moy[order(moy$moyenne, decreasing=TRUE),]
    moy$classement <- 1:20
    tab$eq <- factor(tab$eq, levels=rev(moy$eq))
    return(tab)
}

#' Violin plot du nombre de points obtenus
violin.plot <- function(tab) {
    g <- ggplot(data=tab) +
        geom_violin(aes(x=eq,y=points)) +
        scale_x_discrete("Équipe") +
        scale_y_continuous("Nombre de points") +
        coord_flip() +
        theme(text = element_text(size=10))
    filename <- paste0(journee, "_violin_", tab$dyn[1], ".png")
    ggsave(g, filename=file.path(file.base,filename), dpi=100, width=7, height=6)
    return(g)
}

#' Histogramme des probabilités des différents classements
probas.plot <- function(tab) {
    tab$eq <- factor(tab$eq, levels=rev(levels(tab$eq)))
    tab$classement <- factor(tab$classement, levels=20:1)
    g <- ggplot(data=tab) +
        geom_bar(aes(x=classement, y=(..count..)/sum(..count..)*20)) +
        facet_grid(eq~.) +
        scale_y_continuous("Pourcentage", labels=percent_format()) +
        scale_x_discrete("Position en fin de championnat") +
        theme(text=element_text(size=10), 
              strip.text.y=element_text(angle=0),
              axis.text.y=element_text(size=5)) 
    filename <- paste0(journee, "_probas_", tab$dyn[1], ".png")
    ggsave(g, filename=file.path(file.base,filename), dpi=100, width=7, height=7)
    return(g)
}

#' Données des probabilités de classement par équipe
probas.table <- function(tab) {
    nb.rows <- nrow(tab)
    filename <- paste0(journee, "_probas_", tab$dyn[1], ".Rdata")
    tab <- tab %.% group_by(eq,classement) %.% summarize(n=n())
    tab <- tab %.% group_by(eq) %.% 
        mutate(prob=paste(round(n/sum(n)*100,1),"%"))
    save(tab, file=file.path(file.base,filename))
}


## SIMULATIONS -----------------------------------------------------------

## Méthode 1 : probas sur toute la saison
cat("- Running saison\n")
probas <- table.probas(d, journee=journee)
resultats <- mclapply(1:nb.rep, simulation, d, probas, journee=journee)
taball <- rbindlist(resultats)
taball$dyn <- "saison"
taball <- reorder.tab(taball)
invisible(violin.plot(taball))
invisible(probas.plot(taball))
probas.table(taball)


## Méthode 2 : probas sur les 15 dernières journées
cat("- Running 15j\n")
probas <- table.probas(d, derniers=15, journee=journee)
resultats <- mclapply(1:nb.rep, simulation, d, probas, journee=journee)
tab15 <- rbindlist(resultats)
tab15$dyn <- "15j"
tab15 <- reorder.tab(tab15)
invisible(violin.plot(tab15))
invisible(probas.plot(tab15))
probas.table(tab15)

## Méthode 3 : probas sur les 5 dernières journées
cat("- Running 5j\n")
probas <- table.probas(d, derniers=5, journee=journee)
resultats <- mclapply(1:nb.rep, simulation, d, probas, journee=journee)
tab5 <- rbindlist(resultats)
tab5$dyn <- "5j"
tab5 <- reorder.tab(tab5)
invisible(violin.plot(tab5))
invisible(probas.plot(tab5))
probas.table(tab5)


## SAUVEGARDE -----------------------------------------------------------

## datas contient la liste des données disponibles (championnat, saison, journée
## dynamique)
load("src/shiny/app/www/data/datas.Rdata")
#datas <- data.frame(championnat=championnat, saison=saison, journee=journee, derniers="saison", stringsAsFactors=FALSE)
datas <- rbind(datas, c(championnat, saison, journee, "saison"))
datas <- rbind(datas, c(championnat, saison, journee, "15j"))
datas <- rbind(datas, c(championnat, saison, journee, "5j"))
datas <- unique(datas)
save(datas, file="src/shiny/app/www/data/datas.Rdata")
