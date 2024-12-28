# Should make this the one script to run everything including queries and shiny app using source()
source("shiny-app/global.R")
source("shiny-app/ui.R")
source("shiny-app/server.R")

runApp(list(ui = ui, server = server), launch.browser = TRUE)
