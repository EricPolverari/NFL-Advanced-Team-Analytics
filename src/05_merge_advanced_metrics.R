# ==========================================================
# NFL Next Gen Game Preview
#
# Script: 05_merge_advanced_metrics.R
#
# Purpose:
# Merge SQL player summaries with SumerSports and
# Next Gen Stats datasets to create advanced
# analysis-ready player tables.
#
# Author: Eric Polverari
# Last Updated: 2026-07-01
# ==========================================================
# Load required packages
library(tidyverse)
library(readxl)
library(here)

# Load SumerSports and Next Gen Stats workbook
ss_ngs <- here("data", "raw", "ss_ngs.xlsx")

# Load quarterback datasets
ss_qb_standard <- read_excel(ss_ngs, sheet = "ssQBstand")

ss_qb_man <- read_excel(ss_ngs, sheet = "ssQBvsMan")

ss_qb_zone <- read_excel(ss_ngs, sheet = "ssQBvsZone")

ss_qb_blitz <- read_excel(ss_ngs, sheet = "ssQBvsBlitz")

ss_qb_pressure <- read_excel(ss_ngs, sheet = "ssQBvsPressure")

ngs_qb <- read_excel(ss_ngs, sheet = "ngsQB")

# Load running back datasets
ss_rb_standard <- read_excel(ss_ngs, sheet = "ssRBstandard")

ss_rb_lightbox <- read_excel(ss_ngs, sheet = "ssRB_lightbox")

ss_rb_7man <- read_excel(ss_ngs, sheet = "ssRB_7manbox")

ss_rb_8plus <- read_excel(ss_ngs, sheet = "ssRB_8plusbox")

ngs_rb <- read_excel(ss_ngs, sheet = "ngsRB")

# Load wide receiver datasets
ss_wr_standard <- read_excel(ss_ngs, sheet = "ssWRstandard")

ss_wr_man <- read_excel(ss_ngs, sheet = "ssWRvsMan")

ss_wr_zone <- read_excel(ss_ngs, sheet = "ssWRvsZone")

# Load tight end datasets
ss_te_standard <- read_excel(ss_ngs, sheet = "ssTEstandard")

ss_te_man <- read_excel(ss_ngs, sheet = "ssTEvsMan")

ss_te_zone <- read_excel(ss_ngs, sheet = "ssTEvsZone")

# Load Next Gen Stats receiving dataset
# Separate wide receivers and tight ends
ngs_wr <- read_excel(ss_ngs, sheet = "ngsWRTE") %>%
  filter(POS == "WR")

ngs_te <- read_excel(ss_ngs, sheet = "ngsWRTE") %>%
  filter(POS == "TE")

# ==========================================================
# Load Team Matchup Metrics
# ==========================================================

# Load coverage tendencies
coverage_summary <- read_excel(
  "data/raw/Cov_OL_DL_advstats.xlsx",
  sheet = "CoverageTendencies"
)

# Load offensive and defensive line metrics
line_summary <- read_excel(
  "data/raw/Cov_OL_DL_advstats.xlsx",
  sheet = "espn_OLDL"
)

library(stringr)

line_summary <- line_summary %>%
  mutate(
    PRWR_Rank = as.numeric(str_extract(PRWR, "\\d+(?=\\)$)")),
    RSWR_Rank = as.numeric(str_extract(RSWR, "\\d+(?=\\)$)")),
    PBWR_Rank = as.numeric(str_extract(PBWR, "\\d+(?=\\)$)")),
    RBWR_Rank = as.numeric(str_extract(RBWR, "\\d+(?=\\)$)")),
    
    PRWR = as.numeric(str_extract(PRWR, "^\\d+")) / 100,
    RSWR = as.numeric(str_extract(RSWR, "^\\d+")) / 100,
    PBWR = as.numeric(str_extract(PBWR, "^\\d+")) / 100,
    RBWR = as.numeric(str_extract(RBWR, "^\\d+")) / 100
  )

head(line_summary)

