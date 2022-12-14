
context("pull_pdfs")

test_that("pull_pdfs works", {

  # create temp folder
  dir.create("/Users/madeline/Desktop/temp0000000/")

  source_pop <- "https://www.cdcr.ca.gov/research/2022-weekly-total-population-reports-tpop4/"
  # put the files in temp folder
  dest_pop <- "/Users/madeline/Desktop/temp0000000/"

  # pull pdfs
  pull_pdfs(source_pop, dest_pop)
  # list PDFs in folder
  filelist <- list.files(dest_pop, pattern = ".pdf")

  # check to make sure it downloaded some PDFs
  expect_false(TRUE %in% is.na(filelist))

  # now remove the folder
  unlink("/Users/madeline/Desktop/temp0000000/", recursive = TRUE)

})
