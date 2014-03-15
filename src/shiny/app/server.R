
shinyServer(function(input, output) {

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
    
     output$journee <- renderUI({
         choices <- unique(datas$journee[datas$championnat==input$championnat &
                                         datas$saison==saison])
         if (length(choices)==0) choices <- list(none="<Invalide>")
         selectInput("journee", "Journée :",
                     as.list(choices))
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
        selectInput("eq", "Équipe :", as.list(choices))
    })

    output$classement <- renderUI({
        tab <- tab()
        choices <- sort(unique(tab$classement))
        selectInput("classement", "Classement :", as.list(choices))
    })
        
    output$pointsViolin <- renderText({
        filename <- paste0(input$journee,"_violin_",input$dyn,".png")
        file <- file.path(imagepath(), filename)
        out <- paste0('<img src="',file,'" width="700" height="600" alt="Violin plot" />')
        HTML(out)
    })
    
    output$classProbs <- renderText({
        filename <- paste0(input$journee,"_probas_",input$dyn,".png")
        file <- file.path(imagepath(), filename)
        out <- paste0('<img src="',file,'" width="700" height="700" alt="Violin plot" />')
        HTML(out)
    })
    
    output$tabProbEq <- renderTable({
        tab <- tab()
        tmp <- tab[tab$eq==input$eq, c("classement", "prob")]
        names(tmp) <- c("Classement", "Probabilité")
        tmp
    }, include.rownames=FALSE)
    
    output$tabProbClass <- renderTable({
        tab <- tab()
        tmp <- tab[tab$classement==input$classement, c("eq", "prob")]
        #tmp <- tmp[order(as.numeric(gsub("%","",tmp$prob)),decreasing=TRUE),]
        names(tmp) <- c("Équipe", "Probabilité")
        tmp
    }, include.rownames=FALSE)
    
    
})