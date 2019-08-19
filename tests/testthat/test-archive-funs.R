context("archiving")

tempdir <- tempdir()

test_that("error is provided when archive dir already exists", {
  expect_error(createArchive(archivePath = tempdir))
})

test_that("an archive dir can be created", {
  expect_true(createArchive(archivePath = tempfile()))
})

test_that("error is provided when archive dir does not exist", {
  expect_error(archiveLog(archivePath = "", logPath = tempdir))
})

test_that("error is provided when log dir does not exist", {
  expect_error(archiveLog(archivePath = tempdir, logPath = ""))
})

test_that("error is provided when log files does not exixt", {
  expect_error(archiveLog(archivePath = tempdir, logPath = tempdir,
                          logs = c("foo.csv", "bar.csv")))
})


logs <- c("mtcars.csv")
rio::export(mtcars, file.path(tempdir, logs))

test_that("function silently archives...", {
  expect_silent(archiveLog(archivePath = tempdir, logPath = tempdir,
                           logs = logs))
})

test_that("...and that archive actually exists", {
  expect_true(file.exists(file.path(tempdir, "mtcars.rda")))
})

test_that("no cleaning is performed when eol is set to 0", {
  expect_null(cleanArchive(archivePath = tempdir))
})

test_that("function silently cleans...", {
  expect_silent(cleanArchive(archivePath = tempdir, eolDays = 0))
})

test_that("...and that file is actually removed", {
  expect_false(file.exists(file.path(tempdir, "mtcars.rda")))
})

