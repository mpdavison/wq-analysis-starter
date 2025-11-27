# Water Quality Analysis Pipeline

Example project: Statistical analysis of water quality data with censored observations (non-detects).

## Quick Start

**Prerequisites:** R 4.5+

```bash
# Install dependencies
Rscript install_deps.R

# Run analysis
Rscript run_analysis.R
```

Or with Docker:
```bash
docker-compose up -d
# Access RStudio at http://localhost:38788 (rstudio/rstudio)
```

## Pipeline

Sequential 4-stage workflow (each depends on the previous):

1. **Filter & Prepare** (`R/01-filter-prepare.Rmd`)
   - Parse detection limits (L-prefix), validate data
   - Output: `data/processed/filtered_data.csv`

2. **Partition** (`R/02-partition.Rmd`)
   - Test for seasonal patterns
   - Output: `data/processed/partitioned_data.rds`

3. **Analyze** (`R/03-analysis.Rmd`)
   - Apply appropriate statistical methods per decision tree
   - Methods: censored and non-censored Mann-Kendall, seasonal and non-seasonal
   - Handles both censored (left-censored non-detects) and uncensored data
   - Output: `output/tables/complete_results.csv`

4. **Report** (`R/04-report.Rmd`)
   - Generate visualizations and summaries
   - Output: `output/figures/`, `output/tables/`

## Configuration

All constants in `R/functions/analysis_constants.R`:
- `MIN_SAMPLE_SIZE` = 50
- `MAX_CENSORING_PCT` = 50
- `ALPHA` = 0.05

## Data Format

Input CSV (`data/raw/lwq-results.csv`):
- `VALUE`: Numeric or "L" prefix for non-detects (e.g., "L0.05" = <0.05)
- `SAMPLE_DATETIME`: MM/DD/YY HH:MM format
- `VARIABLE_CODE`, `VARIABLE_NAME`
- `STATION_NO`, `STATION_NAME`

## Structure

```
R/                           # Analysis scripts + functions
data/raw/                    # Input data (read-only)
data/processed/              # Generated intermediate data
output/csv,figures,tables/   # Results
```

## Key Packages

- **EnvStats** - Kendall trend tests with slope estimation (censored & uncensored data)
- **NADA/NADA2** - Censored data utilities and quantile estimation
- **Kendall** - Additional trend test utilities
- **dplyr, ggplot2, rmarkdown**

See `docs/example_workflow.dot` for decision tree logic.

---
*Example project for demonstration. Adapt for real data.*
