# ==========================================================
# NFL Next Gen Game Preview
#
# Script: 02_clean_data.R
#
# Purpose:
# Load the raw 2025 NFL play-by-play dataset, retain the
# variables required for game preview analysis, and save
# a cleaned dataset for use in the project database and
# downstream analysis.
#
# Author: Eric Polverari
# Last Updated: 2026-06-30
# ==========================================================

# ==========================================================
# Load Required Libraries
# ==========================================================

library(tidyverse)
library(here)

# ==========================================================
# Load Raw Data
# ==========================================================

# Load the raw play-by-play dataset
pbp_raw <- readRDS(
  here("data", "raw", "pbp_2025.rds")
)

# Create a working copy for cleaning
pbp_clean <- pbp_raw

# ==========================================================
# Explore the Dataset
# ==========================================================

# Display the structure of the dataset
glimpse(pbp_clean)

# Display summary statistics
summary(pbp_clean)

# Count missing values for each variable
missing_summary <- tibble(
  variable = names(pbp_clean),
  missing = colSums(is.na(pbp_clean)),
  percent_missing = round(
    colSums(is.na(pbp_clean)) / nrow(pbp_clean) * 100,
    2
  )
)
# Save missing value summary
write.csv(
  missing_summary,
  here("data", "processed", "missing_summary.csv"),
  row.names = FALSE
)

# Keep variables used for analysis
pbp_clean <- pbp_clean %>%
  select(
    
    # Game Information
    play_id,
    game_id,
    season,
    season_type,
    week,
    game_date,
    home_team,
    away_team,
    
    # Teams
    posteam,
    defteam,
    posteam_type,
    
    # Game Situation
    qtr,
    game_half,
    down,
    ydstogo,
    yardline_100,
    drive,
    desc,
    
    quarter_seconds_remaining,
    half_seconds_remaining,
    game_seconds_remaining,
    
    score_differential,
    posteam_score,
    defteam_score,
    home_score,
    away_score,
    
    # Play Type
    play_type,
    pass,
    rush,
    qb_dropback,
    qb_scramble,
    
    shotgun,
    no_huddle,
    
    # Passing
    passer_player_id,
    passer_player_name,
    
    receiver_player_id,
    receiver_player_name,
    
    air_yards,
    yards_after_catch,
    
    complete_pass,
    incomplete_pass,
    
    interception,
    sack,
    
    qb_hit,
    
    # Rushing
    rusher_player_id,
    rusher_player_name,
    
    rushing_yards,
    
    # Receiving
    receiving_yards,
    
    # Play Result
    yards_gained,
    
    first_down,
    first_down_pass,
    first_down_rush,
    first_down_penalty,
    
    touchdown,
    
    fumble,
    fumble_lost,
    
    penalty,
    penalty_team,
    
    # Advanced Analytics
    epa,
    wpa,
    wp,
    
    air_epa,
    yac_epa,
    
    cp,
    cpoe,
    
    success,
    
    pass_oe,
    
    xpass,
    
    # Field Goals, XP, and 2PT Conversions
    field_goal_attempt,
    field_goal_result,
    
    extra_point_attempt,
    extra_point_result,
    
    two_point_attempt,
    two_point_conv_result
  )


# ==========================================================
# Validate and Save Cleaned Data
# ==========================================================

# Verify the dimensions of the cleaned dataset
dim(pbp_clean)

# Display the remaining variables
names(pbp_clean)

# Display the first few rows of the cleaned dataset
head(pbp_clean)

# Export the cleaned variable list
write.csv(
  data.frame(variable = names(pbp_clean)),
  here("data", "processed", "pbp_clean_variables.csv"),
  row.names = FALSE
)

# Save cleaned play-by-play dataset
saveRDS(
  pbp_clean,
  here("data", "processed", "pbp_clean.rds")
)
