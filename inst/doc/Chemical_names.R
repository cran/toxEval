## ----setup, include=FALSE-----------------------------------------------------
library(toxEval)
library(dplyr)
knitr::opts_chunk$set(echo = TRUE,
                      warning = FALSE,
                      message = FALSE)

## -----------------------------------------------------------------------------
library(toxEval)
library(dplyr)
path_to_tox <- system.file("extdata", package = "toxEval")
file_name <- "OWC_data_fromSup.xlsx"

full_path <- file.path(path_to_tox, file_name)

chem_info <- readxl::read_xlsx(full_path, sheet = "Chemicals")

#remove Chemical column for demonstration:
chem_info <- chem_info[, c("CAS", "Class")]

tox_chemicals <- tox_chemicals

chem_info_with_names <- chem_info %>%
  left_join(select(tox_chemicals,
                   CAS = Substance_CASRN,
                   Chemical = Substance_Name),
            by = "CAS")

head(chem_info_with_names)


