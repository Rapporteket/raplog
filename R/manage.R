#' Management of shiny application and report logging at Rapporteket
#'
#' A tool to aid archiving and cleanup of logs containing data on use of shiny
#' application and reports at Rapporteket. This function is ment to be called
#' from a scheduler (\emph{e.g.} chron) directly or as part of a process chain
#' initiated by a scheduler
#'
#' @seealso To become orchestrator
#' \code{\link[rapbase:runAutoReport]{runAutoReport}} in package \emph{rapbase}
#'
#' @return Silently exits after successful file operations
#' @export
#'
#' @examples
#' \donttest{
#' # Depend on the R_RAP_CONFIG_PATH being defined and that relevant
#' # configuration is present
#' raplogManager()
#' }

raplogManager <- function() {

  logPath <- Sys.getenv("R_RAP_CONFIG_PATH")
  if (logPath == "") {
    stop("No path to configuration data provided. Cannot continue!")
  }

  conf <- rapbase::getConfig(fileName = "rapbaseConfig.yml")

  archiveDir <- conf$r$raplog$archiveDir
  archivePath <- file.path(logPath, archiveDir)

  if (!dir.exists(archivePath)) {
    createArchive(archivePath)
  }

  ripeLogs <- logsOverSize(logPath)
  archiveLog(archivePath, logPath, logs = ripeLogs)

  eolDays <- conf$r$raplog$eolDays
  cleanArchive(archivePath, eolDays)
  invisible()
}