coverage_summary <- coverage_summary %>%
  mutate(
    team = case_when(
      Team == "49ers" ~ "SF",
      Team == "Bears" ~ "CHI",
      Team == "Bengals" ~ "CIN",
      Team == "Bills" ~ "BUF",
      Team == "Broncos" ~ "DEN",
      Team == "Browns" ~ "CLE",
      Team == "Buccaneers" ~ "TB",
      Team == "Cardinals" ~ "ARI",
      Team == "Chargers" ~ "LAC",
      Team == "Chiefs" ~ "KC",
      Team == "Colts" ~ "IND",
      Team == "Commanders" ~ "WAS",
      Team == "Cowboys" ~ "DAL",
      Team == "Dolphins" ~ "MIA",
      Team == "Eagles" ~ "PHI",
      Team == "Falcons" ~ "ATL",
      Team == "Giants" ~ "NYG",
      Team == "Jaguars" ~ "JAX",
      Team == "Jets" ~ "NYJ",
      Team == "Lions" ~ "DET",
      Team == "Packers" ~ "GB",
      Team == "Panthers" ~ "CAR",
      Team == "Patriots" ~ "NE",
      Team == "Raiders" ~ "LV",
      Team == "Rams" ~ "LA",
      Team == "Ravens" ~ "BAL",
      Team == "Saints" ~ "NO",
      Team == "Seahawks" ~ "SEA",
      Team == "Steelers" ~ "PIT",
      Team == "Texans" ~ "HOU",
      Team == "Titans" ~ "TEN",
      Team == "Vikings" ~ "MIN"
    )
  )

line_summary <- line_summary %>%
  mutate(
    team = case_when(
      team == "Arizona Cardinals" ~ "ARI",
      team == "Atlanta Falcons" ~ "ATL",
      team == "Baltimore Ravens" ~ "BAL",
      team == "Buffalo Bills" ~ "BUF",
      team == "Carolina Panthers" ~ "CAR",
      team == "Chicago Bears" ~ "CHI",
      team == "Cincinnati Bengals" ~ "CIN",
      team == "Cleveland Browns" ~ "CLE",
      team == "Dallas Cowboys" ~ "DAL",
      team == "Denver Broncos" ~ "DEN",
      team == "Detroit Lions" ~ "DET",
      team == "Green Bay Packers" ~ "GB",
      team == "Houston Texans" ~ "HOU",
      team == "Indianapolis Colts" ~ "IND",
      team == "Jacksonville Jaguars" ~ "JAX",
      team == "Kansas City Chiefs" ~ "KC",
      team == "Las Vegas Raiders" ~ "LV",
      team == "Los Angeles Chargers" ~ "LAC",
      team == "Los Angeles Rams" ~ "LA",
      team == "Miami Dolphins" ~ "MIA",
      team == "Minnesota Vikings" ~ "MIN",
      team == "New England Patriots" ~ "NE",
      team == "New Orleans Saints" ~ "NO",
      grepl("Giants", team) ~ "NYG",
      grepl("Jets", team) ~ "NYJ",
      team == "Philadelphia Eagles" ~ "PHI",
      team == "Pittsburgh Steelers" ~ "PIT",
      team == "San Francisco 49ers" ~ "SF",
      team == "Seattle Seahawks" ~ "SEA",
      team == "Tampa Bay Buccaneers" ~ "TB",
      team == "Tennessee Titans" ~ "TEN",
      team == "Washington Commanders" ~ "WAS",
      TRUE ~ team
    )
  )

head(line_summary)


# ==========================================================
# Offensive Team Summary
# ==========================================================

# Combine offensive team statistics with offensive line metrics
offense_master <- offense_summary %>%
  left_join(
    line_summary %>%
      select(
        team,
        PBWR,
        PBWR_Rank,
        RBWR,
        RBWR_Rank
      ),
    by = c("posteam" = "team")
  )

write.csv(
  offense_master,
  here("reports", "offense_master.csv"),
  row.names = FALSE
)
# ==========================================================
# Defensive Team Summary
# ==========================================================

# Combine defensive team statistics with DL and coverage metrics
defense_master <- defense_summary %>%
  left_join(
    line_summary %>%
      select(
        team,
        PRWR,
        PRWR_Rank,
        RSWR,
        RSWR_Rank
      ),
    by = c("defteam" = "team")
  ) %>%
  left_join(
    coverage_summary %>%
      select(
        team,
        `Man Rate`,
        `Zone Rate`,
        `Middle Closed Rate`,
        `Middle Open Rate`
      ),
    by = c("defteam" = "team")
  )


write.csv(
  defense_master,
  here("reports", "defense_master.csv"),
  row.names = FALSE
)
