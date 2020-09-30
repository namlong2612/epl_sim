library(shinythemes)
library(shiny)
library(DT)

# Define UI for application 
shinyUI(navbarPage("EPL Match Sim",
                   tabPanel("Simulation",
    fluidPage(
        theme = shinytheme("simplex"),

    # Application title
    titlePanel("English Premier League Match Simulation"),
    
    tags$head(
        tags$style(HTML("hr {border-top: 1px solid #000000;}", "#sim_result{font-size: 20px;}"))
    ),

    # Sidebar 
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "hseason",
                        label = "Choose Home team's Season:",
                        choices = ""
                        ),
            selectInput(inputId = "hteam",
                        label = "Home Team:",
                        choices = ""
            ),
            hr(),
            
            selectInput(inputId = "aseason",
                        label = "Choose Away team's Season:",
                        choices = ""
            ),
            selectInput(inputId = "ateam",
                        label = "Away Team:",
                        choices = ""
            ),
            hr(),
            
            numericInput(inputId = "nsim",
                         label = "Number of Simulations:",
                         value = 10000,
                         min = 1,
                         max = 1000000),
            helpText("Note: if you want to simulate a single match between 2 teams, set the number of simulations to 1")
            
            #actionButton("goButton", "Go!")
            #submitButton("Simulate")
            
        ),

        # Main
        mainPanel(
            verbatimTextOutput("sim_result"),
            h4("Teams Statistics are provided on the next tab to give you a better idea of a team's attack and defense strength.")
            
        )
    )
)),

tabPanel("Team Stats",
         fluidPage(
             title = "Teams' Goals Scored and Conceded Stats",
             sidebarLayout(
                 sidebarPanel(
                     checkboxGroupInput("show_vars", "Columns to show:", 
                                        names(epl_stat), selected = names(epl_stat))
                 ),
                 
                 mainPanel(
                     helpText("Click the column header to sort a column."),
                     DT::dataTableOutput("epl_stats")
                 )
                 
             )
         )
         ),
tabPanel("About",
         fluidPage(includeMarkdown('README.md'))
)

))
