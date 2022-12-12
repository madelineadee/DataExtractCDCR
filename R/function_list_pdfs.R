
#' List PDF files.
#'
#' `list_pdfs` a character string file name for PDF location and lists all PDFs.
#' MUST currently be using specified file structure.
#'
#' @export list_pdfs
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


# Function to list PDF files ===========================================================

list_pdfs <- function(loc){

list.files(here::here("data", "raw", loc),
           pattern = ".pdf")

}

