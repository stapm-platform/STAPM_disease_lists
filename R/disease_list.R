# R/disease_list.R
# Core processing for the STAPM disease list.
#
# These functions are deliberately base-R only (no package dependencies) so that
# reading, validation and overlap checks run in any R session. Only the Word
# document render (see R/build.R) needs extra packages.

REQUIRED_COLUMNS <- c(
  "tobacco-related", "alcohol-related",
  "disease_type", "Disease category name", "ICD-10 codes"
)

# ---- Reading -----------------------------------------------------------------

#' Read a disease list CSV into a data frame.
#'
#' @param path Path to a CSV in the `lists/` folder.
#' @return A data frame with the original column names preserved.
read_disease_list <- function(path) {
  if (!file.exists(path)) stop("List file not found: ", path)
  df <- utils::read.csv(
    path,
    check.names = FALSE,      # keep "ICD-10 codes" etc. exactly as written
    colClasses = "character",
    na.strings = character(0) # keep blanks as "" rather than NA
  )
  missing <- setdiff(REQUIRED_COLUMNS, names(df))
  if (length(missing)) {
    stop("List is missing required column(s): ", paste(missing, collapse = ", "))
  }
  df
}

# ---- ICD-10 helpers ----------------------------------------------------------

# Normalise a vector of code tokens: strip dots/spaces, upper-case.
.norm_codes <- function(x) {
  x <- toupper(gsub("[.[:space:]]", "", x))
  x[nzchar(x)]
}

# Split a raw "ICD-10 codes" cell into included and excluded code sets,
# honouring an "(excluding ...)" clause.
.icd_tokens <- function(raw) {
  excluded <- character(0)
  m <- regmatches(raw, regexpr("\\(excluding[^)]*\\)", raw, ignore.case = TRUE))
  if (length(m) == 1L && nzchar(m)) {
    inside  <- sub("\\)$", "", sub("\\(excluding\\s*", "", m, ignore.case = TRUE))
    excluded <- .norm_codes(strsplit(inside, "[,[:space:]]+")[[1]])
    raw <- sub("\\(excluding[^)]*\\)", "", raw, ignore.case = TRUE)
  }
  included <- .norm_codes(strsplit(raw, ",")[[1]])
  list(included = included, excluded = excluded)
}

# Two code prefixes share code-space iff one is a prefix of the other
# (e.g. "T65" contains "T652").
.prefix_overlap <- function(a, b) startsWith(a, b) || startsWith(b, a)

# ---- Overlap detection -------------------------------------------------------

#' Find pairs of conditions whose ICD-10 codes overlap.
#'
#' Uses ICD-10 hierarchy: a 3-character code contains its 4-character children.
#' "(excluding ...)" clauses are respected, so deliberately carved-out codes
#' (e.g. I42.6 excluded from Cardiomyopathy) are not reported.
#'
#' @return A data frame of overlapping pairs (possibly zero rows).
find_overlaps <- function(df) {
  tok <- lapply(df[["ICD-10 codes"]], .icd_tokens)
  names_ <- df[["Disease category name"]]
  out <- list()
  n <- nrow(df)
  if (n >= 2L) for (i in seq_len(n - 1L)) for (j in (i + 1L):n) {
    a <- tok[[i]]; b <- tok[[j]]
    shared <- character(0)
    for (x in a$included) for (y in b$included) {
      if (!.prefix_overlap(x, y)) next
      root <- if (nchar(x) >= nchar(y)) x else y   # intersection = more specific
      if (length(a$excluded) && any(startsWith(root, a$excluded))) next
      if (length(b$excluded) && any(startsWith(root, b$excluded))) next
      shared <- c(shared, root)
    }
    if (length(shared)) {
      out[[length(out) + 1L]] <- data.frame(
        disease_a    = names_[i],
        disease_b    = names_[j],
        shared_codes = paste(sort(unique(shared)), collapse = ", "),
        stringsAsFactors = FALSE
      )
    }
  }
  if (length(out)) do.call(rbind, out) else
    data.frame(disease_a = character(), disease_b = character(),
               shared_codes = character(), stringsAsFactors = FALSE)
}

# ---- Validation --------------------------------------------------------------

