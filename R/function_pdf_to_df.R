
#' Convert PDF to a dataframe.
#'
#' `pdf_to_df()` takes a population or COMPSTAT report PDF and processes some of the data into
#' a dataframe.
#'
#' @param pdf_file A PDF file
#' @param type The type of file - can be 'compstat' or 'pop'
#'
#' @returns
#' A data frame
#'
#' @export pdf_to_df
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



# Function to convert to data frame ====================================================

pdf_to_df <- function(pdf_file, type){

if (!type == "compstat" & !type == "pop"){
    stop("invalid report type, please use 'pop' or 'compstat'")
}


# COMPSTAT -----------------------------------------------------------------------------

if (type == "compstat"){

  # extract date code from file name
  date <- substring(pdf_file, 27, 30)
  year <- paste0("20", substr(date, start = 1, stop = 2))
  mon <- substr(date, start = 3, stop = 4)
  date2 <- paste0(year, "-", mon)

  c13 <- as.Date(zoo::as.yearmon(date2, "%Y-%m"), frac = 1)

  # should simplify this still
  c1 <- c13 %m-% months(12) %>% ceiling_date(unit = "month") - 1
  c2 <- c13 %m-% months(11) %>% ceiling_date(unit = "month") - 1
  c3 <- c13 %m-% months(10) %>% ceiling_date(unit = "month") - 1
  c4 <- c13 %m-% months(9) %>% ceiling_date(unit = "month") - 1
  c5 <- c13 %m-% months(8) %>% ceiling_date(unit = "month") - 1
  c6 <- c13 %m-% months(7) %>% ceiling_date(unit = "month") - 1
  c7 <- c13 %m-% months(6) %>% ceiling_date(unit = "month") - 1
  c8 <- c13 %m-% months(5) %>% ceiling_date(unit = "month") - 1
  c9 <- c13 %m-% months(4) %>% ceiling_date(unit = "month") - 1
  c10 <- c13 %m-% months(3) %>% ceiling_date(unit = "month") - 1
  c11 <- c13 %m-% months(2) %>% ceiling_date(unit = "month") - 1
  c12 <- c13 %m-% months(1) %>% ceiling_date(unit = "month") - 1


  # read the pdf file
  got_txt <- pdf_text(here::here("data", "raw", "compstat_reports", pdf_file)) %>%
    readr::read_lines()

  # extract text from the lines I want
  dat_txt1 <- got_txt[c(10, 11)] %>%
    # remove the commas in numbers
    str_replace_all(",","")

  list1 <- str_split(dat_txt1, "  ")
  dat1 <- plyr::ldply(list1, function(l){
    chars <- unlist(l)
    chars2 <- chars[which(nchar(chars) > 0)]
    return(chars2)
  })

  dat1 <- dat1 %>%
    pivot_longer(cols = c(V2:V14), names_to = "month", values_to = "value") %>%
    mutate(month = case_when(
             month == "V2" ~ c1,
             month == "V3" ~ c2,
             month == "V4" ~ c3,
             month == "V5" ~ c4,
             month == "V6" ~ c5,
             month == "V7" ~ c6,
             month == "V8" ~ c7,
             month == "V9" ~ c8,
             month == "V10" ~ c9,
             month == "V11" ~ c10,
             month == "V12" ~ c11,
             month == "V13" ~ c12,
             month == "V14" ~ c13))

  # remove leading and trailing white space
  dat1$value <- trimws(dat1$value, which = "both")

# POP  ---------------------------------------------------------------------------------

} else if (type == "pop"){

  # extract date code from file name
  date <- substring(pdf_file, 8, 13)
  # convert to date (print to test)
  date <- as.Date(as.character(date),format = "%y%m%d")

  # read the pdf file
  got_txt <- pdf_text(here::here("data", "raw", "pop_reports", pdf_file)) %>%
    readr::read_lines()

  # Lines where data starts and ends
  start_line1 <- which(grepl("Avenal State Prison (ASP)*", got_txt))
  end_line1 <- which(grepl("Wasco State Prison (WSP)*", got_txt))

  # extract text from the lines I want
  dat_txt1 <- got_txt[start_line1:end_line1] %>%
    # remove the commas in numbers
    str_replace_all(",","")

  # locate the second number
  sn <- regexpr("\\D+\\S+\\D+", dat_txt1)
  # get the position of second number
  p <- attr(sn, "match.length")
  # P between 100 and 102 will be NB

  # turn text to list at line breaks
  dat_txt1 <- dat_txt1 %>%
    # remove all of the extra space
    str_squish() %>%
    strsplit(split = "/n")

  # convert list to tibble
  dat1 <- dat_txt1 %>%
    map_df(~.x %>%
             map(~if(length(.)) . else NA) %>%
             do.call(what = cbind) %>%
             as_tibble)

  dat1 <- dat1 %>%
    # attach second number position
    cbind(., p) %>%
    # separate out prison name and numbers
    mutate(values = substring(V1, regexpr(")", V1) + 1),
           prison = sub("\\).*", ")", V1))


  # remove leading white space
  dat1$values <- trimws(dat1$values, which = "left")

  dat1 <- dat1 %>%
    separate(values, c("male", "female", "nb", "total"), extra = "drop", fill = "right") %>%
    # if only two numbers, shift total over to the right spot and
    mutate(total = ifelse(p >= 105, female, total),
           female = ifelse(p >= 105, 0, female),
           # if three numbers, shift total over to the right spot
           total = ifelse(!is.na(nb) & is.na(total), nb, total),
           nb = ifelse(total == nb | total == male, 0, nb),
           # if there are three numbers, make sure female or nb is in the right spot
           nb = ifelse(p >= 100 & p <= 102, female, nb),
           female = ifelse(p >= 100 & p <= 102, 0, female),
           # assign date extracted from file name
           date = date)

  # arrange in a better order
  dat1 <- dat1[, c(7, 8, 3:6)]

}

  return(dat1)

}



