# Visualization Helper Functions
# Functions for generating publication-quality plots

# Source constants
source("functions/analysis_constants.R")

#' Create Censored Data Boxplot with Non-detects
#' 
#' Generates boxplot showing both detected and non-detect values
#' 
#' @param data Data frame with value, is_censored, and grouping columns
#' @param group_var Column name for grouping (e.g., season, station)
#' @param value_var Column name for values
#' @param title Plot title
#' @return ggplot object
plot_censored_boxplot <- function(data, group_var, value_var = "value", title = "") {
  require(ggplot2)
  
  ggplot(data, aes(x = .data[[group_var]], y = .data[[value_var]])) +
    geom_boxplot(aes(fill = .data[[group_var]]), alpha = 0.6, outlier.shape = NA) +
    geom_jitter(aes(color = is_censored, shape = is_censored), 
                width = 0.2, alpha = 0.5, size = 2) +
    scale_color_manual(
      values = c("FALSE" = "darkblue", "TRUE" = "red"),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    scale_shape_manual(
      values = c("FALSE" = 16, "TRUE" = 1),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    theme_minimal() +
    theme(
      legend.position = "right",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(
      title = title,
      color = "Status",
      shape = "Status",
      fill = group_var
    )
}

#' Create Time Series Plot with Trend Line
#' 
#' @param data Data frame with datetime, value, is_censored
#' @param add_trend Logical, add linear trend line
#' @param title Plot title
#' @return ggplot object
plot_time_series <- function(data, add_trend = TRUE, title = "") {
  require(ggplot2)
  
  p <- ggplot(data, aes(x = datetime, y = value)) +
    geom_line(alpha = 0.3, color = "gray50") +
    geom_point(aes(color = is_censored, shape = is_censored), 
               alpha = 0.7, size = 2.5) +
    scale_color_manual(
      values = c("FALSE" = "steelblue", "TRUE" = "coral"),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    scale_shape_manual(
      values = c("FALSE" = 16, "TRUE" = 1),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      title = title,
      x = "Date",
      y = "Concentration",
      color = "Status",
      shape = "Status"
    )
  
  if (add_trend) {
    p <- p + geom_smooth(method = "lm", se = TRUE, color = "red", 
                         linetype = "dashed", linewidth = 1)
  }
  
  return(p)
}

#' Create Summary Statistics Table Visual
#' 
#' @param stats_df Data frame with summary statistics
#' @return ggplot table
plot_summary_table <- function(stats_df) {
  require(ggplot2)
  require(gridExtra)
  
  # Format table
  table_grob <- tableGrob(stats_df, rows = NULL, theme = ttheme_default(
    core = list(fg_params = list(cex = 0.8)),
    colhead = list(fg_params = list(cex = 0.9, fontface = "bold"))
  ))
  
  grid::grid.draw(table_grob)
}

#' Create Censoring Rate Histogram
#' 
#' @param censoring_pcts Numeric vector of censoring percentages
#' @return ggplot object
plot_censoring_histogram <- function(censoring_pcts) {
  require(ggplot2)
  
  df <- data.frame(pct_censored = censoring_pcts)
  
  ggplot(df, aes(x = pct_censored)) +
    geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7, color = "black") +
    geom_vline(xintercept = MAX_CENSORING_PCT, color = "red", linetype = "dashed", linewidth = 1) +
    theme_minimal() +
    labs(
      title = "Distribution of Censoring Rates",
      subtitle = paste0("Red line indicates ", MAX_CENSORING_PCT, "% threshold for analysis suitability"),
      x = "Censoring Rate (%)",
      y = "Frequency"
    )
}

#' Generate Multi-Panel Seasonal Plot
#' 
#' @param data Data frame with season, value, is_censored
#' @param parameter_name Name of parameter for title
#' @return ggplot object
plot_seasonal_panel <- function(data, parameter_name = "") {
  require(ggplot2)
  require(dplyr)
  
  # Order seasons
  data <- data %>%
    mutate(season = factor(season, levels = c("Under ice", "High flow", "Open water")))
  
  ggplot(data, aes(x = season, y = value, fill = season)) +
    geom_violin(alpha = 0.5, draw_quantiles = c(0.25, 0.5, 0.75)) +
    geom_jitter(aes(color = is_censored, shape = is_censored), 
                width = 0.2, alpha = 0.6, size = 2) +
    scale_color_manual(
      values = c("FALSE" = "black", "TRUE" = "red"),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    scale_shape_manual(
      values = c("FALSE" = 16, "TRUE" = 1),
      labels = c("FALSE" = "Detected", "TRUE" = "Non-detect")
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 0)
    ) +
    labs(
      title = paste("Seasonal Pattern:", parameter_name),
      x = "Season",
      y = "Concentration",
      color = "Status",
      shape = "Status",
      fill = "Season"
    )
}
