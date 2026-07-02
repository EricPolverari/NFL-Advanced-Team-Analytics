# ==========================================================
# NFL Next Gen Game Preview
#
# Script: 03_database.R
#
# Purpose:
# Create a SQLite database and import the cleaned datasets
# used throughout the project.
#
# Author: Eric Polverari
# Last Updated: 2026-06-30
# ==========================================================

# load libraries
library(DBI)
library(RSQLite)
library(here)

# Load cleaned play-by-play dataset
pbp_clean <- readRDS(
  here("data", "processed", "pbp_clean.rds")
)

# ==========================================================
# Create SQLite Database
# ==========================================================

# Connect to the project database
con <- dbConnect(
  RSQLite::SQLite(),
  here("sql", "nfl_nextgen.sqlite")
)

# Import cleaned play-by-play data
dbWriteTable(
  con,
  "play_by_play",
  pbp_clean,
  overwrite = TRUE
)

# Display all tables in the database
dbListTables(con)

# Display the number of records in the play-by-play table
dbGetQuery(
  con,
  "
  SELECT COUNT(*) AS total_plays
  FROM play_by_play
  "
)

# ==========================================================
# Close Database Connection
# ==========================================================

# Close the database connection
dbDisconnect(con)