#' Validate a disease list and report problems.
#'
#' Checks structure, blank fields, duplicate condition names, plausible ICD-10
#' token format, and within-list ICD-10 overlaps.
#'
#' @param df A data frame from `read_disease_list()`.
#' @param error_on_overlap If TRUE, stop on overlaps; otherwise warn.
#' @return Invisibly, a list of findings.
validate_disease_list <- function(df, error_on_overlap = FALSE) {
  problems <- character(0)
  notes    <- character(0)

  # blank required fields
  blank_name  <- which(!nzchar(trimws(df[["Disease category name"]])))
  blank_codes <- which(!nzchar(trimws(df[["ICD-10 codes"]])))
  if (length(blank_name))  problems <- c(problems,
    sprintf("%d row(s) with a blank condition name.", length(blank_name)))
  if (length(blank_codes)) problems <- c(problems,
    sprintf("%d row(s) with blank ICD-10 codes.", length(blank_codes)))

  # duplicate condition names
  dups <- df[["Disease category name"]][duplicated(df[["Disease category name"]])]
  if (length(dups)) notes <- c(notes,
    sprintf("Duplicate condition name(s): %s", paste(unique(dups), collapse = ", ")))

  # plausible ICD-10 token format (letter + >=2 chars), allowing an X suffix
  bad_tokens <- character(0)
  for (i in seq_len(nrow(df))) {
    toks <- .icd_tokens(df[["ICD-10 codes"]][i])$included
    bad  <- toks[!grepl("^[A-Z][0-9][0-9A-Z]+$", toks)]
    if (length(bad)) bad_tokens <- c(bad_tokens, bad)
  }
  if (length(bad_tokens)) notes <- c(notes,
    sprintf("Unusual code token(s) to check: %s",
            paste(sort(unique(bad_tokens)), collapse = ", ")))

  # overlaps
  ov <- find_overlaps(df)

  # report
  message(sprintf("Validation: %d conditions across %d groups.",
                  nrow(df), length(unique(df[["disease_type"]]))))
  if (length(problems)) {
    for (p in problems) message("  ERROR: ", p)
  } else message("  Structure OK.")
  for (n in notes) message("  NOTE: ", n)
  if (nrow(ov)) {
    message(sprintf("  OVERLAP: %d overlapping pair(s):", nrow(ov)))
    for (k in seq_len(nrow(ov))) {
      message(sprintf("    - '%s' <> '%s' share %s",
                      ov$disease_a[k], ov$disease_b[k], ov$shared_codes[k]))
    }
    if (error_on_overlap) stop("ICD-10 overlaps detected (see messages above).")
  } else message("  No ICD-10 overlaps.")

  if (length(problems)) stop("List failed validation (see messages above).")
  invisible(list(problems = problems, notes = notes, overlaps = ov))
}

# ---- List discovery & version resolution -------------------------------------

# Expected filename pattern: stapm_disease_list_v<MAJOR>_<MINOR>_<PATCH>[-tag].csv
# Separators may be underscores (preferred) or dots; both are accepted.
.LIST_PATTERN <- "^stapm_disease_list_v([0-9]+)[._]([0-9]+)[._]([0-9]+)(-[0-9A-Za-z.]+)?\\.csv$"

# Display versions in dotted SemVer form (v1.0.0) regardless of filename style.
.version_from_filename <- function(fname) {
  m <- regmatches(fname, regexec(.LIST_PATTERN, fname))[[1]]
  if (length(m) == 0L) return(NA_character_)
  sprintf("v%s.%s.%s%s", m[2], m[3], m[4], ifelse(is.na(m[5]) || m[5] == "", "", m[5]))
}

# A sortable numeric key; pre-release tags (with "-") sort below their release.
.version_key <- function(fname) {
  m <- regmatches(fname, regexec(.LIST_PATTERN, fname))[[1]]
  if (length(m) == 0L) return(-Inf)
  base <- as.numeric(m[2]) * 1e6 + as.numeric(m[3]) * 1e3 + as.numeric(m[4])
  if (!is.na(m[5]) && nzchar(m[5])) base - 0.5 else base
}

#' List the available disease-list files and their versions.
list_disease_lists <- function(dir = "lists") {
  files <- list.files(dir, pattern = "\\.csv$", full.names = FALSE)
  files <- files[grepl(.LIST_PATTERN, files)]
  if (!length(files)) return(data.frame(
    file = character(), version = character(), path = character(),
    stringsAsFactors = FALSE))
  df <- data.frame(
    file    = files,
    version = vapply(files, .version_from_filename, character(1)),
    path    = file.path(dir, files),
    key     = vapply(files, .version_key, numeric(1)),
    stringsAsFactors = FALSE
  )
  df <- df[order(-df$key), c("file", "version", "path")]
  rownames(df) <- NULL
  df
}

#' Resolve a list to a concrete file path.
#'
#' @param version Either NULL (use the highest version), a version string such
#'   as "v2.0.0", or a full path to a CSV.
#' @param dir The lists directory.
resolve_disease_list <- function(version = NULL, dir = "lists") {
  if (!is.null(version) && file.exists(version)) return(version)  # full path given
  available <- list_disease_lists(dir)
  if (nrow(available) == 0L) stop("No disease lists found in: ", dir)
  if (is.null(version)) return(available$path[1])                 # highest version
  # accept "v2.0.0" or "v2_0_0"
  want <- gsub("_", ".", version)
  hit <- available$path[available$version == want]
  if (!length(hit)) {
    stop("Version '", version, "' not found. Available: ",
         paste(available$version, collapse = ", "))
  }
  hit[1]
}
