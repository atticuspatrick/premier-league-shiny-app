ui <- dashboardPage(
  
  dashboardHeader(
    title = "Premier League Match Up Comparison"
  ),
  
  dashboardSidebar(
    selectInput("fixture_matchup",
                "Choose Fixture",
                "Names")
  ),
  
  dashboardBody(
    plotOutput("last_five_goals")
  )
  
)
