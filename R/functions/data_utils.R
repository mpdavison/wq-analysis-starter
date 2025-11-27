# Data Utility Functions for Water Quality Analysis
# Handles detection limits, censored data, and data validation

# Source constants
source("functions/analysis_constants.R")

#' Parse Detection Limits from Value Strings
#' 
#' Extracts censored/non-detect indicators (L prefix) and numeric values
#' from laboratory result strings
#' 
#' @param value_col Character vector of values, may contain "L" prefix for non-detects
#' @return Data frame with columns: is_censored (logical), numeric_value (numeric), 
#'         detection_limit (numeric)
parse_detection_limits <- function(value_col) {
  require(dplyr)
  
  # Initialize result vectors
  is_censored <- grepl("^L", value_col, ignore.case = TRUE)
  
  # Extract numeric values (remove L prefix if present)
  numeric_value <- as.numeric(gsub("^[Ll]", "", value_col))
  
  # For censored values, detection limit equals the numeric value
  detection_limit <- ifelse(is_censored, numeric_value, NA_real_)
  
  data.frame(
    is_censored = is_censored,
    numeric_value = numeric_value,
    detection_limit = detection_limit,
    stringsAsFactors = FALSE
  )
}

#' Check for Multiple Detection Limits
#' 
#' Determines if a dataset has multiple detection limits for censored observations
#' 
#' @param dl_values Numeric vector of detection limit values (NA for uncensored)
#' @return Logical - TRUE if multiple unique detection limits exist
has_multiple_dls <- function(dl_values) {
  unique_dls <- unique(dl_values[!is.na(dl_values)])
  length(unique_dls) > 1
}

#' Calculate Censoring Percentage
#' 
#' @param is_censored Logical vector indicating censored observations
#' @return Numeric percentage of censored observations (0-100)
calc_censoring_pct <- function(is_censored) {
  sum(is_censored, na.rm = TRUE) / length(is_censored) * 100
}

#' Validate Sample Size for Analysis
#' 
#' Checks if sample meets minimum requirements for statistical analysis
#' 
#' @param data Data frame with observations
#' @param min_n Minimum sample size (default MIN_SAMPLE_SIZE per ITRC guidance)
#' @return List with valid (logical) and message (character)
validate_sample_size <- function(data, min_n = MIN_SAMPLE_SIZE) {
  n <- nrow(data)
  
  list(
    valid = n >= min_n,
    n = n,
    message = ifelse(n >= min_n, 
                     paste("Sample size adequate (n =", n, ")"),
                     paste("Insufficient sample size (n =", n, ", need >= ", min_n, ")", sep = ""))
  )
}

#' Extract Month and Season from Date
#' 
#' @param datetime_col Character or POSIXct vector of sample dates
#' @return Data frame with month, season columns
extract_temporal_info <- function(datetime_col) {
  require(lubridate)
  
  # Parse datetime
  dt <- as.POSIXct(datetime_col, format = "%m/%d/%y %H:%M")
  
  # Extract month
  month <- month(dt)
  
  # Assign seasons (hydrological periods)
  # Under ice: Dec, Jan, Feb (12, 1, 2)
  # High flow: Mar, Apr, May (3, 4, 5)
  # Open water: Jun, Jul, Aug, Sep, Oct, Nov (6, 7, 8, 9, 10, 11)
  season <- case_when(
    month %in% c(12, 1, 2) ~ "Under ice",
    month %in% c(3, 4, 5) ~ "High flow",
    month %in% c(6, 7, 8, 9, 10, 11) ~ "Open water",
    TRUE ~ NA_character_
  )
  
  data.frame(
    datetime = dt,
    year = year(dt),
    month = month,
    season = season,
    stringsAsFactors = FALSE
  )
}

#' Check if All Samples in Single Month
#' 
#' @param month_col Integer vector of months
#' @return Logical
is_single_month <- function(month_col) {
  unique_months <- unique(month_col[!is.na(month_col)])
  length(unique_months) <= 1
}
