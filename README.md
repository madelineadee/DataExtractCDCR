
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DataExtractCDCR

<!-- badges: start -->
<!-- badges: end -->

The goal of DataExtractCDCR is to enable the user to pull PDFs of data
from the California Department of Corrections and Rehabilitation (CDCR)
website, and convert that data to useable dataframes and files within R.

## Installation

You can install the development version of DataExtractCDCR like so:

``` r
# install.packages("devtools")
devtools::install_github("madelineadee/DataExtractCDCR")
```

## Downloading PDFs

``` r

library(DataExtractCDCR)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
#> ✔ tibble  3.1.7     ✔ dplyr   1.0.9
#> ✔ tidyr   1.2.0     ✔ stringr 1.4.0
#> ✔ readr   2.1.2     ✔ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()

# Pull the PDFs ========================================================================

source_pop <- "https://www.cdcr.ca.gov/research/2022-weekly-total-population-reports-tpop4/"
dest_pop <- "/Users/madeline/Desktop/biostat-computing-final/data/raw/pop_reports/"

source_compstat <- "https://www.cdcr.ca.gov/research/compstat-incident-reports-2021-2022/"
dest_compstat <- "/Users/madeline/Desktop/biostat-computing-final/data/raw/compstat_reports/"

pull_pdfs(source_pop, dest_pop)
pull_pdfs(source_compstat, dest_compstat)
```

## List the PDFs and Process

``` r

# list all of the PDF files
pdf_files_compstat <- list_pdfs(dest_compstat)
pdf_files_pop <- list_pdfs(dest_pop)

# there are some PDF files with an error, remove from processing for now
pdf_files_compstat <- pdf_files_compstat[-1]
pdf_files_pop <- pdf_files_pop[-1]

compstat_dat <- bind_rows(lapply(pdf_files_compstat, pdf_to_df, type = "compstat"))  %>%
  # need to remove duplicate data that is contained in multiple PDFs
  group_by(V1, month) %>%
  summarise(value = max(value))
#> `summarise()` has grouped output by 'V1'. You can override using the `.groups`
#> argument.

pop_dat <- bind_rows(lapply(pdf_files_pop, pdf_to_df, type = "pop"))
#> Warning: The `x` argument of `as_tibble.matrix()` must have unique column names if `.name_repair` is omitted as of tibble 2.0.0.
#> Using compatibility `.name_repair`.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.


save_pop <- "/Users/madeline/Desktop/biostat-computing-final/data/processed/pop_reports/"
save_compstat <- "/Users/madeline/Desktop/biostat-computing-final/data/processed/compstat_reports/"

saveRDS(compstat_dat, 
        paste0(save_compstat, "compstat_", Sys.Date(),".rds"))

saveRDS(pop_dat, 
        paste0(save_pop, "pop_", Sys.Date(),".rds"))
```
