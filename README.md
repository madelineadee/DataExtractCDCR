
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DataExtractCDCR

<!-- badges: start -->
<!-- badges: end -->

The goal of the `DataExtractCDCR` package is to enable easy downloading
and processing of data that is in publicly available PDF reports on the
California Department of Corrections and Rehabilitation (CDCR) website.
This package is a work in progress, but is published on GitHub as part
of a final project for PH290: Biostatistical Computing at UC Berkeley.

The package currently includes the functions:

- `pull_pdfs`: list and download all PDF files on a CDCR webpage and put
  them in the specified directory. *NOTE: this currently only works for
  the CDCR website due to inconsitencies in links on their website that
  required cleaning*.

- `list_pdfs`: list all PDF files in the specified directory, and append
  the directory path to the beginning of each file name.

- `pdf_to_df`: convert a CDCR population report or COMPSTAT report into
  a useable dataframe. *NOTE: this currently only works on the newer
  TPOP4 population reports, or COMPSTAT reports*

  - For population reports: only population breakdown by gender identity
    and prison location is pulled.
  - For COMSTAT reports: only total incidents and use of force incidents
    at the CDCR-wide level is pulled. *There are plans to update this to
    institute specific data in the future*

## Installation

You can install the development version of `DataExtractCDCR` like so:

``` r

# install.packages("devtools")
devtools::install_github("madelineadee/DataExtractCDCR")
```

## Downloading PDFs

To download the PDFs using `pull_pdfs` you need to specify a website
with multiple PDF links, and the folder where you want the files stored
on your computer. For example:

``` r

library(DataExtractCDCR)

source_pop <- "https://www.cdcr.ca.gov/research/2022-weekly-total-population-reports-tpop4/"
dest_pop <- "/Users/madeline/Desktop/biostat-computing-final/data/raw/pop_reports/"

source_compstat <- "https://www.cdcr.ca.gov/research/compstat-incident-reports-2021-2022/"
dest_compstat <- "/Users/madeline/Desktop/biostat-computing-final/data/raw/compstat_reports/"

pull_pdfs(source_pop, dest_pop)
pull_pdfs(source_compstat, dest_compstat)
```

## List the PDFs

To use the `list_pdfs` function, you just need to specify the folder
where the PDFs are located. In this example, I am removing a couple of
PDF files that are in the wrong place on the website – future versions
of the package will hopefully address this within the `pull_pdfs`
function.

``` r

# list all of the PDF files
pdf_files_compstat <- list_pdfs(dest_compstat)
pdf_files_pop <- list_pdfs(dest_pop)

# there are some PDF files with an error, remove from processing for now
pdf_files_compstat <- pdf_files_compstat[-1]
pdf_files_pop <- pdf_files_pop[-1]
```

# Process the PDFs

To process the PDFs into a useable dataframe with the `pdf_to_df`
function, you need to specify the file (one PDF file) and the type
(either “compstat” or “pop”). This example uses lapply to use the
function on all listed pdf files and return on combined dataframe.

``` r

library(dplyr)

compstat_dat <- bind_rows(lapply(pdf_files_compstat, pdf_to_df, type = "compstat"))  %>%
  # need to remove duplicate data that is contained in multiple PDFs
  group_by(V1, month) %>%
  summarise(value = max(value))

pop_dat <- bind_rows(lapply(pdf_files_pop, pdf_to_df, type = "pop"))
```

Here is an example of what the final processed data looks like.

``` r

head(compstat_dat,n = 10)
#> # A tibble: 10 × 3
#> # Groups:   V1 [1]
#>    V1                      month      value
#>    <chr>                   <date>     <chr>
#>  1 Documented Use of Force 2021-02-28 459  
#>  2 Documented Use of Force 2021-03-31 490  
#>  3 Documented Use of Force 2021-04-30 458  
#>  4 Documented Use of Force 2021-05-31 566  
#>  5 Documented Use of Force 2021-06-30 526  
#>  6 Documented Use of Force 2021-07-31 557  
#>  7 Documented Use of Force 2021-08-31 503  
#>  8 Documented Use of Force 2021-09-30 508  
#>  9 Documented Use of Force 2021-10-31 549  
#> 10 Documented Use of Force 2021-11-30 553
head(pop_dat, n = 10)
#>                                               prison       date male female nb
#> 1                          Avenal State Prison (ASP) 2022-01-05 3840      0  0
#> 2                      Calipatria State Prison (CAL) 2022-01-05 2872      0  0
#> 3               California Correctional Center (CCC) 2022-01-05 1648      0  0
#> 4          California Correctional Institution (CCI) 2022-01-05 3083      0  0
#> 5         Central California Women's Facility (CCWF) 2022-01-05   85   2151 51
#> 6                       Centinela State Prison (CEN) 2022-01-05 2825      0  0
#> 7  California Health Care Facility - Stockton (CHCF) 2022-01-05 2188     27  4
#> 8               California Institution for Men (CIM) 2022-01-05 2656     36  5
#> 9             California Institution for Women (CIW) 2022-01-05   57    956 19
#> 10                     California Men's Colony (CMC) 2022-01-05 3220     19  6
#>    total
#> 1   3840
#> 2   2872
#> 3   1648
#> 4   3083
#> 5   2287
#> 6   2825
#> 7   2219
#> 8   2697
#> 9   1032
#> 10  3245
```
