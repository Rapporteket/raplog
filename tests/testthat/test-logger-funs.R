context("Logging")

test_that("formatter returns error upon non-existing format", {
  expect_error(makeLogRecord(content = list(), format = "a4"))
})

test_that("formatter returns a json-class object", {
  expect_equal(class(makeLogRecord(content = list())), "json")
})

test_that("formatter returns as expected", {
  expect_match(makeLogRecord(list(foo="bar")), "\\{\"time\":\\[", all = FALSE)
})
