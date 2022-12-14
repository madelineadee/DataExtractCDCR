

context("pdf_to_df")

test_that("pdf_to_df works", {

  # create temp folder
  dir.create("/Users/madeline/Desktop/temp0000000/")

  source_pop <- "https://www.cdcr.ca.gov/research/2022-weekly-total-population-reports-tpop4/"
  # put the files in temp folder
  dest_pop <- "/Users/madeline/Desktop/temp0000000/"

  # pull pdfs
  pull_pdfs(source_pop, dest_pop)
  # list pdfs
  filelist <- list_pdfs(dest_pop)

  # use function
  df <- pdf_to_df(filelist[1], type = "pop")

  names <- c("prison", "date", "male", "female", "nb", "total")

  # test that df has the right names
  expect_equal(names(df), names)

  # now remove the folder
  unlink("/Users/madeline/Desktop/temp0000000/", recursive = TRUE)

})
