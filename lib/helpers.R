## Fonctions utilisées dans les autres scripts


## Renvoit pour chaque équipe les pourcentages de victoires, nuls et défaites,
## à domicile et à l'extérieur. Prend comme argument `d`, le tableau de données
## des résultats et du calendrier, et `derniers`, le nombre des dernières journées
## à retenir pour le calcul (par défaut, toutes les journées passées sont retenues)

table.probas <- function(d, derniers=NULL) {
    ## Filtre les journées à venir
    tmp <- d[!is.na(d$result),]
    ## Filtre sur les dernières journées si nécessaire
    if (!is.null(derniers)) {
        derniere.journee <- max(tmp$journee)
        tmp <- tmp[tmp$journee >= (derniere.journee - derniers + 1),]
    }
    ## Passage en format "long"
    tmp <- melt(tmp,measure.vars=c("eq.dom", "eq.ext"),id.vars=c("result"))
    setnames(tmp, c("result","dom","eq"))
    ## Recodage des résultats
    tmp$res <- "P"
    tmp$res[tmp$result==tmp$dom] <- "G"
    tmp$res[tmp$result=="nul"] <- "N"
    ## Calcul des pourcentages
    tmp <- tmp %.% group_by(eq,dom) %.% summarize(nb=n(), n=sum(res=="N"), g=sum(res=="G"), p=sum(res=="P"))
    tmp <- tmp %.% mutate(prob.g=g/nb,prob.n=n/nb,prob.p=p/nb)
    return(tmp)
}


## Calcule les probabilités de victoire à domicile, nul, et victoire à l'extérieur,
## pour un match donné. `eq.dom` est le nom de l'équipe à domicile, `eq.ext` l'équipe
## jouant à l'extérieur, et `probas` le tableau des pourcentages de victoires, nuls
## et défaites calculé avec `table.probas`

calcule.probas <- function(eq.dom, eq.ext, probas) {
    ## Extraction des pourcentages des deux équipes
    dom <- probas[probas$eq==eq.dom & dom=="eq.dom"]
    ext <- probas[probas$eq==eq.ext & dom=="eq.ext"]
    ## Calcul des probas
    p.dom <- mean(c(dom$prob.g, ext$prob.p))
    p.nul <- mean(c(dom$prob.n, ext$prob.n))
    p.ext <- mean(c(dom$prob.p, ext$prob.g))
    result <- list(p.dom=p.dom, p.nul=p.nul, p.ext=p.ext)
    return(result)
}

## Tire au sort le résultat d'un match. `eq.dom` est le nom de l'équipe à domicile, 
## `eq.ext` l'équipe jouant à l'extérieur, et `probas` le tableau des pourcentages 
## de victoires, nuls et défaites calculé avec `table.probas`

calcule.resultat <- function(eq.dom, eq.ext, probas) {
    ## Calcul des probabilités de victoire à domicile, nul, à l'extérieur
    prob <- calcule.probas(eq.dom, eq.ext, probas)
    ## Tirage au sort
    alea <- runif(1)
    result <- "nul"
    if (alea<prob$p.dom) result <- "eq.dom"
    if (alea>(1-prob$p.ext)) result <- "eq.ext"
    return(result)
}

## Calcule le nombre de points et le classement de chaque équipe à partir d'un 
## tableau de résultats `d`.

calcule.points <- function(d) {
    ## Filtre les dates à venir
    tmp <- d[!is.na(d$result),]
    ## Passage en format "long"
    tmp <- melt(tmp,measure.vars=c("eq.dom", "eq.ext"),id.vars=c("result"))
    setnames(tmp, c("result","dom","eq"))
    ## Recodage du nombre de points par match
    tmp$res <- 0
    tmp$res[tmp$result==tmp$dom] <- 3
    tmp$res[tmp$result=="nul"] <- 1
    ## Somme
    tmp <- tmp[,list(points=sum(res)),by="eq"]
    ## Points de pénalité pour Nantes et Bastia
    tmp$points[tmp$eq=="Nantes"] <- tmp$points[tmp$eq=="Nantes"]-1
    tmp$points[tmp$eq=="Bastia"] <- tmp$points[tmp$eq=="Bastia"]+2
    ## Tri et ajout du classement
    tmp <- tmp[order(tmp$points, decreasing=TRUE),]
    tmp$classement <- 1:20
    return(tmp)
}


## Fonction lançant une simulation de fin de championnat, en tirant au sort le
## résultat de chaque match à venir en fonction des probabilités observées sur
## les matchs passés. `probas` est le tableau des pourcentages de victoires, nuls 
## et défaites calculé avec `table.probas`

simulation <- function(probas) {
    current <- d
    tmp <- current[is.na(current$result),]
    current$result[is.na(current$result)] <- mapply(calcule.resultat, tmp$eq.dom, tmp$eq.ext, MoreArgs=list(probas=probas))
    calcule.points(current)
}


