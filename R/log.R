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
  } else {
    stop(paste0("Target ", target, " is not supported. ",
                "Event was not appended!"))
  }

}


#' Make a log record
#'
#' Add default values and make a formatted log record
#'
#' @param content A named list of values to be logged
#' @param format String defining the format of the log record. Supported
#' values: 'csv' (default)
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

  # Currently not used
}

#' Logging at application level
#'
#' To be used for logging at application level \emph{i.e.} when a shiny session
#' is started.
#'
#' @param session Shiny session object to be used for getting user data.
#' For testing and development purposes \code{session} can be replaced by
#' \code{list()} in which case various config options might be used to provide
#' something sensible
#' @param msg String providing a user defined message to be added to the log
#' record. Default value is 'No message provided'
#'
#' @return Returns nothing but calls a logging appender
#' @export
#'
#' @examples
#' \donttest{
#' # Depend on the environment variable R_RAP_CONFIG_PATH being set
#' appLogger(list())
#' }
#'
appLogger <- function(session, msg = "No message provided") {

  name <- "appLog"
  content <- c(getSessionData(session), list(message=msg))
  event <- makeLogRecord(content, format = "csv")
  appendLog(event, name, target = "file", format = "csv")

}


#' Logging at report level
#'
#' To be used for logging at report level, \emph{i.e.} each time a report is
#' run. Calls to this function can be made from reactive enviroments within the
#' shiny server function or from within the (report) functions used by the same
#' reactive environments
#'
#' @inheritParams appLogger
#' @param .topcall Parent call (if any) calling this function. Used to provide
#' the function call with arguments. Default value is \code{sys.call(-1)}
#' @param .topenv Name of the parent environment calling this function. Used to
#' provide package name (\emph{i.e.} register) this function was called from.
#' Default value is \code{parent.frame()}
#'
#' @return Returns nothing but calls a logging appender
#' @export
#'
#' @examples
#' \donttest{
#' # Depend on the environment variable R_RAP_CONFIG_PATH being set
#' repLogger(list())
#' }


repLogger <- function(session, msg = "No message provided",
                      .topcall = sys.call(-1), .topenv = parent.frame()) {

  name <- "reportLog"
  parent_environment <- environmentName(topenv(.topenv))
  parent_call <- deparse(.topcall)
  content <- c(getSessionData(session),
               list(
                 environment=parent_environment,
                 call=parent_call,
                 message=msg))
  event <- makeLogRecord(content, format = "csv")
  appendLog(event, name, target = "file", format = "csv")
}
