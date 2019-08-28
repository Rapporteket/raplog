context("management")

# store current instance and prepare
currentConfig <- Sys.getenv("R_RAP_CONFIG_PATH")
Sys.setenv(R_RAP_CONFIG_PATH="")
tempdir <- tempdir()

conf <- rapbase::getConfig(fileName = "rapbaseConfig.yml")
archiveDir <- conf$r$raplog$archiveDir

test_that("error is provided when config path env var is empty", {
  expect_error(raplogManager())
})

Sys.setenv(R_RAP_CONFIG_PATH=tempdir)

logs <- c("mtcars.csv")
rio::export(mtcars, file.path(tempdir, logs))
raplogManager()

test_that("for now, just that archiveDir is created", {
  expect_true(dir.exists(file.path(tempdir, archiveDir)))
})


# Restore instance
Sys.setenv(R_RAP_CONFIG_PATH=currentConfig)
