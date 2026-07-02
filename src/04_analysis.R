# ==========================================================
# NFL Next Gen Game Preview
#
# Script: 04_analysis.R
#
# Purpose:
# Analyze the cleaned NFL play-by-play data to generate
# team and player performance metrics used in the game
# preview report and visualizations.
#
# Author: Eric Polverari
# Last Updated: 2026-06-30
# ==========================================================

# load libraries

library(DBI)
library(RSQLite)
library(tidyverse)
library(here)

# Connect to the project database
con <- dbConnect(
  RSQLite::SQLite(),
  here("sql", "nfl_nextgen.sqlite")
)

# ==========================================================
# Offensive Team Summary
# ==========================================================

offense_summary <- dbGetQuery(
  con,
  "
SELECT

    posteam,

    COUNT(*) AS plays,

    AVG(epa) AS avg_epa,
    
    AVG(CASE WHEN play_type='pass' THEN epa END) AS pass_epa,
    
    AVG(CASE WHEN play_type='run' THEN epa END) AS rush_epa,

    AVG(success) AS success_rate,
    
    AVG(CASE WHEN play_type='pass' THEN success END) AS pass_success_rate,
    
    AVG(CASE WHEN play_type='run' THEN success END) AS rush_success_rate,

    AVG(pass) AS pass_rate,

    AVG(rush) AS rush_rate,

    AVG(yards_gained) AS avg_yards,

    AVG(cpoe) AS avg_cpoe,

    AVG(air_yards) AS avg_air_yards,

    AVG(yards_after_catch) AS avg_yac

  FROM play_by_play

  WHERE play_type IN ('pass','run')

  GROUP BY posteam

  ORDER BY avg_epa DESC;
  "
)

head(offense_summary)

# Save offensive team summary
write.csv(
  offense_summary,
  here("reports", "offense_summary.csv"),
  row.names = FALSE
)
# Preview offensive team summary
head(offense_summary)

# ==========================================================
# Offensive Team Summary
# ==========================================================

# Generate a league-wide offensive team summary
offense_summary <- dbGetQuery(
  con,
  "
  SELECT
    posteam,
    COUNT(*) AS plays,
    AVG(epa) AS avg_epa,
    AVG(CASE WHEN play_type='pass' THEN epa END) AS pass_epa,
    AVG(CASE WHEN play_type='run' THEN epa END) AS rush_epa,
    AVG(success) AS success_rate,
    
    AVG(pass) AS pass_rate,
    AVG(rush) AS rush_rate,
    AVG(yards_gained) AS avg_yards,
    AVG(cpoe) AS avg_cpoe,
    AVG(air_yards) AS avg_air_yards,
    AVG(yards_after_catch) AS avg_yac

  FROM play_by_play

  WHERE season_type = 'REG'
    AND play_type IN ('pass', 'run')
    AND posteam IS NOT NULL
    
  GROUP BY posteam

  ORDER BY avg_epa DESC;
  "
)

# Preview the offensive team summary
head(offense_summary)

# Save offensive team summary
write.csv(
  offense_summary,
  here("reports", "offense_summary.csv"),
  row.names = FALSE
)
# Preview offensive team summary
head(offense_summary)

# ==========================================================
# Defensive Team Summary
# ==========================================================

# Generate a league-wide defensive team summary
defense_summary <- dbGetQuery(
  con,
  "
  SELECT
    defteam,
    COUNT(*) AS plays_faced,
    AVG(epa) AS avg_epa_allowed,
    AVG(success) AS success_rate_allowed,
    AVG(pass) AS pass_rate_faced,
    AVG(rush) AS rush_rate_faced,
    AVG(yards_gained) AS avg_yards_allowed,
    AVG(cpoe) AS avg_cpoe_allowed,
    AVG(air_yards) AS avg_air_yards_allowed,
    AVG(yards_after_catch) AS avg_yac_allowed,
    AVG(CASE WHEN play_type='pass' THEN epa END)
    AS pass_epa_allowed,
    AVG(CASE WHEN play_type='run' THEN epa END)
    AS rush_epa_allowed,
    AVG(CASE WHEN play_type='pass' THEN success END)
    AS pass_success_allowed,
    AVG(CASE WHEN play_type='run' THEN success END)
    AS rush_success_allowed

  FROM play_by_play

  WHERE season_type = 'REG'
    AND play_type IN ('pass', 'run')
    AND defteam IS NOT NULL

  GROUP BY defteam

  ORDER BY avg_epa_allowed ASC;
  "
)

# Preview defensive team summary
head(defense_summary)

# Save defensive team summary
write.csv(
  defense_summary,
  here("reports", "defense_summary.csv"),
  row.names = FALSE
)

# validation
nrow(defense_summary)
sum(defense_summary$plays_faced)

# ==========================================================
# Quarterback Summary
# ==========================================================

