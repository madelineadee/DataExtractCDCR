
context("list_pdfs")
library(stringr)

test_that("list_pdfs works", {

  # create temp folder
  dir.create("/Users/madeline/Desktop/temp0000000/")

  source_pop <- "https://www.cdcr.ca.gov/research/2022-weekly-total-population-reports-tpop4/"
  # put the files in temp folder
  dest_pop <- "/Users/madeline/Desktop/temp0000000/"

  # pull pdfs
  pull_pdfs(source_pop, dest_pop)
  # use function
  filelist <- list_pdfs(dest_pop)

  ispdf <- str_detect(filelist, ".pdf")

  # check to make sure it listed something
  expect_false(TRUE %in% is.na(filelist))
  # check that it only listed pdfs
  expect_false(FALSE %in% ispdf)

  # now remove the folder
  unlink("/Users/madeline/Desktop/temp0000000/", recursive = TRUE)

})
