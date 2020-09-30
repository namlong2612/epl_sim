library(tidyverse)
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    observe({
        updateSelectInput(session,
                          "hseason",
                          choices = unique(epl_avg$Season),
                          selected = "2019-20")
    })
    
    observe({
        updateSelectInput(
            session,
            "hteam",
            choices = epl_avg %>%
                filter(Season == input$hseason) %>%
                select(Team) %>%
                .[[1]])
    })
    observe({
        updateSelectInput(session,
                          "aseason",
                          choices = unique(epl_avg$Season),
                          selected = "2019-20")
    })
    
    observe({
        updateSelectInput(
            session,
            "ateam",
            choices = epl_avg %>%
                filter(Season == input$aseason) %>%
                select(Team) %>%
                .[[1]])
    })
    output$sim_result <- renderPrint({
        
        if (input$hteam == "") {
            return()
        }
        
        if (input$ateam == "") {
            return()
        }
        
        match_sim(input$hteam,
                  input$hseason,
                  input$ateam,
                  input$aseason,
                  nsim = input$nsim)
    })
    
    output$epl_stats <- DT::renderDataTable(
        DT::datatable(epl_stat[, input$show_vars, drop = FALSE], rownames = FALSE
                      )
        )

})