# Generate season statistics for all quarterbacks
qb_summary <- dbGetQuery(
  con,
  "
  SELECT

    passer_player_id,
    
    passer_player_name,

    posteam,

    COUNT(*) AS passing_plays,

    AVG(epa) AS avg_passing_epa,

    AVG(success) AS passing_success_rate,

    AVG(cpoe) AS avg_cpoe,

    AVG(air_yards) AS avg_air_yards,

    AVG(yards_after_catch) AS avg_yac,

    SUM(complete_pass) AS completions,

    SUM(incomplete_pass) AS incompletions,

    SUM(interception) AS interceptions,

    SUM(touchdown) AS passing_touchdowns

  FROM play_by_play

  WHERE season_type = 'REG'
    AND play_type = 'pass'
    AND passer_player_name IS NOT NULL

  GROUP BY passer_player_id, passer_player_name, posteam

  HAVING COUNT(*) >= 100

  ORDER BY avg_passing_epa DESC;
  "
)

# Preview quarterback summary
head(qb_summary)

# Save quarterback summary
write.csv(
  qb_summary,
  here("reports", "qb_summary.csv"),
  row.names = FALSE
)


# ==========================================================
# Rushing Summary
# ==========================================================

# Generate rushing statistics for all players
rushing_summary <- dbGetQuery(
  con,
  "
  SELECT
  
    rusher_player_id,

    rusher_player_name,

    posteam,

    COUNT(*) AS rushing_plays,

    AVG(epa) AS avg_rushing_epa,
    
    AVG(yards_gained) AS avg_yards_per_rush,

    AVG(success) AS rushing_success_rate,

    SUM(rushing_yards) AS rushing_yards,

    SUM(touchdown) AS rushing_touchdowns

  FROM play_by_play

  GROUP BY rusher_player_id, rusher_player_name, posteam

  HAVING COUNT(*) >= 10

  ORDER BY avg_rushing_epa DESC;
  "
)

# Preview rushing summary
head(rushing_summary)

# Save rushing summary
write.csv(
  rushing_summary,
  here("reports", "rushing_summary.csv"),
  row.names = FALSE
)

# ==========================================================
# Player Receiving Summary
# ==========================================================

# Generate receiving statistics for all players
receiving_summary <- dbGetQuery(
  con,
  "
  SELECT
  
    receiver_player_id,

    receiver_player_name,

    posteam,

    COUNT(*) AS targets,

    SUM(complete_pass) AS receptions,

    AVG(epa) AS avg_receiving_epa,

    AVG(success) AS receiving_success_rate,

    SUM(receiving_yards) AS receiving_yards,

    AVG(air_yards) AS avg_air_yards,

    AVG(yards_after_catch) AS avg_yac,

    SUM(touchdown) AS receiving_touchdowns

  FROM play_by_play

  WHERE season_type = 'REG'
    AND play_type = 'pass'
    AND receiver_player_name IS NOT NULL

  GROUP BY receiver_player_id, receiver_player_name, posteam

  HAVING COUNT(*) >= 10

  ORDER BY avg_receiving_epa DESC;
  "
)

# Preview receiving summary
head(receiving_summary)

# Save receiving summary
write.csv(
  receiving_summary,
  here("reports", "receiving_summary.csv"),
  row.names = FALSE
)

# ==========================================================
# Save Summary Tables to SQLite
# ==========================================================

dbWriteTable(
  con,
  "qb_passing_summary",
  qb_summary,
  overwrite = TRUE
)

dbWriteTable(
  con,
  "rushing_summary",
  rushing_summary,
  overwrite = TRUE
)

dbWriteTable(
  con,
  "receiving_summary",
  receiving_summary,
  overwrite = TRUE
)

# ==========================================================
# Quarterback Offensive Summary
# ==========================================================


qb_offvalue_summary <- dbGetQuery(
  con,
  "
  SELECT
      
      p.passer_player_id,

      p.passer_player_name,

      p.posteam,

      p.passing_plays,

      p.avg_passing_epa,

      p.passing_success_rate,

      p.avg_cpoe,

      p.avg_air_yards,

      p.avg_yac,

      p.completions,

      p.incompletions,

      p.interceptions,

      p.passing_touchdowns,

      COALESCE(r.rushing_plays, 0) AS rushing_plays,

      COALESCE(r.avg_rushing_epa, 0) AS avg_rushing_epa,

      COALESCE(r.rushing_success_rate, 0) AS rushing_success_rate,

      COALESCE(r.rushing_yards, 0) AS rushing_yards,

      COALESCE(r.avg_yards_per_rush, 0) AS avg_yards_per_rush,

      COALESCE(r.rushing_touchdowns, 0) AS rushing_touchdowns

  FROM qb_passing_summary p

  LEFT JOIN rushing_summary r

      ON p.passer_player_name = r.rusher_player_name
      AND p.posteam = r.posteam

  ORDER BY p.avg_passing_epa DESC;
  "
)

# Preview quarterback summary
head(qb_offvalue_summary)

# Save quarterback summary
write.csv(
  qb_offvalue_summary,
  here("reports", "qb_offvalue_summary.csv"),
  row.names = FALSE
)
names(qb_offvalue_summary)


# ==========================================================
# Save 2025 Roster Table to SQLite
# ==========================================================

