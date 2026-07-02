# ==========================================================
# Load Required Libraries
# ==========================================================

# Install packages if they are missing
required_packages <- c(
  "nflverse",
  "tidyverse",
  "DBI",
  "RSQLite",
  "gt",
  "readxl",
  "janitor",
  "here"
)

missing_packages <- required_packages[
  !(required_packages %in% installed.packages()[,"Package"])
]

if(length(missing_packages) > 0){
  install.packages(missing_packages)
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))

# ==========================================================
# Create Project Directory Structure
# ==========================================================
#
# These folders organize the project into:
# - raw data
# - processed data
# - project outputs
# - documentation
#
# The folders are created only if they do not already exist.
# ==========================================================
if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

if (!dir.exists("output")) {
  dir.create("output")
}

if (!dir.exists("docs")) {
  dir.create("docs")
}
