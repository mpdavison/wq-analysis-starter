# Unit Tests for Data Utility Functions
# Test suite for detection limit parsing, validation, and temporal extraction

library(testthat)

# Source the functions
setwd("/workspace/R")
source("functions/analysis_constants.R")
source("functions/data_utils.R")

# Load required packages
library(dplyr)
library(lubridate)

context("Detection Limit Parsing")

test_that("parse_detection_limits correctly identifies censored values", {
  values <- c("L0.5", "1.0", "L0.1", "2.5", "3.0")
  
  result <- parse_detection_limits(values)
  
  # Check structure
  expect_s3_class(result, "data.frame")
  expect_named(result, c("is_censored", "numeric_value", "detection_limit"))
  
  # Check censoring flags
  expect_equal(result$is_censored, c(TRUE, FALSE, TRUE, FALSE, FALSE))
  
  # Check numeric values
  expect_equal(result$numeric_value, c(0.5, 1.0, 0.1, 2.5, 3.0))
  
  # Check detection limits (should be NA for uncensored)
  expect_equal(result$detection_limit, c(0.5, NA, 0.1, NA, NA))
})

test_that("parse_detection_limits handles lowercase l prefix", {
  values <- c("l0.5", "L1.0", "2.0")
  
  result <- parse_detection_limits(values)
  
  expect_equal(result$is_censored, c(TRUE, TRUE, FALSE))
  expect_equal(result$numeric_value, c(0.5, 1.0, 2.0))
  expect_equal(result$detection_limit, c(0.5, 1.0, NA))
})

test_that("parse_detection_limits handles all uncensored values", {
  values <- c("1.0", "2.0", "3.0")
  
  result <- parse_detection_limits(values)
  
  expect_equal(result$is_censored, rep(FALSE, 3))
  expect_equal(result$numeric_value, c(1.0, 2.0, 3.0))
  expect_true(all(is.na(result$detection_limit)))
})

test_that("parse_detection_limits handles all censored values", {
  values <- c("L0.5", "L1.0", "L0.1")
  
  result <- parse_detection_limits(values)
  
  expect_equal(result$is_censored, rep(TRUE, 3))
  expect_equal(result$numeric_value, c(0.5, 1.0, 0.1))
  expect_equal(result$detection_limit, c(0.5, 1.0, 0.1))
})

context("Multiple Detection Limits")

test_that("has_multiple_dls identifies multiple detection limits", {
  # Multiple DLs
  dl_values <- c(0.5, 0.5, 1.0, 1.0, NA, NA)
  expect_true(has_multiple_dls(dl_values))
  
  # Single DL
  dl_values <- c(0.5, 0.5, 0.5, NA, NA)
  expect_false(has_multiple_dls(dl_values))
  
  # No DLs (all uncensored)
  dl_values <- c(NA, NA, NA)
  expect_false(has_multiple_dls(dl_values))
  
  # Empty vector
  dl_values <- numeric(0)
  expect_false(has_multiple_dls(dl_values))
})

context("Censoring Percentage")

test_that("calc_censoring_pct calculates percentage correctly", {
  # 50% censored
  censored <- c(TRUE, FALSE, TRUE, FALSE)
  expect_equal(calc_censoring_pct(censored), 50)
  
  # 100% censored
  censored <- rep(TRUE, 5)
  expect_equal(calc_censoring_pct(censored), 100)
  
  # 0% censored
  censored <- rep(FALSE, 5)
  expect_equal(calc_censoring_pct(censored), 0)
  
  # 25% censored
  censored <- c(TRUE, FALSE, FALSE, FALSE)
  expect_equal(calc_censoring_pct(censored), 25)
})

test_that("calc_censoring_pct handles NA values", {
  censored <- c(TRUE, FALSE, NA, TRUE)
  result <- calc_censoring_pct(censored)
  
  # Should count 2 TRUE out of 4 = 50%
  expect_equal(result, 50)
})

