library(shiny)
library(dplyr)

datas <- data.frame(championnat=character(),
                    saison=character(),
                    journee.min=numeric(),
                    journee.max=numeric(),
                    stringsAsFactors=FALSE)
datas[1,] <- c("Ligue 1",  "2015-2016", 21, 21)
datas[2,] <- c("Ligue 2",  "2015-2016", 21, 21)
datas[3,] <- c("National", "2015-2016", 18, 18)

saison <- "2015-2016"


