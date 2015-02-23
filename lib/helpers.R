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
    tmp <- tmp %>% group_by(eq,dom) %>% summarize(nb=n(), n=sum(res=="N"), g=sum(res=="G"), p=sum(res=="P"))
    tmp <- tmp %>% mutate(prob.g=g/nb,prob.n=n/nb,prob.p=p/nb)
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


#' Calcule le nombre de points et le classement de chaque équipe à partir d'un
#' tableau de résultats `results` et d'une journée `jour`. Fonction utilisée
#' pour le billet 'Bilan'.

calcule.points.journee <- function(results, jour) {
    ## Filtre les dates à venir
    tmp <- results[results$journee<=jour,]
    ## Passage en format "long"
    tmp <- melt(tmp,measure.vars=c("dom", "ext"),id.vars=c("result", "buts.dom", "buts.ext"))
    setnames(tmp, c("result","buts.dom", "buts.ext","dom","eq"))
    ## Recodage du nombre de points par match
    tmp$res <- 0
    tmp$res[tmp$result==tmp$dom] <- 3
    tmp$res[tmp$result=="nul"] <- 1
    ## Recodage du nombre de buts
    tmp$buts.pour <- ifelse(tmp$dom=="dom", tmp$buts.dom, tmp$buts.ext)
    tmp$buts.contre <- ifelse(tmp$dom=="dom", tmp$buts.ext, tmp$buts.dom)
    ## Somme
    tmp <- tmp[,list(points=sum(res),buts.pour=sum(buts.pour), buts.contre=sum(buts.contre)),by="eq"]
    ## Points de pénalité pour Nantes et Bastia (Ligue 1)
    tmp$points[tmp$eq=="Nantes"] <- tmp$points[tmp$eq=="Nantes"]-1
    tmp$points[tmp$eq=="Bastia"] <- tmp$points[tmp$eq=="Bastia"]+2
    ## Points de pénalité pour Vannes (National)
    tmp$points[tmp$eq=="Vannes"] <- tmp$points[tmp$eq=="Vannes"]-1
    ## Calcul différences de buts
    tmp$diff <- tmp$buts.pour - tmp$buts.contre
    ## Ajout du classement
    tmp <- tmp %>% arrange(desc(points), desc(diff))
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


#' Fonction qui charge les données pour l'ensemble des résultats
#' du championnat à partir d'une page de maxifoot.fr. Utilisée
#' dans le billet bilan

scrape.championnat <- function(url) {

    doc <- htmlParse(url, encoding="latin-1")
    tableNodes <- getNodeSet(doc, "//table[@class='cd1']")
    tables <- lapply(tableNodes, readHTMLTable)
    for (i in 1:length(tables)) {
        names(tables[[i]]) <- c("eq.dom","eq.ext","score")
        tables[[i]]$journee <- i
    }

    results <- rbindlist(tables)

    ## Recodages

    results <- within(results, {
        ## Matchs à venir
        score[score=="-"] <- NA
        score[!grepl("-", score)] <- NA
        ## Extraction score
        buts.dom <- as.numeric(gsub("-[0-9]+$","",score))
        buts.ext <- as.numeric(gsub("^[0-9]+-","",score))
        ## Recodage résultat
        result <- NA
        result[buts.dom > buts.ext] <- "dom"
        result[buts.dom < buts.ext] <- "ext"
        result[buts.dom == buts.ext] <- "nul"
        ## Recodage équipes
        dom <- as.character(eq.dom)
        ext <- as.character(eq.ext)
    })

    results <- results[,list(dom,ext,buts.dom,buts.ext,journee,result)]

    return(results)
}

#' Fonction qui calcule les classements aux différentes journées d'un'
#' championnat à partir de la liste des résultats des matchs. Utilisée
#' pour les bilans.

calcule.classements <- function(results) {
    classements <- rbindlist(lapply(20:38, function(i) {
        df <- calcule.points.journee(results,i)
        df$journee <- i
        df
    }))
    classements <- as.data.frame(classements)
    names(classements) <- c("eq", "points.reel", "pour", "contre", "diff", "classement.reel", "journee")
    return(classements)

}


#' Charge et agrège l'ensemble des résultats des simulations d'un championnat.
#' Utilisée pour les bilans.

load.simulations <- function(dir) {
    rdata_files <- list.files(path=dir, pattern="*.Rdata", full.names=TRUE)
    journees <- gsub('^.*/(\\d+?)_probas.*$', '\\1', rdata_files)
    typesim <- gsub('^.*/\\d+?_probas_(.*?)\\.Rdata.*$', '\\1', rdata_files)
    
    d <- data.frame(journee=numeric(), typesim=character(), eq=character(), classement=numeric(), n =numeric(), prob=character())

    for (i in 1:length(rdata_files)) {
        load(rdata_files[i])
        tab$journee <- journees[i]
        tab$typesim <- typesim[i]
        d <- rbind(d, as.data.frame(tab))
    }
    d$prob <- as.numeric(gsub(" %", "", d$prob))
    d$eq <- as.character(d$eq)
    d$journee <- as.numeric(d$journee)

    return(d)
}
