#' Script appelé par add_journee.R. Exécute les simulations.

## INIT ----------------------------------------------------------------

library(ggplot2)
library(scales)
library(parallel)
options(mc.cores=detectCores())

## Création du répertoire de stockage des images et données
file.base <- gsub(" ","_", paste(championnat, saison, sep="/"))
file.base <- file.path("src/shiny_2015-2016/app/www/data/", file.base)
dir.create(file.base, recursive=TRUE)


## FONCTIONS -----------------------------------------------------------

#' Réordonne le tableau des résultat selon le nombre moyen de
#' points obtenus
reorder.tab <- function(tab) {
    moy <- tab %>% group_by(eq) %>% summarize(moyenne=mean(points))
    moy <- moy[order(moy$moyenne, decreasing=TRUE),]
    moy$classement <- 1:nrow(moy)
    tab$eq <- factor(tab$eq, levels=rev(moy$eq))
    return(tab)
}

#' Violin plot du nombre de points obtenus
points.plot <- function(tab) {
    tmp <- tab %>% group_by(eq, points) %>% summarize(n=n()) %>% mutate(prob=n/sum(n))
    g <- ggplot(data=tmp) +
        geom_tile(aes(x=eq,y=points, fill=prob)) +
        scale_fill_gradient("Proba", low="#F0F0FF", high="#BB0000", labels=percent_format()) +
        scale_x_discrete("Équipe") +
        scale_y_continuous("Nombre de points", breaks=seq(0,100,5)) +
        coord_flip() +
        theme(text = element_text(size=10))
    
    filename <- paste0(journee, "_points_", tab$dyn[1], ".png")
    ggsave(g, filename=file.path(file.base,filename), dpi=100, width=8, height=6)
    return(g)
}

#' Histogramme des probabilités des différents classements
classement.plot <- function(tab) {
    #tab$eq <- factor(tab$eq, levels=rev(levels(tab$eq)))
    nb <- length(levels(tab$eq))
    tab$classement <- factor(tab$classement, levels=nb:1)
    tmp <- tab %>% group_by(eq, classement) %>% summarize(n=n())
    tmp <- tmp %>% mutate(prob=n/sum(n))
    g <- ggplot(data=tmp, aes(x=eq, y=classement)) +
        geom_tile(aes(fill=prob)) +
        scale_fill_gradient("Proba", low="#F0F0FF", high="#BB0000", labels=percent_format()) +
        scale_x_discrete("Équipe") +
        scale_y_discrete("Position en fin de championnat") +
        coord_flip() +
        theme(text=element_text(size=10))
    g
    
    filename <- paste0(journee, "_classement_", tab$dyn[1], ".png")
    ggsave(g, filename=file.path(file.base,filename), dpi=100, width=8, height=6)
    return(g)
}

#' Données des probabilités de classement par équipe
probas.table <- function(tab) {
    nb.rows <- nrow(tab)
    filename <- paste0(journee, "_probas_", tab$dyn[1], ".Rdata")
    tab <- tab %>% group_by(eq, classement) %>% summarize(n=n())
    tab <- tab %>% group_by(eq) %>% 
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
invisible(points.plot(taball))
invisible(classement.plot(taball))
probas.table(taball)


## Méthode 2 : probas sur les 15 dernières journées
cat("- Running 15j\n")
probas <- table.probas(d, derniers=15, journee=journee)
resultats <- mclapply(1:nb.rep, simulation, d, probas, journee=journee)
tab15 <- rbindlist(resultats)
tab15$dyn <- "15j"
tab15 <- reorder.tab(tab15)
invisible(points.plot(tab15))
invisible(classement.plot(tab15))
probas.table(tab15)


## SAUVEGARDE -----------------------------------------------------------

## datas contient la liste des données disponibles (championnat, saison, journée
## dynamique)
##load("src/shiny/app/www/data/datas.Rdata")
##datas <- data.frame(championnat=championnat, saison=saison, journee=journee, derniers="saison", stringsAsFactors=FALSE)
##datas <- rbind(datas, c(championnat, saison, journee, "saison"))
##datas <- rbind(datas, c(championnat, saison, journee, "15j"))
##datas <- rbind(datas, c(championnat, saison, journee, "5j"))
##datas <- unique(datas)
##save(datas, file="src/shiny/app/www/data/datas.Rdata")
