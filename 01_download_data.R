# ==========================================================
# NFL Next Gen Game Preview
#
# Script: 01_download_data.R
#
# Purpose:
# Download the 2025 NFL play-by-play dataset from nflverse,
# save a raw local copy, and perform an initial exploration
# of the data prior to cleaning and analysis.
#
# Author: Eric Polverari
# Last Updated: 2026-06-30
# ==========================================================
# ==========================================================
# Load Required Libraries
# ==========================================================

library(nflverse)
library(tidyverse)
library(janitor)
library(here)

# ==========================================================
# Download 2025 NFL Play-by-Play Data
# ==========================================================

# Download the complete 2025 regular season play-by-play
# dataset from nflverse.

pbp_2025 <- load_pbp(2025)

# ==========================================================
# Save Raw Dataset
# ==========================================================

# Save an untouched copy of the play-by-play dataset.
# This preserves the original download and prevents the
# need to repeatedly query nflverse.

saveRDS(
  pbp_2025,
  here("data", "raw", "pbp_2025.rds")
)

# ==========================================================
# Load Official nflfastR Variable Descriptions
# ==========================================================

data(
  "field_descriptions",
  package = "nflfastR"
)

# ==========================================================
# Save Variable Descriptions
# ==========================================================

write.csv(
  field_descriptions,
  here("data", "raw", "field_descriptions.csv"),
  row.names = FALSE
)

# ==========================================================
# Explore Play-by-Play Data
# ==========================================================

# Display the structure of the dataset.
glimpse(pbp_2025)

# List every variable name.
names(pbp_2025)

# Generate summary statistics.
summary(pbp_2025)

# ==========================================================
# Create Project Variable Dictionary
# ==========================================================

# Record each variable name and its data type.
# This table will later be expanded with project-specific
# notes indicating which variables will be retained.

variable_dictionary <-
  tibble(
    variable = names(pbp_2025),
    type = sapply(pbp_2025, function(x) class(x)[1])
  )

# save
write.csv(
  variable_dictionary,
  here("data", "raw", "pbp_variable_dictionary.csv"),
  row.names = FALSE
)

#download
schedules_2025 <- load_schedules(2025)

rosters_2025 <- load_rosters(2025)

teams <- nflreadr::load_teams()
