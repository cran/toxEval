## ----setup, include=FALSE---------------------------------
library(knitr)
library(rmarkdown)
options(continue=" ")
options(width=60)
knitr::opts_chunk$set(echo = TRUE,
                      warning = FALSE,
                      message = FALSE)

## ----runApp, eval=FALSE-----------------------------------
#  library(toxEval)
#  explore_endpoints()

## ----mainImage, echo=FALSE--------------------------------
knitr::include_graphics("main.png")

## ----sideImage, echo=FALSE, fig.align='right', out.extra='style="float:right; padding:10px"'----
knitr::include_graphics("sidebar.png")

## ----assayIMAGE, echo=FALSE, fig.align='right', out.extra='style="float:right; padding:10px"'----
knitr::include_graphics("assays.png")

## ----flagImage, echo=FALSE, fig.align='right', out.extra='style="float:right; padding:10px"'----
knitr::include_graphics("flags.png")

## ---------------------------------------------------------
citation(package = "toxEval")

