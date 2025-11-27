#!/usr/bin/env Rscript
# Run complete water quality analysis pipeline
# Executes all four stages sequentially with error handling

cat("=======================================================\n")
cat("Water Quality Analysis Pipeline - Automated Runner\n")
cat("=======================================================\n\n")

# Check working directory
if (!file.exists("R/01-filter-prepare.Rmd")) {
  stop("Error: Must run from workspace root directory")
}

# Load required package
if (!require("rmarkdown", quietly = TRUE)) {
  cat("Installing rmarkdown package...\n")
  install.packages("rmarkdown")
  library(rmarkdown)
}

# Define stages
stages <- list(
  list(
    name = "Stage 1: Data Filtering and Preparation",
    file = "R/01-filter-prepare.Rmd",
    output = "R/01-filter-prepare.html"
  ),
  list(
    name = "Stage 2: Seasonal Partitioning",
    file = "R/02-partition.Rmd",
    output = "R/02-partition.html"
  ),
  list(
    name = "Stage 3: Statistical Analysis",
    file = "R/03-analysis.Rmd",
    output = "R/03-analysis.html"
  ),
  list(
    name = "Stage 4: Reporting and Visualization",
    file = "R/04-report.Rmd",
    output = "R/04-report.html"
  )
)

# Track execution
start_time <- Sys.time()
success_count <- 0
failed_stages <- character()

# Execute each stage
for (i in seq_along(stages)) {
  stage <- stages[[i]]
  
  cat("\n")
  cat(strrep("=", 55), "\n")
  cat(sprintf("Running %s\n", stage$name))
  cat(strrep("=", 55), "\n")
  
  # Run stage
  tryCatch({
    render(
      input = stage$file,
      output_file = basename(stage$output),
      output_dir = dirname(stage$output),
      quiet = FALSE
    )
    
    success_count <- success_count + 1
    cat(sprintf("\n✓ %s completed successfully\n", stage$name))
    cat(sprintf("  Output: %s\n", stage$output))
    
  }, error = function(e) {
    failed_stages <<- c(failed_stages, stage$name)
    cat(sprintf("\n✗ %s FAILED\n", stage$name))
    cat(sprintf("  Error: %s\n", e$message))
    
    # Ask whether to continue
    if (interactive()) {
      response <- readline(prompt = "Continue to next stage? (y/n): ")
      if (tolower(response) != "y") {
        stop("Pipeline execution stopped by user")
      }
    } else {
      stop(sprintf("Pipeline failed at %s", stage$name))
    }
  })
}

# Summary
end_time <- Sys.time()
elapsed <- as.numeric(difftime(end_time, start_time, units = "mins"))

cat("\n")
cat(strrep("=", 55), "\n")
cat("PIPELINE EXECUTION SUMMARY\n")
cat(strrep("=", 55), "\n")
cat(sprintf("Total stages: %d\n", length(stages)))
cat(sprintf("Successful: %d\n", success_count))
cat(sprintf("Failed: %d\n", length(failed_stages)))
cat(sprintf("Execution time: %.1f minutes\n", elapsed))

if (length(failed_stages) > 0) {
  cat("\nFailed stages:\n")
  for (stage in failed_stages) {
    cat(sprintf("  - %s\n", stage))
  }
  cat("\n")
  quit(status = 1)
} else {
  cat("\n✓ All stages completed successfully!\n")
  cat("\nOutputs available in:\n")
  cat("  - data/processed/     (intermediate data)\n")
  cat("  - output/csv/         (results summaries)\n")
  cat("  - output/tables/      (detailed tables)\n")
  cat("  - output/figures/     (visualizations)\n")
  cat("  - R/*.html            (stage reports)\n")
  cat("\n")
}
