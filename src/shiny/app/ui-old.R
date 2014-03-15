library(shiny)

load("data/datas.Rdata") # datas

shinyUI(pageWithSidebar(

    headerPanel(    HTML("<h1>Toto</h1>"),"Simulations de fin de championnat"),

    sidebarPanel(
        selectInput("championnat", "Championnat :",
                    as.list(unique(datas$championnat))),
        
        uiOutput("saison"),
        uiOutput("journee"),
        uiOutput("dynamique")
        
        ),

    mainPanel(
        tabsetPanel(
            tabPanel("Nombre de points", imageOutput("pointsViolin", width=700, height=600)),
            tabPanel("Classement final", imageOutput("classProbs", width=700, height=700)),
            tabPanel("Probabilités par équipe", 
                     uiOutput("eq"),
                     tableOutput("tabProbEq")
            ),
            tabPanel("Probabilités par classement", 
                     uiOutput("classement"),
                     tableOutput("tabProbClass")
            )
        )
    )
))
