library(shiny)

datas <- data.frame(championnat=character(),
                    saison=character(),
                    journee.min=numeric(),
                    journee.max=numeric(),
                    stringsAsFactors=FALSE)
datas[1,] <- c("Ligue 1",  "2013-2014", 20, 37)
datas[2,] <- c("Ligue 2",  "2013-2014", 20, 37)
datas[3,] <- c("National", "2013-2014", 22, 33)

#load("www/data/datas.Rdata") # datas

saison <- "2013-2014"


