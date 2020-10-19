library(tidyverse)
library(shiny)


shinyServer(function(input, output, session) {
    observe({
        updateSelectInput(
            session,
            "hseason",
            choices = unique(epl_avg$Season),
            selected = "2019-20"
        )
    })
    
    observe({
        updateSelectInput(
            session,
            "hteam",
            choices = epl_avg %>%
                filter(Season == input$hseason) %>%
                select(Team) %>%
                .[[1]]
        )
    })
    observe({
        updateSelectInput(
            session,
            "aseason",
            choices = unique(epl_avg$Season),
            selected = "2019-20"
        )
    })
    
    observe({
        updateSelectInput(
            session,
            "ateam",
            choices = epl_avg %>%
                filter(Season == input$aseason) %>%
                select(Team) %>%
                .[[1]]
        )
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
    
    output$epl_stats <- DT::renderDataTable(DT::datatable(epl_stat[, input$show_vars, drop = FALSE], rownames = FALSE))
    
    # observe({
    #     if (input$random_teams = 0) {
    #         updateCheckboxGroupInput(session = session, inputId = "chosen_teams", NULL, choices = unique(epl_perf$Team), selected = sample(1:544, 20, replace=FALSE))
    #     }
    # })
    
    observe({
        if (input$random_teams == 0)
            return(NULL)
        else if (input$random_teams %% 2 == 0)
        {
            updateCheckboxGroupInput(session,
                                     "chosen_teams",
                                     NULL,
                                     choices = unique(epl_perf$Team))
        }
        else
        {
            updateCheckboxGroupInput(
                session,
                "chosen_teams",
                NULL,
                choices = unique(epl_perf$Team),
                selected = sample_n(epl_perf, size = 20)$Team
            )
        }
    })
    
    observe({
        input$reset_teams
        updateCheckboxGroupInput(
            session,
            "chosen_teams",
            NULL,
            choices = unique(epl_perf$Team),
            selected = NULL
        )
        

    })
    
    sim_fixture <- reactive({simulate(input$chosen_teams)})
        
    output$sim_table <- renderTable(rank(sim_fixture()))
    
    output$sim_matrix <- renderPlot({
        ggplot(sim_fixture(), aes(Chosen.ATeam, reorder(Chosen.HTeam, desc(Chosen.HTeam)), fill=result)) +
            geom_tile(color="white", size=1.5, stat="identity", height=1, width=1) + 
            scale_fill_manual(values = c("lightblue", "cornsilk", "darkseagreen2"), labels=c("Away Win", "Draw", "Home Win")) +
            geom_text(data=sim_fixture(), aes(Chosen.ATeam, Chosen.HTeam, label = score), size=rel(5)) +
            scale_x_discrete(position="top") + scale_y_discrete(expand = c(0, 0)) + 
            ylab("Home") + xlab("Away") +
            theme(axis.text.x = element_text(angle = 55, hjust = 0), legend.position="bottom", 
                  axis.text = element_text(size = 12), axis.title = element_text(size = 20),
                  legend.text = element_text(size = 15),
                  plot.margin = margin(1, 50, 1, 1),
                  panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                  panel.background = element_blank()) +
            guides(fill = guide_legend(title=NULL, reverse=TRUE))
        
    }, height = 800, width = 1230)
    
})
