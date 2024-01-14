# Library Necessary Packages
library(tidyverse)
library(curl)
library(httr)
library(glue)
library(jsonlite)
library(shiny)
library(shinydashboard)

#options(shiny.launch.browser = .rs.invokeShinyWindowExternal)

# Player Data
#players = read_api(https://fantasy.premierleague.com/api/element-summary/{element_id}/)

  # HTTPS requests for api football - don't use this ----
# matches = "https://api.football-data.org/v4/competitions/PL/matches?matchday=17"
# 
# #GET request
# get_req <- GET(url = matches, 
#     add_headers(`X-Auth-Token` = "5db907e3b917494aa2986d4e939449d3"))
# 
# # convert to text
# textfile <- content(get_req,
#                           "text", encoding = "UTF-8")
# 
# # Parsing data in JSON
# json_file <- fromJSON(textfile)
# 
# # convert to df
# matches_df <- as.data.frame(json_file["matches"])
# 
# view(matches_df)
# 
# matches_df1 <- matches_df %>% 
#   select(c(matches.homeTeam, matches.awayTeam))
# view(matches_df1)


# FPL API

