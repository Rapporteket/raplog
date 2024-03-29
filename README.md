# raplog <img src="man/figures/logo.svg" align="right" height="150" />

<!-- badges: start -->
[![Version](https://img.shields.io/github/v/release/rapporteket/raplog?sort=semver)](https://github.com/rapporteket/raplog/releases)
[![R build status](https://github.com/Rapporteket/raplog/workflows/R-CMD-check/badge.svg)](https://github.com/Rapporteket/raplog/actions)
[![codecov.io](https://codecov.io/github/Rapporteket/raplog/raplog.svg?branch=master)](https://codecov.io/github/Rapporteket/raplog?branch=master)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Doc](https://img.shields.io/badge/Doc--grey.svg)](https://rapporteket.github.io/raplog/)
<!-- badges: end -->

raplog provides logging for registries and underlying reports at Rapporteket. The purpose of raplog is NOT logging of how your code works (_e.g._ for code debugging) but rather the use of reports (statistics and auditing). See also the [raplog site](https://rapporteket.github.io/raplog/)

## Installation

You can install the released version of raplog from [Rapporteket at GitHub](https://github.com/Rapporteket) with:

``` r
remotes::install_github("Rapporteket/raplog")
```

## Use

raplog collects information from three sources:

1. the R environment; from where and which function the call (for logging) comes from,
1. the shiny session object; user details in the shiny session from where logging is requested, and
1. an optional message to be part of the log

A typical usecase will call one out of two functions in raplog; ```appLogger()``` for logging at the shiny application level and ```repLogger()``` for logging at the report level.

To make a log entry when the shiny application "smerteregistert" starts, use ```raplog::appLogger()``` in the shiny server function:

```r
library(shiny)
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

To log the use of single reports (_e.g._ figures, tables, documents) use ```raplog::repLogger()``` within a reactive context in the server function:

```r
library(shiny)
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
From the last example above the log states that it was called from ```renderPlot(...)``` residing in the R global environment (```R_GlobalEnv```). The log fields _environment_ and _call_ would be much more useful if they provided more details on the actual function call that produces the report and the package (environment) that the registry belongs to. The latter would provide the oportunity to check wether the login credentials (as provided in the log fields _user_, _name_, _group_, _role_, and _resh_id_) match the actual call for the report or not (in case we have a possible breach of confidentiality). This can be obtained by moving ```repLogger()``` from the shiny reactive function into the function that actually produces the report (```makeHist()``` in the above example). This can be obtained by altering ```makeHist()``` allowing it to take the session object from shiny as an argument, _e.g._:

```r
makeHist <- function(regData, var, bins, ...) {
  
  if ("session" %in% names(list(...))) {
    raplog::repLogger(session = list(...)[["session"]], msg = "Providing histogram")
  }
  ...
}
```

This will add a record to the report log that looks like:

```csv
"2019-08-12 13:04:51","ttester","Tore Tester","smerteregisteret","LU",999999,"smerteregisteret","makeHist(df = regData, var = input$var, bins = input$bins, session = session)","Providing histogram"
```

Changes to the function as suggested above will not alter the way it works in other context since the function only reacts to logging if ```session``` is found among its arguments.
