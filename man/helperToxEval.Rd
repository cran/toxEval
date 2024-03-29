% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_toxEval.R
\name{as.toxEval}
\alias{as.toxEval}
\title{toxEval helper functions}
\usage{
as.toxEval(x, ...)
}
\arguments{
\item{x}{list or toxEval object}

\item{\dots}{data frames to override data within the original x list.}
}
\description{
A small collection of helper functions for toxEval
}
\examples{
path_to_tox <- system.file("extdata", package = "toxEval")
file_name <- "OWC_data_fromSup.xlsx"
full_path <- file.path(path_to_tox, file_name)
tox_list <- create_toxEval(full_path)

# To over-ride one of the data frames:
chem_data <- data.frame(
  CAS = "21145-77-7",
  Value = 1,
  "Sample Date" = as.Date("2012-01-01"),
  SiteID = "USGS-04249000"
)
tox_list_new <- as.toxEval(tox_list, chem_data)

}
