library(shinythemes)
library(shiny)
library(DT)

# Define UI for application
shinyUI(navbarPage(
    "EPL What If",
    tabPanel(
        "Match Sim",
        fluidPage(
            theme = shinytheme("simplex"),
            
            
            titlePanel("Match Simulation"),
            
            tags$head(tags$style(
                HTML(
                    "hr {border-top: 1px solid #000000;}",
                    "#sim_result{font-size: 20px;}",
                    "
                                 .multicol {
                                   -webkit-column-count: 4; /* Chrome, Safari, Opera */
                                   -moz-column-count: 4;    /* Firefox */
                                   column-count: 4;
                                   -moz-column-fill: auto;
                                   -column-fill: auto;
                                 }
                                 "
                )
            )),
            
            # Sidebar
            sidebarLayout(
                sidebarPanel(
                    selectInput(
                        inputId = "hseason",
                        label = "Choose Home team's Season:",
                        choices = ""
                    ),
                    selectInput(
                        inputId = "hteam",
                        label = "Home Team:",
                        choices = ""
                    ),
                    hr(),
                    
                    selectInput(
                        inputId = "aseason",
                        label = "Choose Away team's Season:",
                        choices = ""
                    ),
                    selectInput(
                        inputId = "ateam",
                        label = "Away Team:",
                        choices = ""
                    ),
                    hr(),
                    
                    numericInput(
                        inputId = "nsim",
                        label = "Number of Simulations:",
                        value = 10000,
                        min = 1,
                        max = 1000000
                    ),
                    helpText(
                        "Note: if you want to simulate a single match between 2 teams, set the number of simulations to 1"
                    )
                    
                    #actionButton("goButton", "Go!")
                    #submitButton("Simulate")
                    
                ),
                
                # Main
                mainPanel(
                    verbatimTextOutput("sim_result"),
                    h4(
                        "Teams Statistics are provided on the 3rd tab to give you a better idea of a team's attack and defense strength."
                    )
                    
                )
            )
        )
    ),
    
    
    # League sim tab
    tabPanel(
        "League Sim",
        fluidPage(title = "League Simulator",
                  titlePanel("League Simulation"),
                  sidebarLayout(
                      sidebarPanel(
                          h3("Choose 20 teams to simulate a league:"),
                          h5(
                              "Teams Statistics are provided on the 3rd tab to give you a better idea of a team's attack and defense strength."
                          ),
                          tags$div(
                              class = 'multicol',
                              checkboxGroupInput("chosen_teams", NULL, choices = unique(epl_perf$Team))
                          ),
                          hr(),
                          actionButton("random_teams", "Select 20 random teams"),
                          helpText("You can also use this button to clear your choices"),
                          actionButton("reset_teams", "Clear")
                      ),
                      mainPanel(
                          h2("League Table"),
                          tableOutput('sim_table'),
                          helpText(
                              "Pos: Position, Pts: Points, W: Matches Won, D: Matches Draw, L: Matches Lost, GF: Goals For, GA: Goals Against, GD: Goals Difference"
                          ),
                          
                          h2("Result Matrix"),
                          plotOutput("sim_matrix")
                      )
                  ))
    ),
    
    # Team Stats tab
    tabPanel(
        "Team Stats",
        fluidPage(title = "Teams' Goals Scored and Conceded Stats",
                  sidebarLayout(
                      sidebarPanel(
                          checkboxGroupInput(
                              "show_vars",
                              "Columns to show:",
                              names(epl_stat),
                              selected = names(epl_stat)
                          )
                      ),
                      
                      mainPanel(
                          helpText("Click the column header to sort a column."),
                          DT::dataTableOutput("epl_stats")
                      )
                      
                  ))
    ),
    
    # About tab
    tabPanel("About",
             fluidPage(includeMarkdown('README.md')))
    
))