context("Sample Size Validation")

test_that("validate_sample_size accepts adequate sample sizes", {
  data <- data.frame(value = 1:50)
  
  result <- validate_sample_size(data, min_n = 50)
  
  expect_type(result, "list")
  expect_named(result, c("valid", "n", "message"))
  expect_true(result$valid)
  expect_equal(result$n, 50)
  expect_match(result$message, "adequate")
})

test_that("validate_sample_size rejects insufficient sample sizes", {
  data <- data.frame(value = 1:30)
  
  result <- validate_sample_size(data, min_n = 50)
  
  expect_false(result$valid)
  expect_equal(result$n, 30)
  expect_match(result$message, "Insufficient")
})

test_that("validate_sample_size uses MIN_SAMPLE_SIZE by default", {
  data <- data.frame(value = 1:MIN_SAMPLE_SIZE)
  
  result <- validate_sample_size(data)
  
  expect_true(result$valid)
  expect_equal(result$n, MIN_SAMPLE_SIZE)
})

context("Temporal Information Extraction")

test_that("extract_temporal_info parses dates correctly", {
  dates <- c("01/15/20 10:30", "06/20/21 14:00", "12/01/19 08:15")
  
  result <- extract_temporal_info(dates)
  
  # Check structure
  expect_s3_class(result, "data.frame")
  expect_named(result, c("datetime", "year", "month", "season"))
  
  # Check datetime parsing
  expect_s3_class(result$datetime, "POSIXct")
  
  # Check years
  expect_equal(result$year, c(2020, 2021, 2019))
  
  # Check months
  expect_equal(result$month, c(1, 6, 12))
  
  # Check seasons
  expect_equal(result$season, c("Under ice", "Open water", "Under ice"))
})

test_that("extract_temporal_info assigns seasons correctly", {
  # Test each season
  dates_under_ice <- c("12/15/20 10:00", "01/15/20 10:00", "02/15/20 10:00")
  dates_high_flow <- c("03/15/20 10:00", "04/15/20 10:00", "05/15/20 10:00")
  dates_open_water <- c("06/15/20 10:00", "07/15/20 10:00", "08/15/20 10:00",
                        "09/15/20 10:00", "10/15/20 10:00", "11/15/20 10:00")
  
  result_ui <- extract_temporal_info(dates_under_ice)
  result_hf <- extract_temporal_info(dates_high_flow)
  result_ow <- extract_temporal_info(dates_open_water)
  
  # Check season assignments
  expect_true(all(result_ui$season == "Under ice"))
  expect_true(all(result_hf$season == "High flow"))
  expect_true(all(result_ow$season == "Open water"))
})

test_that("extract_temporal_info handles month extraction", {
  dates <- c("01/01/20 00:00", "02/01/20 00:00", "03/01/20 00:00",
             "04/01/20 00:00", "05/01/20 00:00", "06/01/20 00:00",
             "07/01/20 00:00", "08/01/20 00:00", "09/01/20 00:00",
             "10/01/20 00:00", "11/01/20 00:00", "12/01/20 00:00")
  
  result <- extract_temporal_info(dates)
  
  expect_equal(result$month, 1:12)
})

context("Single Month Check")

test_that("is_single_month detects single month correctly", {
  # Single month
  months <- rep(6, 10)
  expect_true(is_single_month(months))
  
  # Multiple months
  months <- c(6, 7, 8)
  expect_false(is_single_month(months))
  
  # Single month with NA
  months <- c(6, 6, NA, 6)
  expect_true(is_single_month(months))
  
  # All NA - length 0 is <= 1 so TRUE
  months <- rep(NA_integer_, 5)
  expect_true(is_single_month(months))
})

test_that("is_single_month handles edge cases", {
  # Empty vector
  months <- integer(0)
  expect_true(is_single_month(months))
  
  # Single value
  months <- 3
  expect_true(is_single_month(months))
})

# Tests are run by the main test runner
