# import logos

library(nflreadr)
library(dplyr)

team_logos <- load_teams() %>%
  select(
    posteam = team_abbr,
    team_name,
    team_logo_espn
  )

head(team_logos)

write.csv(
  team_logos,
  here("Tableau", "team_logos.csv"),
  row.names = FALSE
)

library(readxl)
library(httr)
library(here)

# Read the logo table
library(readr)
library(here)

logos <- read_csv(here("Tableau", "team_logos.csv"))

dir.create(
  here("Tableau", "team_logos"),
  showWarnings = FALSE
)

for(i in seq_len(nrow(logos))){
  
  download.file(
    logos$team_logo_espn[i],
    destfile = here(
      "Tableau",
      "team_logos",
      paste0(logos$posteam[i], ".png")
    ),
    mode = "wb"
  )
  
  message("Downloaded ", logos$posteam[i])
}
