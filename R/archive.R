#' Archive functions for logs at Rapporteket
#'
#' Functions to manage archiving of logs at Rapporteket. To be applied mainly
#' as helpers within the raplog package.
#'
#' @param archivePath String providing the path to the archive directory
#' @param logPath String providing the path to the log directory
#' @param logs String vector defining the log file names. Defaults to
#' \code{c("appLog.csv", "reportLog.csv")}
#' @param eolDays Integer age in days definig archive file end-of-life. When
#' \code{eoldays < 0} no archive files will be deleted. Default value is -1
#' @param pattern String regexp defining file name pattern. Defaults to ".rda$"
#'
#' @name archive
#' @aliases createArchive archiveLog cleanArchive
#'
NULL


#' @rdname archive
#' @export
#' @examples
#' # Create an archive
#' createArchive(archivePath = tempfile())
#'

createArchive <- function(archivePath) {

  if (dir.exists(archivePath)) {
    stop(paste0("The directory '", archivePath, "' already exists. ",
                "You can't make me overwrite!"))
  } else {
    dir.create(archivePath)
  }
}


#' @rdname archive
#' @export
#' @examples
#' # Archive a file under the same directory
#' fileName <- paste0(tempfile(), ".csv")
#' file.create(fileName)
#' write.csv(mtcars, fileName)
#' archiveLog(archivePath = dirname(fileName), logPath = dirname(fileName),
#' logs = c(basename(fileName)))
#'

archiveLog <- function(archivePath, logPath,
                       logs = c("appLog.csv", "reportLog.csv")) {

  if (!dir.exists(archivePath)) {
    stop(paste0("Got '", archivePath, "' as target archive directory, ",
                "but it does not exist. Cannot ",
                "make anything sensible from that!"))
  }
  if (!dir.exists(logPath)) {
    stop(paste0("I'm told to archive logs from '", logPath, "', but it ",
                "does not exist. Out of options here!"))
  }
  if (!all(file.exists(file.path(logPath, logs)))) {
    stop(paste0("Some or all of the log files provided (",
                paste(logs, collapse = ", "), ") does not exist. That is ",
                "fishy and I refuse to continue archiving!"))
  }

  in_file <- file.path(logPath, logs)
  out_file <- file.path(archivePath,
                        paste0(tools::file_path_sans_ext(logs), ".rda"))
  mapply(rio::convert, in_file, out_file)

}


#' @rdname archive
#' @export
#' @examples
#' # Do not delete any files
#' cleanArchive(archivePath = tempdir())
#'

cleanArchive <- function(archivePath, eolDays = -1, pattern = ".rda$") {

  if (eolDays == -1) {
    return(NULL)
  } else {
    files <- file.info(list.files(archivePath, pattern = pattern,
                                  full.names = TRUE))
    rmFiles <- rownames(files[difftime(Sys.time(), files[, "mtime"],
                                       units = "days") > eolDays, ])
    file.remove(rmFiles)
  }

}
