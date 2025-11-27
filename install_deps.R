#!/usr/bin/env Rscript
# Install missing dependencies

# lib <- '/workspace/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu'
# .libPaths(lib)

pkgs <- c('lubridate', 'readr', 'stringr', 'tidyr', 'forcats', 'ggplot2', 
          'rmarkdown', 'knitr', 'cenGAM', 'Kendall', 'tzdb', 'dplyr', 'NADA2',
          'vroom', 'coin', 'survminer', 'ggpubr', 'purrr', 'rstatix', 'car',
          'survMisc', 'rlang')

for (pkg in pkgs) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, repos = 'https://cloud.r-project.org', 
                     dependencies = FALSE, quiet = FALSE)
  } else {
    cat(pkg, "already installed\n")
  }
}

cat("\n=== Testing key packages ===\n")
library(dplyr)
library(lubridate)
library(NADA)
cat("SUCCESS: Core packages loaded\n")
