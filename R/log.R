createLog <- function(name, target) {

}

appendLog <- function(event, name, target, format) {

  if (target == "file") {
    path <- Sys.getenv("R_RAP_CONFIG_PATH")
    if (path == "") {
      stop(paste0("There is nowhere to append the logging event. ",
                  "The environment variable R_RAP_CONFIG_PATH should be ",
                  "defined!"))
    }
    name <- paste0(name, ".", format)
    if (format == "csv") {
      doAppend <- TRUE
      doColNames <- FALSE
      if (!file.exists(file.path(path, name))) {
        doAppend <- FALSE
        doColNames <- TRUE
      }
      write.table(event, file = file.path(path, name), append = doAppend,
                col.names = doColNames, row.names = FALSE, sep = ",")
    }
    #close(con)
  } else {
    stop(paste0("Target ", target, " is not supported. ",
                "Event was not appended!"))
  }

}

createArchive <- function() {

}

archiveLog <- function() {

}

cleanArchive <- function() {

}

#' Make a log record
#'
#' Add default values and make a formatted log record
#'
#' @param content A named list of values to be logged
#' @param format String defining the format of the log record. Supported
#' values: 'json' (default)
#'
#' @return A formatted log entry
#' @export
#'
#' @examples
#' makeLogRecord(list(msg="This is a test"))

makeLogRecord <- function(content, format = "csv") {

  defaultEntries <- list(
    time = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  )

  content <- c(defaultEntries, content)

  if (format == "csv") {
    as.data.frame(content)
  } else {
    stop(paste0("Format ", format, " is not supported. Event not logged!"))
  }

}

getSessionData <- function(session) {

  list(
    user = rapbase::getUserName(session),
    name = rapbase::getUserFullName(session),
    group = rapbase::getUserGroups(session),
    role = rapbase::getUserRole(session),
    resh_id = rapbase::getUserReshId(session)
  )
}

getSessionDataRep <- function(session) {

  # for now, just re-use getSession data
  #getSessionData(session)

  # just for initial testing
  list(
    navn = "Are",
    status = "lur"
  )
}

appLogger <- function(session, msg = "No message provided") {

  name <- "appLog"
  content <- c(getSessionDataRep(list()), list(msg=msg))
  event <- makeLogRecord(content, format = "csv")
  appendLog(event, name, target = "file", format = "csv")

}

repLogger <- function(session, msg = "No message provided") {

  name <- "reportLog"


}
