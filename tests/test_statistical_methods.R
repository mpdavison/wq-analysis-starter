# Unit Tests for Statistical Methods
# Test suite for censored and uncensored trend analysis functions

library(testthat)

# Source the functions
setwd("/workspace/R")
source("functions/analysis_constants.R")
source("functions/statistical_methods.R")

# Load required packages
library(NADA)
library(NADA2)
library(EnvStats)

context("Statistical Methods - Censored Data")

test_that("cenken (Mann-Kendall censored) returns correct structure", {
  # Create test data with censored values
  set.seed(123)
  values <- c(1, 2, 3, 4, 0.5, 5, 6, 7, 8, 9)
  censored <- c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  times <- seq(1, 10)
  
  result <- mann_kendall_censored(values, censored, times)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "tau", "p_value", "slope", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "cenken")
  
  # Check success
  expect_true(result$success)
  expect_null(result$error)
  
  # Check that statistics are numeric
  expect_type(result$tau, "double")
  expect_type(result$p_value, "double")
  expect_type(result$slope, "double")
  
  # Tau should be between -1 and 1
  expect_gte(result$tau, -1)
  expect_lte(result$tau, 1)
  
  # P-value should be between 0 and 1
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

test_that("cenken handles all censored data gracefully", {
  values <- c(0.5, 0.5, 0.5, 0.5, 0.5)
  censored <- rep(TRUE, 5)
  times <- seq(1, 5)
  
  result <- mann_kendall_censored(values, censored, times)
  
  # Should still return structure even if analysis fails
  expect_type(result, "list")
  expect_named(result, c("method", "tau", "p_value", "slope", "success", "error"))
})

test_that("censeaken (Seasonal Kendall censored) returns correct structure", {
  # Create test data with seasons
  set.seed(456)
  times <- seq(1, 24)
  values <- c(1, 2, 3, 4, 0.5, 5, 6, 7, 8, 9, 10, 11, 
              12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23)
  censored <- c(rep(FALSE, 4), TRUE, rep(FALSE, 19))
  seasons <- factor(rep(1:4, each = 6))
  
  result <- seasonal_kendall_censored(values, censored, seasons, times)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "tau", "p_value", "slope", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "censeaken")
  
  # Check success
  expect_true(result$success)
  expect_null(result$error)
  
  # Check that statistics are numeric
  expect_type(result$tau, "double")
  expect_type(result$p_value, "double")
  expect_type(result$slope, "double")
  
  # Tau should be between -1 and 1
  expect_gte(result$tau, -1)
  expect_lte(result$tau, 1)
  
  # P-value should be between 0 and 1
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

context("Statistical Methods - Uncensored Data")

test_that("mann_kendall (uncensored) returns correct structure", {
  # Create test data with increasing trend
  set.seed(789)
  values <- seq(1, 10) + rnorm(10, 0, 0.5)
  times <- seq(1, 10)
  
  result <- mann_kendall_uncensored(values, times)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "tau", "p_value", "slope", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "mann_kendall")
  
  # Check success
  expect_true(result$success)
  expect_null(result$error)
  
  # Check that statistics are numeric
  expect_type(result$tau, "double")
  expect_type(result$p_value, "double")
  expect_type(result$slope, "double")
  
  # Tau should be between -1 and 1
  expect_gte(result$tau, -1)
  expect_lte(result$tau, 1)
  
  # P-value should be between 0 and 1
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
  
  # For increasing data, tau should be positive
  expect_gt(result$tau, 0)
})

test_that("seasonal_kendall (uncensored) returns correct structure", {
  # Create test data with seasonal pattern
  set.seed(101)
  times <- seq(1, 24)
  values <- seq(1, 24) + rep(c(0, 2, -1, 1), each = 6) + rnorm(24, 0, 0.5)
  seasons <- factor(rep(1:4, each = 6))
  
  result <- seasonal_kendall_uncensored(values, seasons, times)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "tau", "p_value", "slope", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "seasonal_kendall")
  
  # Check success
  expect_true(result$success)
  expect_null(result$error)
  
  # Check that statistics are numeric
  expect_type(result$tau, "double")
  expect_type(result$p_value, "double")
  expect_type(result$slope, "double")
  
  # Tau should be between -1 and 1
  expect_gte(result$tau, -1)
  expect_lte(result$tau, 1)
  
  # P-value should be between 0 and 1
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

context("Statistical Methods - Support Functions")

test_that("recensor_to_single_dl handles multiple detection limits", {
  values <- c(0.5, 1.0, 2.0, 3.0, 4.0)
  censored <- c(TRUE, TRUE, FALSE, FALSE, FALSE)
  detection_limits <- c(0.5, 1.0, NA, NA, NA)
  
  result <- recensor_to_single_dl(values, censored, detection_limits)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("values", "censored", "detection_limit", "max_dl_used"))
  
  # Max DL should be 1.0
  expect_equal(result$max_dl_used, 1.0)
  
  # All values <= max_dl should be censored
  expect_true(result$censored[1])  # 0.5 <= 1.0
  expect_true(result$censored[2])  # 1.0 <= 1.0
  expect_false(result$censored[3]) # 2.0 > 1.0
  
  # Check values are set correctly
  expect_equal(result$values[1], 1.0)
  expect_equal(result$values[2], 1.0)
  expect_equal(result$values[3], 2.0)
})

test_that("test_seasonal_differences with cendiff returns correct structure", {
  # Create test data with group differences
  set.seed(202)
  values <- c(rep(1, 5), rep(2, 5), rep(3, 5))
  censored <- c(rep(c(TRUE, FALSE), length.out = 15))
  groups <- factor(rep(c("A", "B", "C"), each = 5))
  
  result <- test_seasonal_differences(values, censored, groups)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "statistic", "p_value", "is_seasonal", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "cendiff")
  
  # Check that statistics exist
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  expect_type(result$is_seasonal, "logical")
  expect_type(result$success, "logical")
})

test_that("kruskal_wallis_test for seasonality returns correct structure", {
  # Create test data with seasonal differences
  set.seed(303)
  values <- c(rep(10, 10), rep(20, 10), rep(15, 10))
  groups <- factor(rep(c("Season1", "Season2", "Season3"), each = 10))
  
  result <- kruskal_wallis_test(values, groups)
  
  # Check structure
  expect_type(result, "list")
  expect_named(result, c("method", "statistic", "p_value", "is_seasonal", "success", "error"))
  
  # Check method name
  expect_equal(result$method, "Kruskal-Wallis")
  
  # Check success
  expect_true(result$success)
  expect_null(result$error)
  
  # Check that statistics are numeric
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  
  # P-value should be between 0 and 1
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

test_that("censored_summary_stats calculates quantiles correctly", {
  # Create test data
  set.seed(404)
  values <- c(0.5, 0.5, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  censored <- c(TRUE, TRUE, rep(FALSE, 9))
  
  result <- censored_summary_stats(values, censored)
  
  # Check structure
  expect_type(result, "list")
  expect_true(all(c("median", "percentile_5th", "percentile_95th", "success") %in% names(result)))
  
  # Check that statistics are numeric
  expect_type(result$median, "double")
  expect_type(result$percentile_5th, "double")
  expect_type(result$percentile_95th, "double")
  
  # Check ordering: 5th < median < 95th
  expect_lt(result$percentile_5th, result$median)
  expect_lt(result$median, result$percentile_95th)
})

# Tests are run by the main test runner
