% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log.R
\name{logger}
\alias{logger}
\alias{appLogger}
\alias{repLogger}
\alias{subLogger}
\alias{autLogger}
\title{Log user events in shiny applications at Rapporteket}
\usage{
appLogger(session, msg = "No message provided")

repLogger(
  session,
  msg = "No message provided",
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)

subLogger(
  author,
  registryName,
  reshId,
  msg = "No message provided",
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)
}
\arguments{
\item{session}{Shiny session object to be used for getting user data.
For testing and development purposes \code{session} can be replaced by
\code{list()} in which case various config options might be used to provide
something sensible}

\item{msg}{String providing a user defined message to be added to the log
record. Default value is 'No message provided'}

\item{.topcall}{Parent call (if any) calling this function. Used to provide
the function call with arguments. Default value is \code{sys.call(-1)}}

\item{.topenv}{Name of the parent environment calling this function. Used to
provide package name (\emph{i.e.} register) this function was called from.
Default value is \code{parent.frame()}}

\item{author}{String providing author of a report. Only used for automated
subscription reports that are run outside a shiny session. Deprecated}

\item{registryName}{String providing registry name. Only used for automated
reports that are run outside a shiny session.}

\item{reshId}{String providing the organization id of the (subscription)
report author. Only used for automated reports that are run outside a shiny
session.}
}
\value{
Returns nothing but calls a logging appender
}
\description{
To be used for logging at application level (\emph{i.e.} when a shiny
session is started) or at report level (\emph{i.e.} each time a report is
run). Logging of single report events should be made from reactive
environments within the shiny server function or from within the (report)
functions used by the same reactive environments.
}
\details{
The below fields will be appended to the log, in the following order:
\enumerate{
\item \code{time}: date-time as event is logged as
\code{format(time, "\%Y-\%m-\%d \%H:\%M:\%S")}
\item \code{user}: username as found in the shiny session object or as
provided by function argument (\code{subLogger()})
\item \code{name}: full name of user as found in the shiny session object
\item \code{group}: users group membership as provided by the shiny
session object. Normally, this will correspond to the registry the user
belongs to
\item \code{role}: users role as provided by the shiny session object. Its
value will depend on whatever is delivered by the autorization provider,
but for OpenQReg registires 'LU' (local user) and 'SC' (system
coordinator) are typical values
\item \code{resh_id}: the organization id of the current user as provided
by the shiny session object
\item \code{environment}: environment from where the logger function was
called (only provided by \code{repLogger()})
\item \code{call}: function (with arguments) from where the logger was
called (only provided by \code{repLogger()})
\item message: an optional message defined as argument to the function
}

The \code{autLogger()} function is a special case to be used for automated
reports. Since such reports are run outside a reactive (shiny) context
shiny session data are not available to the logger. Hence, logging data
must be provided as arguments directly. As of rapbase version 1.12.0 logging
of automated reports are already taken care of. Hence, this function should
not be applied per registry application.
}
\note{
Pseudo code of how \code{appLogger()} may be implemented:
\preformatted{
library(shiny)
library(raplog)

server <- function(input, output, session) {
  raplog::appLogger(session, msg = "Smerteregisteret: starting shiny app")
  ...
}
}
Pseudo code on how \code{repLogger()} can be implemented as part of a
function in a reactive (shiny) context. First, this is an example of the
shiny server function with the (reactive) function \code{renderPlot()}
calling a function that provides a histogram:
\preformatted{
library(shiny)
library(raplog)

server <- function(input, output, session) {
  ...
  output$hist <- renderPlot({
    makeHist(data, var = input$var, bins = input$bins, session = session)
  })
  ...
}
} Then, logging is called within the function \code{makeHist()}:
\preformatted{
makeHist <- function(data, var, bins, ...) {

  if ("session" \%in\% names(list(...))) {
    raplog::repLogger(session = list(...)[["session"]], msg = "Providing histogram")
  }
  ...
}
}
}
\examples{
\donttest{
# Depend on the environment variable R_RAP_CONFIG_PATH being set
appLogger(list())
}
\donttest{
# Depend on the environment variable R_RAP_CONFIG_PATH being set
repLogger(list())
}
\donttest{
# Depend on the environment variable R_RAP_CONFIG_PATH being set
subLogger(author = "Rapporteket", registryName = "rapbase", reshId = "999999")
}
}
