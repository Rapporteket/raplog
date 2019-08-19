#' Archive functions
#'
#' @param archivePath
#' @param logPath
#' @param logs
#' @param eolDays
#' @param pattern
#'
#' @name archive
#' @aliases createArchive archiveLog cleanArchive
#'
NULL


#' @rdname archive
#' @export
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
archiveLog <- function(archivePath, logPath,
                       logs = c("appLog.csv", "repLog.csv")) {

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