# Save the 2025 roster data to the SQLite database
dbWriteTable(
  con,
  "rosters_2025",
  rosters_2025,
  overwrite = TRUE
)

# ==========================================================
# Running Back Summary
# ==========================================================

# Combine rushing and receiving statistics for running backs
rb_summary <- dbGetQuery(
  con,
  "
  SELECT

      r.rusher_player_id,

      r.rusher_player_name,

      r.posteam,

      ro.position,

      r.rushing_plays,

      r.avg_rushing_epa,

      r.rushing_success_rate,

      r.rushing_yards,

      r.avg_yards_per_rush,

      r.rushing_touchdowns,

      COALESCE(rec.targets, 0) AS targets,

      COALESCE(rec.receptions, 0) AS receptions,

      COALESCE(rec.avg_receiving_epa, 0) AS avg_receiving_epa,

      COALESCE(rec.receiving_success_rate, 0) AS receiving_success_rate,

      COALESCE(rec.receiving_yards, 0) AS receiving_yards,

      COALESCE(rec.avg_air_yards, 0) AS avg_air_yards,

      COALESCE(rec.avg_yac, 0) AS avg_yac,

      COALESCE(rec.receiving_touchdowns, 0) AS receiving_touchdowns

  FROM rushing_summary r

  LEFT JOIN receiving_summary rec

      ON r.rusher_player_id = rec.receiver_player_id

      AND r.posteam = rec.posteam

  LEFT JOIN rosters_2025 ro

      ON r.rusher_player_id = ro.gsis_id

      AND r.posteam = ro.team

  WHERE ro.position = 'RB'

  ORDER BY r.avg_rushing_epa DESC;
  "
)

# Preview running back summary
head(rb_summary)

# Save running back summary
write.csv(
  rb_summary,
  here("reports", "rb_summary.csv"),
  row.names = FALSE
)


# ==========================================================
# Wide Receiver Summary
# ==========================================================

# Combine receiving and rushing statistics for wide receivers
wr_summary <- dbGetQuery(
  con,
  "
  SELECT

      rec.receiver_player_id,

      rec.receiver_player_name,

      rec.posteam,

      ro.position,

      rec.targets,

      rec.receptions,

      rec.avg_receiving_epa,

      rec.receiving_success_rate,

      rec.receiving_yards,

      rec.avg_air_yards,

      rec.avg_yac,

      rec.receiving_touchdowns,

      COALESCE(r.rushing_plays, 0) AS rushing_plays,

      COALESCE(r.avg_rushing_epa, 0) AS avg_rushing_epa,

      COALESCE(r.rushing_success_rate, 0) AS rushing_success_rate,

      COALESCE(r.rushing_yards, 0) AS rushing_yards,

      COALESCE(r.avg_yards_per_rush, 0) AS avg_yards_per_rush,

      COALESCE(r.rushing_touchdowns, 0) AS rushing_touchdowns

  FROM receiving_summary rec

  LEFT JOIN rushing_summary r

      ON rec.receiver_player_id = r.rusher_player_id

      AND rec.posteam = r.posteam

  LEFT JOIN rosters_2025 ro

      ON rec.receiver_player_id = ro.gsis_id

      AND rec.posteam = ro.team

  WHERE ro.position = 'WR'

  ORDER BY rec.avg_receiving_epa DESC;
  "
)

# Preview wide receiver summary
head(wr_summary)

# Save wide receiver summary
write.csv(
  wr_summary,
  here("reports", "wr_summary.csv"),
  row.names = FALSE
)

# ==========================================================
# Tight End Summary
# ==========================================================

# Combine receiving and rushing statistics for tight ends
te_summary <- dbGetQuery(
  con,
  "
  SELECT

      rec.receiver_player_id,

      rec.receiver_player_name,

      rec.posteam,

      ro.position,

      rec.targets,

      rec.receptions,

      rec.avg_receiving_epa,

      rec.receiving_success_rate,

      rec.receiving_yards,

      rec.avg_air_yards,

      rec.avg_yac,

      rec.receiving_touchdowns,

      COALESCE(r.rushing_plays, 0) AS rushing_plays,

      COALESCE(r.avg_rushing_epa, 0) AS avg_rushing_epa,

      COALESCE(r.rushing_success_rate, 0) AS rushing_success_rate,

      COALESCE(r.rushing_yards, 0) AS rushing_yards,

      COALESCE(r.avg_yards_per_rush, 0) AS avg_yards_per_rush,

      COALESCE(r.rushing_touchdowns, 0) AS rushing_touchdowns

  FROM receiving_summary rec

  LEFT JOIN rushing_summary r

      ON rec.receiver_player_id = r.rusher_player_id

      AND rec.posteam = r.posteam

  LEFT JOIN rosters_2025 ro

      ON rec.receiver_player_id = ro.gsis_id

      AND rec.posteam = ro.team

  WHERE ro.position = 'TE'

  ORDER BY rec.avg_receiving_epa DESC;
  "
)

# Preview tight end summary
head(te_summary)

# Save tight end summary
write.csv(
  te_summary,
  here("reports", "te_summary.csv"),
  row.names = FALSE
)
