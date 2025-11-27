# Water Quality Analysis Pipeline - Function Library
# Main entry point for sourcing all utility functions

# Source all function files
source("functions/analysis_constants.R")  # Load constants first
source("functions/data_utils.R")
source("functions/statistical_methods.R")
source("functions/plotting_utils.R")

# Package dependencies list
required_packages <- c(
  # Data manipulation
  "dplyr",
  "tidyr",
  "readr",
  "purrr",
  "lubridate",
  
  # Censored data analysis (CRITICAL)
  "NADA",
  "NADA2",
  "EnvStats",
  "cenGAM",
  "asbio",
  
  # Trend analysis
  "Kendall",
  
  # Visualization
  "ggplot2",
  "cowplot",
  "scales",
  "gridExtra"
)

# Function to check and install missing packages
check_packages <- function() {
  missing <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
  
  if (length(missing) > 0) {
    cat("Missing packages:", paste(missing, collapse = ", "), "\n")
    cat("Install with: install.packages(c('", paste(missing, collapse = "', '"), "'))\n", sep = "")
    return(FALSE)
  } else {
    cat("All required packages are installed.\n")
    return(TRUE)
  }
}

# Display loaded functions
cat("=== Water Quality Analysis Function Library ===\n")
cat("Loaded function modules:\n")
cat("  - data_utils.R: Detection limit parsing, validation, temporal extraction\n")
cat("  - statistical_methods.R: Censored data methods (censeaken, cenken, recensor)\n")
cat("  - plotting_utils.R: Visualization helpers for censored data\n\n")

cat("Key functions available:\n")
cat("  parse_detection_limits()      - Parse L-prefix non-detects\n")
cat("  validate_sample_size()        - Check n >= MIN_SAMPLE_SIZE requirement\n")
cat("  seasonal_kendall_censored()   - censeaken wrapper (NADA2)\n")
cat("  mann_kendall_censored()       - cenken wrapper (NADA)\n")
cat("  seasonal_kendall_uncensored() - seasonal Kendall (EnvStats)\n")
cat("  mann_kendall_uncensored()     - Mann-Kendall (EnvStats)\n")
cat("  recensor_to_single_dl()       - Handle multiple detection limits\n")
cat("  plot_time_series()            - Time series with censoring indicators\n")
cat("  plot_censored_boxplot()       - Boxplots for censored data\n\n")

# Run package check
check_packages()
