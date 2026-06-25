# R/build.R
# Render a disease list to a formatted Word document.
#
# Requires: rmarkdown, knitr, flextable, officer, and a working pandoc
# (bundled with RStudio, or install the system `pandoc`).

source(file.path("R", "disease_list.R"))

#' Build a Word document from a disease list.
#'
#' @param version  NULL for the highest version in `lists_dir`, a version string
#'   such as "v2.0.0", or a full path to a CSV.
#' @param lists_dir  Folder holding the versioned list CSVs.
#' @param rmd  Path to the report template.
#' @param out_dir  Folder for generated documents.
#' @param project_root  Repository root; defaults to the working directory.
#'   Run this from the repository root.
#' @param error_on_overlap  If TRUE, refuse to build when overlaps are found.
#' @return (Invisibly) the path to the generated .docx.
build_word_document <- function(version = NULL,
                                lists_dir = "lists",
                                rmd = file.path("reports", "disease_list_report.Rmd"),
                                out_dir = "output",
                                project_root = getwd(),
                                error_on_overlap = FALSE) {

  # Ensure a UTF-8 ctype locale so non-ASCII data (accents, curly quotes)
  # serialises correctly. Modern R sessions are already UTF-8; this is a guard
  # for environments that default to C/POSIX.
  if (!grepl("UTF-8|utf8", Sys.getlocale("LC_CTYPE"), ignore.case = TRUE)) {
    for (loc in c("C.UTF-8", "en_US.UTF-8", "en_GB.UTF-8")) {
      if (suppressWarnings(Sys.setlocale("LC_CTYPE", loc)) != "") break
    }
  }

  for (pkg in c("rmarkdown", "flextable", "officer")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop("Package '", pkg, "' is required to render the Word document.\n",
           "Install with: install.packages(c('rmarkdown','flextable','officer'))")
    }
  }

  path <- resolve_disease_list(version, dir = file.path(project_root, lists_dir))
  ver  <- .version_from_filename(basename(path))
  message("Building from: ", path, "  (", ver, ")")

  df <- read_disease_list(path)
  validate_disease_list(df, error_on_overlap = error_on_overlap)

  out_full <- file.path(project_root, out_dir)
  if (!dir.exists(out_full)) dir.create(out_full, recursive = TRUE)
  out_file <- file.path(out_full, sprintf("stapm_disease_list_%s.docx", ver))

  rmarkdown::render(
    input         = file.path(project_root, rmd),
    output_file   = out_file,
    knit_root_dir = project_root,        # so source("R/...") and paths resolve
    params        = list(list_file = path, list_version = ver),
    envir         = new.env(parent = globalenv()),
    quiet         = TRUE
  )
  message("Word document written to: ", out_file)
  invisible(out_file)
}
