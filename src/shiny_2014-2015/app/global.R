library(shiny)
library(dplyr)

datas <- data.frame(championnat=character(),
                    saison=character(),
                    journee.min=numeric(),
                    journee.max=numeric(),
                    stringsAsFactors=FALSE)
datas[1,] <- c("Ligue 1",  "2014-2015", 20, 29)
datas[2,] <- c("Ligue 2",  "2014-2015", 20, 28)
datas[3,] <- c("National", "2014-2015", 18, 24)

saison <- "2014-2015"


