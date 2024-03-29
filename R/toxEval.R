
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    paste(strwrap(paste("For more information:
https://doi-usgs.github.io/toxEval/
ToxCast database: version", dbVersion()), width = 40),
      collapse = "\n"
    )
  )
}

dbVersion <- function() {
  "3.5"
}

#' Analyze ToxCast data in relation to measured concentrations.
#'
#' \code{toxEval} includes a set of functions to analyze, visualize, and
#' organize measured concentration data as it relates to ToxCast data
#' (default) or other user-selected chemical-biological interaction
#' benchmark data such as water quality criteria. The intent of
#' these analyses is to develop a better understanding of the potential
#' biological relevance of environmental chemistry data. Results can
#' be used to prioritize which chemicals at which sites may be of
#' greatest concern. These methods are meant to be used as a screening
#' technique to predict potential for biological influence from chemicals
#' that ultimately need to be validated with direct biological assays.

#'
#' \tabular{ll}{
#' Package: \tab toxEval\cr
#' Type: \tab Package\cr
#' License: \tab Unlimited for this package, dependencies have more restrictive licensing.\cr
#' Copyright: \tab This software is in the public domain because it contains materials
#' that originally came from the United States Geological Survey, an agency of
#' the United States Department of Interior. For more information, see the
#' official USGS copyright policy at
#' https://www.usgs.gov/visual-id/credit_usgs.html#copyright\cr
#' LazyLoad: \tab yes\cr
#' }
#'
#' @name toxEval-package
#' @docType package
#' @author Laura De Cicco \email{ldecicco@@usgs.gov}. Steven Corsi
#' @keywords internal 
"_PACKAGE"

#' ACC values included with toxEval.
#'
#' Downloaded on October 2022 from ToxCast. The data were
#' combined from files in the "INVITRODB_V3_5_LEVEL5" folder.
#' At the time of toxEval package release, this information was found:
#' \url{https://www.epa.gov/comptox-tools/exploring-toxcast-data}
#' in the "ToxCast & Tox21 Data Spreadsheet" data set.
#' ACC values are the in the "ACC" column (winning model) and units are
#' log micro-Molarity (log \eqn{\mu}M).
#'
#' @references Toxicology, EPA's National Center for Computational (2020):
#' ToxCast and Tox21 Data Spreadsheet. figshare. Dataset.
#'  \doi{10.23645/epacomptox.6062479.v3}.
#'
#' @source \url{https://www.epa.gov/comptox-tools/exploring-toxcast-data}
#'
#' @aliases ToxCast_ACC
#' @return data frame with columns CAS, chnm (chemical name), flags, endPoint, and ACC (value).
#' @name ToxCast_ACC
#' @docType data
#' @export ToxCast_ACC
#' @keywords datasets
#' @examples
#' head(ToxCast_ACC)
NULL

#' Endpoint information from ToxCast
#'
#' Downloaded on October 2022 from ToxCast. The file name of the
#' raw data was "assay_annotation_information_invitrodb_v3_5.xlsx" from the zip file
#' "INVITRODB_V3_5_SUMMARY" folder. At the time
#' of the toxEval package release, these data were found at:
#' \url{https://www.epa.gov/comptox-tools/exploring-toxcast-data}
#' in the section marked "Download Assay Information", in the
#' ToxCast & Tox21 high-throughput assay information data set.
#'
#'
#' @name end_point_info
#' @aliases end_point_info
#' @docType data
#' @keywords datasets
#' @references U.S. EPA. 2014. ToxCast Assay Annotation Data User Guide.
#'
#' @source \doi{10.23645/epacomptox.6062479.v3}
#' @export end_point_info
#' @return data frame with 72 columns. The columns and definitions
#' are discussed in the "ToxCast Assay Annotation Version 1.0 Data User Guide (PDF)" (see source).
#' The column "Relevance Category" was included for consideration of 
#' grouping/filtering endpoints based on user goals.
#' @examples
#' end_point_info <- end_point_info
#' head(end_point_info[, 1:5])
NULL

#Due to size constraints for CRAN, some columns needed to be removed:
# 
# end_point_info <- end_point_info |>
#   dplyr::select(-reagent_reagent_name_value_type,
#          -reagent_reagent_name_value,
#          -citations_citation,
#          -citations_title,
#          -citations_author,
#          -assay_source_desc,
#          -assay_component_endpoint_desc)
# save(end_point_info, tox_chemicals, ToxCast_ACC, file = "sysdata.rda", compress = "xz")

#' ToxCast Chemical Information
#'
#' Downloaded from the CompTox database on October 2022.
#' \url{https://comptox.epa.gov/dashboard/}. Additional columns were
#' added based on the information from the "INVITRODB_V3_5_LEVEL5" data.
#' 
#' @return data frame with the following columns:
#' \tabular{ll}{
#' Column \tab Description \cr
#' DSSTox_Substance_Id \tab DSSTox_Substance_Id\cr
#' Substance_Name \tab Commen chemical name \cr
#' Structure_MolWt \tab Molecular weight \cr
#' DTXCID \tab DTXCID\cr
#' Substance_CASRN \tab CASRN \cr
#' INCHIKEY \tab INCHIKEY\cr
#' SMILES \tab SMILES\cr
#' Total_tested \tab Total number of ToxCast assays tested\cr
#' Active \tab Number of ToxCast assays flagged as active \cr
#' min_concentration \tab Minimum concentration tested in ToxCast (ug/L) \cr
#' max_concentration \tab Maximum concentration tested in ToxCast (ug/L) \cr
#' }
#'
#' @aliases tox_chemicals
#' @name tox_chemicals
#' @return data frame with columns:
#' "Substance_Name","Substance_CASRN",
#' "Structure_MolWt"
#' @docType data
#' @keywords datasets
#' @export tox_chemicals
#' @examples
#' head(tox_chemicals)
NULL



utils::globalVariables(c("CAS", "endPoint", "chnm", "flags", "site",
                         "Bio_category", "Class", "EAR",
                         "sumEAR", "value", "calc", "choice_calc", "nHits",
                         "Structure_MolWt", "casrn", "Substance_Name",
                         "MlWt", "ACC_value", "Substance_CASRN",
                         "Value", "Sample Date", "SiteID", "Short Name",
                         "groupCol", "Chemical", "logEAR", "meanEAR",
                         "median", "max_med", "choice_calc", "nHits",
                         "nSites", "Samples with hits", "nSamples", "hits",
                         "dec_lat", "dec_lon", "nSites", "name",
                         "nonZero", "maxEAR", "count", "site_grouping",
                         "index", "n", "x", "y", "max_med", "ymin", "label",
                         "ymax", "hit_label", "percentDet", "lab"))

