# raplog

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/Rapporteket/raplog.svg?branch=master)](https://travis-ci.org/Rapporteket/raplog)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/Rapporteket/raplog?branch=master&svg=true)](https://ci.appveyor.com/project/Rapporteket/raplog)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

raplog provides logging for registries and underlying reports at Rapporteket. The purpose of raplog is NOT logging of how your code works (_e.g._ for code debugging) but rather the use of reports (statistics and auditing).

## Installation

You can install the released version of raplog from [Rapporteket at GitHub](https://github.com/Rapporteket) with:

``` r
remotes::install_github("Rapporteket/raplog")
```

## Use

raplog collects information from three sources:

1. the R environment; from where and which function the call (for logging) came from,
1. the shiny session object; user details in the shiny session from where logging is requested, and
1. an optional message to be part of the log

A typical usecase will call one out of two functions in raplog; ```appLogger()``` for logging at (shiny) application level and ```repLogger()``` for logging at (single) report level.

To make a log entry when the shiny application "smerteregistert" starts, use the ```raplog::appLogger()```-function in the (shiny) server function:

```r
library(raplog)

server <- function(input, output, session) {

  raplog::appLogger(session, msg = "Smerteregisteret: starting shiny app")
  
  ...
  
}
```

This will add a record to the application log that may look like:

```csv
"time","user","name","group","role","resh_id","message"
"2019-08-12 10:55:38","ttester","Tore Tester","smerte","LU",999999,"Smerteregisteret: starting shiny app"
```

To log the use of single reports (_e.g._ figures, tables, documents) use the ```raplog::repLogger()```-function within a reactive context (in the server function):

```r
library(raplog)

server <- function(input, output, session) {

...

  output$hist <- renderPlot({
    raplog::repLogger(session, msg = "Smerteregisteret: providing histogram")
    makeHist(df = regData, var = input$var, bins = input$bins)
    ...
  })
  ...
}
```

This will add a record to the report log that may look like:

```csv
"time","user","name","group","role","resh_id","environment","call","message"
"2019-08-12 10:55:41","ttester","Tore Tester","smerteregisteret","LU",999999,"R_GlobalEnv","renderPlot(...)","Smerteregisteret: providing histogram"
```

## Improved report logging
From the last example above the log states that it was called from the ```renderPlot()```-function residing in the R global environment (```R_GlobalEnv```). The log fields _environment_ and _call_ would be much more useful if they provided more details on the actual function call that produces the report and the package (environment) that the registry belongs to. The latter would provide the oportunity to check wether the login credentials (as provided in the _user_, _name_, _group_, _role_, and _resh_id_ log fields) match the actual call for the report or not (in case we have a possible breach of confidentiality). This can be obtained by moving ```repLogger()``` from the shiny (reactive) function (```renderPlot()``` in the above example) into the function that actually produces the report (```makeHist()``` in the above example). This can be obtained by altering the ```makeHist()```-funtion allowing it to handle also the session object from shiny (which raplog requires), _e.g._:

```r
makeHist <- function(regData, var, bins, ...) {
  
  if ("session" %in% names(list(...))) {
    raplog::repLogger(session = session, msg = "Providing histogram")
  }
  ...
}
```

This will add a record to the report log that looks like:

```csv
"2019-08-12 13:04:51","ttester","Tore Tester","smerteregisteret","LU",999999,"smerteregisteret","makeHist(df = regData, var = input$var, bins = input$bins, session = session)","Providing histogram"
```

Changes to the function as suggested above will not alter the way it works in other context since the function only reacts to logging if ```session``` is found among its arguments.
