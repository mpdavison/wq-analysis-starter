# Unit Tests for Water Quality Analysis

This directory contains comprehensive unit tests for the water quality analysis functions.

## Test Files

### `test_statistical_methods.R`
Tests for censored and uncensored statistical analysis functions:

- **Censored Data Methods**:
  - `mann_kendall_censored()` - NADA::cenken wrapper
  - `seasonal_kendall_censored()` - NADA2::censeaken wrapper
  
- **Uncensored Data Methods**:
  - `mann_kendall_uncensored()` - EnvStats::kendallTrendTest wrapper
  - `seasonal_kendall_uncensored()` - EnvStats::kendallSeasonalTrendTest wrapper
  
- **Support Functions**:
  - `recensor_to_single_dl()` - Handle multiple detection limits
  - `test_seasonal_differences()` - NADA::cendiff wrapper
  - `kruskal_wallis_test()` - Test for seasonality
  - `censored_summary_stats()` - Calculate quantiles for censored data

### `test_data_utils.R`
Tests for data utility and validation functions:

- **Detection Limit Parsing**:
  - `parse_detection_limits()` - Extract L-prefix non-detects
  - `has_multiple_dls()` - Identify multiple detection limits
  - `calc_censoring_pct()` - Calculate censoring percentage
  
- **Sample Validation**:
  - `validate_sample_size()` - Check minimum sample size requirements
  
- **Temporal Extraction**:
  - `extract_temporal_info()` - Parse dates and assign seasons
  - `is_single_month()` - Check if all samples from one month

## Running Tests

### Run All Tests
```bash
Rscript tests/run_all_tests.R
```

### Run Individual Test Files
```R
library(testthat)
test_file("tests/test_statistical_methods.R")
test_file("tests/test_data_utils.R")
```

### Run Tests from R Session
```R
setwd("/workspace")
library(testthat)
test_dir("tests")
```

## Test Coverage

The test suite validates:

1. **Correct Structure**: All functions return expected data structures with proper field names
2. **Method Identification**: Statistical methods return correct method names (cenken, censeaken, mann_kendall, seasonal_kendall)
3. **Value Ranges**: Statistical outputs fall within expected ranges (tau ∈ [-1,1], p-value ∈ [0,1])
4. **Edge Cases**: Functions handle empty data, all censored data, and single observations gracefully
5. **Error Handling**: Functions catch errors and return appropriate error messages

## Dependencies

Tests require the following packages:
- `testthat` - Testing framework
- `NADA` - Censored data methods
- `NADA2` - Extended censored data methods
- `EnvStats` - Environmental statistics
- `dplyr` - Data manipulation
- `lubridate` - Date/time handling

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed

## Notes

- Some tests may produce warnings when testing edge cases (e.g., all censored data) - this is expected behavior
- Tests use fixed random seeds (`set.seed()`) for reproducibility
- The NADA packages may mask some base R functions (e.g., `cor`) during test execution
