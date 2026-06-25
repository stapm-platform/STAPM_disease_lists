#!/usr/bin/env Rscript
# scripts/build_word_document.R
#
# Build the Word version of a disease list.
#
# Usage, from the repository root:
#   Rscript scripts/build_word_document.R            # uses the latest list
#   Rscript scripts/build_word_document.R v2.0.0     # uses a specific version
#   Rscript scripts/build_word_document.R lists/stapm_disease_list_v2.0.0.csv
#
# Inside an R session you can instead call:
#   source("R/build.R"); build_word_document()

source(file.path("R", "build.R"))

args <- commandArgs(trailingOnly = TRUE)
version <- if (length(args) >= 1L) args[[1]] else NULL

build_word_document(version = version)
