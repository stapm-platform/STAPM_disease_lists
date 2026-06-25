#!/usr/bin/env Rscript
# scripts/setup.R
# Install the packages needed to render the Word document.
# Reading and validating a list (R/disease_list.R) needs no packages.

pkgs <- c("rmarkdown", "knitr", "flextable", "officer")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing)) {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing)
} else {
  message("All render packages already installed.")
}

# Rendering also needs pandoc. RStudio bundles it; otherwise install the
# system 'pandoc' package, or run rmarkdown::find_pandoc() to check.
if (rmarkdown::pandoc_available()) {
  message("pandoc found: ", rmarkdown::pandoc_version())
} else {
  message("pandoc NOT found - install it (https://pandoc.org) or use RStudio.")
}
