% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_toxEval.R
\name{summary.toxEval}
\alias{summary.toxEval}
\title{Summary of tox_list}
\usage{
\method{summary}{toxEval}(object, ...)
}
\arguments{
\item{object}{toxEval object with "chem_info" data frame included.}

\item{\dots}{additional parameters}
}
\description{
A "tox_list" object is created from \code{create_toxEval}. It
is a list of  5 data frames: chem_data, chem_info,
chem_site, exclusions, and benchmarks. This function returns
a message with how many chemicals have ToxCast information,
and returns a vector of which chemicals do not have ToxCast information.
}
\examples{
path_to_tox <- system.file("extdata", package = "toxEval")
file_name <- "OWC_data_fromSup.xlsx"
excel_file_path <- file.path(path_to_tox, file_name)
tox_list <- create_toxEval(excel_file_path)
summary(tox_list)
}
