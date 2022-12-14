
#' Pull PDFs from CDCR website.
#'
#'
#' `pull_pdfs()` take a URL from the CDCR website, and extracts all PDFs linked from that
#' page of the website. Currently only works for TPOP4 population reports and COMPSTAT reports.

#' @param source A URL character string for population or COMPSTAT reports main page from CDCR
#' @param dest A file path character string for where to store the files on your machine
#'
#' @returns
#' Nothing, but PDFs are saved
#'
#'
#' @export pull_pdfs
#'
#'
#' @importFrom rvest read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom stringr str_subset
#' @importFrom stringr str_c
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_squish
#' @importFrom utils download.file
#' @importFrom zoo as.yearmon
#' @importFrom lubridate ceiling_date
#' @importFrom lubridate %m-%
#' @importFrom magrittr %>%
#' @importFrom here here
#' @importFrom readr read_lines
#' @importFrom dplyr case_when
#' @importFrom dplyr mutate
#' @importFrom tidyr pivot_longer
#' @importFrom pdftools pdf_text
#' @importFrom purrr map_df
#' @importFrom purrr map
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#'
#'

# Function to pull PDFs ================================================================

pull_pdfs <- function(source, dest) {

  page <- read_html(source)

  # retrieve URLs of PDF files for download
  raw_list <- page %>% # takes the page above for which we've read the html
    html_nodes("a") %>%  # find all links in the page
    html_attr("href") %>% # get the url for these links
    str_subset("\\.pdf")

  # remove the portion of the URL that is inconsistent
  raw_list <- gsub("https://www.cdcr.ca.gov", "", raw_list)

  # create full URLs
  raw_list <- raw_list %>%
    str_c("https://www.cdcr.ca.gov", .)

  for (url in raw_list){
    download.file(url, destfile = paste0(dest, basename(url)), mode = "wb")
  }

}

