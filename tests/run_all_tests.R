#!/usr/bin/env Rscript
# Run All Unit Tests
# Executes test suites for statistical methods and data utilities

cat("===============================================\n")
cat("Water Quality Analysis - Unit Test Suite\n")
cat("===============================================\n\n")

# Check if running from correct directory
if (!file.exists("tests/test_statistical_methods.R")) {
  stop("Error: Must run from workspace root directory")
}

# Install/load testthat
if (!require("testthat", quietly = TRUE)) {
  cat("Installing testthat package...\n")
  install.packages("testthat")
  library(testthat)
} else {
  library(testthat)
}

# Track test execution
start_time <- Sys.time()

# Run all tests in the tests directory
cat("Running all tests...\n\n")
test_results <- test_dir("tests", reporter = "progress")

# Summary
end_time <- Sys.time()
elapsed <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)

cat("\n===============================================\n")
cat("Test Summary\n")
cat("===============================================\n")
cat("Total time:", elapsed, "seconds\n")

# Print detailed results
print(as.data.frame(test_results))

cat("\n")
if (length(test_results$failed) > 0 && test_results$failed > 0) {
  cat("TESTS FAILED\n")
  quit(status = 1)
} else {
  cat("ALL TESTS PASSED\n")
  quit(status = 0)
}
