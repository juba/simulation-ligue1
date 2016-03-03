library(dplyr)

shinyServer(function(input, output, session) {

    imagepath <- reactive({
        tmp <- gsub(" ","_", paste(input$championnat, saison, sep="/"))
        tmp <- file.path("data/", tmp)
        tmp
    })
    
    loadpath <- reactive({
        tmp <- gsub(" ","_", paste(input$championnat, saison, sep="/"))
        tmp <- file.path("www/data/", tmp)
        tmp
    })
    
     output$journeeUI <- renderUI({
         tmp <- datas[datas$championnat==input$championnat &
                      datas$saison==saison,]
         choices <- tmp$journee.max:tmp$journee.min
         if (length(choices)==0) choices <- list(none="<Invalide>")
         selectInput("journee", "Journée :",
                     as.list(choices), selectize=FALSE)
     })
    
    tab <- reactive({
        filename <- paste0(input$journee,"_probas_",input$dyn,".Rdata")
        file <- file.path(loadpath(), filename)
        load(file) # tab
        tab        
    })
    
    output$eq <- renderUI({
        tab <- tab()
        choices <- sort(unique(as.character(tab$eq)))
        selectInput("eq", "Équipe :", as.list(choices), selectize=FALSE)
    })

    output$classement <- renderUI({
        tab <- tab()
        choices <- sort(unique(tab$classement))
        selectInput("classement", "Classement :", as.list(choices), selectize=FALSE)
    })
        
    output$pointsViolin <- renderText({
        filename <- paste0(input$journee,"_points_",input$dyn,".png")
        file <- file.path(imagepath(), filename)
        out <- paste0('<img class="img-responsive" src="',file,'" alt="" />')
        HTML(out)
    })
    
    output$classProbs <- renderText({
        filename <- paste0(input$journee,"_classement_",input$dyn,".png")
        file <- file.path(imagepath(), filename)
        out <- paste0('<img class="img-responsive" src="',file,'" alt="" />')
        HTML(out)
    })
    
    output$tabProbEq <- renderTable({
        tmp <- tab() %>% 
            filter(eq==input$eq) %>% 
            select(classement, prob) %>%
            rename(Classement=classement, Probabilité=prob) %>%
            arrange(Classement)
        tmp
    }, include.rownames=FALSE)
    
    output$tabProbClass <- renderTable({
        tmp <- tab() %>% 
            filter(classement==input$classement) %>% 
            mutate(num_prob=as.numeric(gsub(" %","",prob))) %>%
            arrange(desc(num_prob)) %>%
            select(eq, prob) %>%
            rename(Équipe=eq, Probabilité=prob)
        tmp
    }, include.rownames=FALSE)
    
    
})