## Fonctions utilisées dans les autres scripts


#' Renvoit pour chaque équipe les pourcentages de victoires, nuls et défaites,
#' à domicile et à l'extérieur. Prend comme argument `d`, le tableau de données
#' des résultats et du calendrier, `derniers`, le nombre des dernières journées
#' à retenir pour le calcul (par défaut, toutes les journées passées sont retenues),
#' et `journee`, la journée considérée comme la dernière.

table.probas <- function(d, derniers=NULL, journee=NULL) {
    ## Filtre les journées à venir
    if (is.null(journee)) 
        sel <- !is.na(d$result)
    else 
        sel <- d$journee <= journee & !is.na(d$result)
    tmp <- d[sel,]
    ## Filtre sur les dernières journées si nécessaire
    if (!is.null(derniers))
        tmp <- tmp[tmp$journee > (max(tmp$journee) - derniers),]
    ## Passage en format "long"
    tmp <- melt(tmp,measure.vars=c("dom", "ext"),id.vars=c("result"))
    setnames(tmp, c("result","dom","eq"))
    ## Recodage des résultats
    tmp$res <- "P"
    tmp$res[tmp$result==tmp$dom] <- "G"
    tmp$res[tmp$result=="nul"] <- "N"
    ## Calcul des pourcentages
    tmp <- tmp %.% group_by(eq,dom) %.% summarize(nb=n(), n=sum(res=="N"), g=sum(res=="G"), p=sum(res=="P"))
    tmp <- tmp %.% mutate(prob.g=g/nb,prob.n=n/nb,prob.p=p/nb)
    ## Retour en format "large"
    tmp <- reshape(tmp, direction="wide", idvar="eq", timevar="dom")
    tmp <- tmp[,list(eq,prob.g.dom,prob.p.dom,prob.g.ext,prob.p.ext)]
    tmp <- data.table(tmp, key="eq")
    return(tmp)
}


#' Calcule le nombre de points et le classement de chaque équipe à partir d'un 
#' tableau de résultats `d`.

calcule.points <- function(d) {
    ## Filtre les dates à venir
    tmp <- d[!is.na(d$result),]
    ## Passage en format "long"
    tmp <- melt(tmp,measure.vars=c("dom", "ext"),id.vars=c("result"))
    setnames(tmp, c("result","dom","eq"))
    ## Recodage du nombre de points par match
    tmp$res <- 0
    tmp$res[tmp$result==tmp$dom] <- 3
    tmp$res[tmp$result=="nul"] <- 1
    ## Somme
    tmp <- tmp[,list(points=sum(res)),by="eq"]
    ## Points de pénalité pour Nantes et Bastia (Ligue 1)
    tmp$points[tmp$eq=="Nantes"] <- tmp$points[tmp$eq=="Nantes"]-1
    tmp$points[tmp$eq=="Bastia"] <- tmp$points[tmp$eq=="Bastia"]+2
    ## Points de pénalité pour Vannes (National)    
    tmp$points[tmp$eq=="Vannes"] <- tmp$points[tmp$eq=="Vannes"]-1
    ## Ajout du classement
    tmp <- tmp[order(tmp$points, decreasing=TRUE),]
    tmp$classement <- 1:nrow(tmp)
    return(tmp)
}


#' Fonction lançant une simulation de fin de championnat, en tirant au sort le
#' résultat de chaque match à venir en fonction des probabilités observées sur
#' les matchs passés. `d` est le tableau du calendrier, `probas` est le tableau 
#' des pourcentages de victoires, nuls et défaites calculé avec `table.probas`,
#' `journee` permet optionnellement de spécifier quelle journée doit être considérée
#' comme la dernière.

simulation <- function(i, d, probas, journee=NULL) {
    ## Sélection des matchs à venir
    if (is.null(journee)) 
        sel <- is.na(d$result)
    else 
        ## On inclut aussi les matchs reportés
        sel <- d$journee > journee | is.na(d$result)
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
}


