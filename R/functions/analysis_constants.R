# Analysis Constants
# Configuration values for water quality analysis pipeline

# Sample size requirements
MIN_SAMPLE_SIZE <- 50  # Minimum observations per parameter-station group for trend analysis

# Censoring thresholds
MAX_CENSORING_PCT <- 50  # Maximum percentage of non-detects for analysis (above this = insufficient data)

# Statistical significance
ALPHA <- 0.05  # Significance level for hypothesis tests

# Seasonal analysis
MIN_SEASONS <- 2  # Minimum number of seasons required for seasonal analysis

# Detection limit handling
SINGLE_DL_ONLY <- TRUE  # Whether to require single detection limit (use recensor() if FALSE)

# Output formatting
QUANTILES <- c(0.05, 0.50, 0.95)  # Quantiles to report in summaries
