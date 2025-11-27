# Statistical Analysis Functions for Censored Data
# Implements ITRC workflow for baseline water quality assessment

# Source constants
source("functions/analysis_constants.R")

#' Perform Seasonal Kendall Test for Censored Data
#' 
#' Uses NADA2::censeaken for seasonal Kendall with censored data
#' 
#' @param values Numeric vector of observations
#' @param censored Logical vector indicating censored values
#' @param seasons Factor or character vector of seasons
#' @param times Numeric vector of time points
#' @return List with test results
seasonal_kendall_censored <- function(values, censored, seasons, times) {
  require(NADA2)
  
  tryCatch({
    # Use censeaken from NADA2 package
    # Note: censeaken uses different parameter order (time, y, y.cen, group)
    result <- censeaken(times, values, censored, seasons, printstat = FALSE)
    
    list(
      method = "censeaken",
      tau = result$tau_SK,
      p_value = result$pval,
      slope = result$slope,
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "censeaken",
      tau = NA,
      p_value = NA,
      slope = NA,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Perform Mann-Kendall Test for Censored Data
#' 
#' Uses NADA::cenken for Mann-Kendall with censored data
#' 
#' @param values Numeric vector of observations
#' @param censored Logical vector indicating censored values
#' @param times Numeric vector of time points
#' @return List with test results
mann_kendall_censored <- function(values, censored, times) {
  require(NADA)
  
  tryCatch({
    # Use cenken from NADA package
    result <- cenken(values, censored, times)
    
    list(
      method = "cenken",
      tau = result$tau,
      p_value = result$p,
      slope = result$slope,
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "cenken",
      tau = NA,
      p_value = NA,
      slope = NA,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Test for Seasonal Differences in Censored Data
#' 
#' Uses NADA::cendiff to test if groups differ
#' 
#' @param values Numeric vector of observations
#' @param censored Logical vector indicating censored values
#' @param groups Factor or character vector of group labels
#' @return List with test results
test_seasonal_differences <- function(values, censored, groups) {
  require(NADA)
  
  tryCatch({
    # cendiff performs Peto-Peto or other test for censored data
    result <- cendiff(values, censored, as.factor(groups))
    
    list(
      method = "cendiff",
      statistic = result$chisq,
      p_value = result$pvalue,
      is_seasonal = result$pvalue < ALPHA,
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "cendiff",
      statistic = NA,
      p_value = NA,
      is_seasonal = FALSE,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Recensor Data to Single Detection Limit
#' 
#' When multiple DLs exist, recensor to highest DL
#' 
#' @param values Numeric vector of observations
#' @param censored Logical vector indicating censored values
#' @param detection_limits Numeric vector of detection limits
#' @return List with recensored values and censoring indicators
recensor_to_single_dl <- function(values, censored, detection_limits) {
  # Find maximum detection limit
  max_dl <- max(detection_limits[!is.na(detection_limits)])
  
  # Recensor: any value <= max_dl becomes censored at max_dl
  new_censored <- values <= max_dl
  new_values <- ifelse(new_censored, max_dl, values)
  new_dl <- ifelse(new_censored, max_dl, NA_real_)
  
  list(
    values = new_values,
    censored = new_censored,
    detection_limit = new_dl,
    max_dl_used = max_dl
  )
}

#' Perform Kruskal-Wallis Test for Seasonality
#' 
#' Standard Kruskal-Wallis for uncensored data
#' 
#' @param values Numeric vector of observations
#' @param groups Factor or character vector of group labels (e.g., months)
#' @return List with test results
kruskal_wallis_test <- function(values, groups) {
  tryCatch({
    result <- kruskal.test(values ~ groups)
    
    list(
      method = "Kruskal-Wallis",
      statistic = result$statistic,
      p_value = result$p.value,
      is_seasonal = result$p.value < ALPHA,
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "Kruskal-Wallis",
      statistic = NA,
      p_value = NA,
      is_seasonal = FALSE,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Perform Seasonal Kendall Test for Uncensored Data
#' 
#' Uses EnvStats::kendallSeasonalTrendTest for seasonal trend analysis
#' 
#' @param values Numeric vector of observations
#' @param seasons Factor or character vector of seasons
#' @param times Numeric vector of time points
#' @return List with test results
seasonal_kendall_uncensored <- function(values, seasons, times) {
  require(EnvStats)
  
  tryCatch({
    # Create dataframe for formula interface
    df <- data.frame(
      value = values,
      season = seasons,
      normalized_year = as.numeric(times - min(times, na.rm = TRUE))
    )
    
    # Use kendallSeasonalTrendTest which computes slope
    result <- kendallSeasonalTrendTest(
      value ~ season + normalized_year,
      data = df
    )
    
    list(
      method = "seasonal_kendall",
      tau = result$estimate[["tau"]],
      p_value = result$p.value[[2]],
      slope = result$estimate[["slope"]],
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "seasonal_kendall",
      tau = NA,
      p_value = NA,
      slope = NA,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Perform Mann-Kendall Test for Uncensored Data
#' 
#' Uses EnvStats::kendallTrendTest for trend analysis
#' 
#' @param values Numeric vector of observations
#' @param times Numeric vector of time points
#' @return List with test results
mann_kendall_uncensored <- function(values, times) {
  require(EnvStats)
  
  tryCatch({
    # Create dataframe for formula interface
    df <- data.frame(
      value = values,
      normalized_year = as.numeric(times - min(times, na.rm = TRUE))
    )
    
    # Use kendallTrendTest which computes slope
    result <- kendallTrendTest(
      value ~ normalized_year,
      data = df
    )
    
    list(
      method = "mann_kendall",
      tau = result$estimate[["tau"]],
      p_value = result$p.value,
      slope = result$estimate[["slope"]],
      success = TRUE,
      error = NULL
    )
  }, error = function(e) {
    list(
      method = "mann_kendall",
      tau = NA,
      p_value = NA,
      slope = NA,
      success = FALSE,
      error = as.character(e)
    )
  })
}

#' Calculate Summary Statistics for Censored Data
#' 
#' Uses EnvStats or NADA2 methods for censored data quantiles
#' 
#' @param values Numeric vector of observations
#' @param censored Logical vector indicating censored values
#' @return List with median, 5th and 95th percentiles
censored_summary_stats <- function(values, censored) {
  require(NADA2)
  
  tryCatch({
    # Use cenros for robust estimation
    fit <- cenros(values, censored)
    
    # Calculate quantiles
    quants <- quantile(fit, probs = QUANTILES)
    
    list(
      median = quants[2],
      percentile_5th = quants[1],
      percentile_95th = quants[3],
      success = TRUE
    )
  }, error = function(e) {
    # Fallback to simple quantiles if cenros fails
    list(
      median = median(values[!censored], na.rm = TRUE),
      percentile_5th = quantile(values[!censored], QUANTILES[1], na.rm = TRUE),
      percentile_95th = quantile(values[!censored], QUANTILES[3], na.rm = TRUE),
      success = FALSE
    )
  })
}
