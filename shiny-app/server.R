# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  
  # For general data (can't put in function below because this is nested)
  # GET request
  get_req <- GET(url = "https://fantasy.premierleague.com/api/bootstrap-static/")
  
  # convert to text
  textfile <- content(get_req,
                      "text", encoding = "UTF-8")
  
  # Parsing data in JSON
  json_file <- fromJSON(textfile)
  
  # convert to df
  general_teams <- as.data.frame(json_file["teams"])
  
  general_teams <- general_teams %>% 
    select(teams.id, teams.name)
  
  #general_players <- as.data.frame(json_file["element_stats"])
  
  # create function to read the API into a dataframe based on a given link ----
  read_api <- function(link){
    
    #GET request
    get_req <- GET(url = link)
    
    # convert to text
    textfile <- content(get_req,
                        "text", encoding = "UTF-8")
    
    # Parsing data in JSON
    json_file <- fromJSON(textfile)
    
    # convert to df
    parsed_df <- as.data.frame(json_file)
  }
  
  # Matches Data
  matches = read_api("https://fantasy.premierleague.com/api/fixtures/")
  
  # combine to get home and away team names in clean version
  matches_clean <- matches %>% 
    left_join(general_teams, by = (c("team_h" = "teams.id"))) %>% 
    left_join(general_teams, by = (c("team_a" = "teams.id"))) %>% 
    rename(home_team = teams.name.x,
           away_team = teams.name.y,
           home_score = team_h_score,
           away_score = team_a_score) %>%
    mutate(kickoff_time = as.Date(kickoff_time)) %>% 
    filter(kickoff_time < as.Date(Sys.Date())) %>% 
    arrange(desc(kickoff_time)) %>% 
    select(kickoff_time, home_score, away_score, home_team, away_team) 
  
  # separate out home and away columns to just team and score in longer version
  matches_team <- matches_clean %>% 
    pivot_longer(cols = ends_with("team"), 
                 names_to = "team_location",
                 values_to = "team")
  
  matches_score <- matches_clean %>% 
    pivot_longer(cols = ends_with("score"), 
                 names_to = "score_location",
                 values_to = "score") %>% 
    select(-kickoff_time)
  
  matches_comb <- bind_cols(matches_team, matches_score) %>% 
    select(-c(home_team, away_team))

  # get this week's matchups
  future_matches = read_api("https://fantasy.premierleague.com/api/fixtures/?future=1")
  future_matches_comb <- future_matches %>% 
    left_join(general_teams, by = (c("team_h" = "teams.id"))) %>% 
    left_join(general_teams, by = (c("team_a" = "teams.id"))) %>% 
    rename(home_team = teams.name.x,
           away_team = teams.name.y) %>% 
    head(10) %>% 
    mutate(fixture_matchup = paste(home_team, away_team, sep = " vs. "))
  
  # update drop down dynamically
  observe({
    updateSelectInput(session, "fixture_matchup", choices = future_matches_comb$fixture_matchup)
  }
  )
 
  output$last_five_goals <- renderPlot({
    matches_comb %>% 
      filter(str_detect(input$fixture_matchup, team)) %>% 
      head(10) %>% 
      group_by(team) %>% 
      summarise(goals = sum(score)) %>% 
      ungroup() %>%
      arrange(desc(goals)) %>% 
      ggplot(aes(y = team, x = goals, fill = team))+
      geom_col(width = 0.8)+
      scale_fill_manual(values = c('darkgrey', 'lightgrey'))+
      geom_text(aes(label = paste0(goals, ' Goals')), hjust = -0.3, size = 6, family = 'Roboto')+
      scale_x_continuous(expand = expansion(c(0, 0.25))) +
      theme_minimal()+
      labs(y = "Team",
           x = "Goals",
           title = "Goals in the Last 5 Games")+
      theme(
        legend.position = 'none',
        text = element_text(size = 14, family = 'Roboto')
      )
  })
  
}
