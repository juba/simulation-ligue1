library(shiny)

shinyUI(
    fluidPage(
        tags$link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css"),
        tags$link(rel = "stylesheet", href = "perso.css"),
        htmlTemplate("navbar.html"),
        fluidRow(tags$h1("Simulations de fins de championnats 2014/2015")),
        fluidRow(
            column(4,
                   wellPanel(
                       selectInput("championnat", "Championnat", 
                                   choices = c("Ligue 1", "Ligue 2", "National"), 
                                   selected = "Ligue 1"),
                       uiOutput("journeeUI"),
                       radioButtons("dyn", "Dyamique sur",
                                    choices = c("Saison entière" = "saison",
                                                "15 journées précédentes" = "15j"),
                                    selected = "15j"),
                       tags$hr(),
                       tags$p(tags$a(href = "https://github.com/juba/simulation-ligue1", "Code source"))
                   )),
            column(8,
                   tabsetPanel(
                       tabPanel("Points", 
                                htmlOutput("pointsViolin")),
                       tabPanel("Classement",
                                htmlOutput("classProbs"),
                                tags$p("Probabilités de classement final pour l'ensemble des équipes.")),
                       tabPanel("Probas par équipe",
                                tags$p("Sélectionnez une équipe pour afficher les différents classements possibles à la fin de la saison et les probabilités correspondantes."),
                                uiOutput("eq"),
                                htmlOutput("tabProbEq")),
                       tabPanel("Probas par classement",
                                tags$p("Sélectionnez une position dans le classement final pour afficher les probabilités des différentes équipes de finir à cette place."),
                                uiOutput("classement"),
                                htmlOutput("tabProbClass")),
                       tabPanel("À propos",
                                htmlTemplate("apropos.html"))
                       
                   ))
        )
            
        
        
    )    
)