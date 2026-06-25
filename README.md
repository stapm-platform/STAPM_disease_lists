# STAPM Disease List

The canonical list of health conditions used in the **Sheffield Tobacco and
Alcohol Policy Model (STAPM)**, with their ICD-10 code definitions and the
exposure(s) — tobacco and/or alcohol — each condition is attributable to, plus
R code that validates the list and renders it to a formatted Word document.

The disease list lives in CSV form (which version-controls and diffs cleanly).
Everything else — the Word document, the data-quality checks — is generated
from it, so a new condition or a changed definition flows through
automatically: edit the CSV, re-render.

## Scope: what lives here vs. in tobalcepi

This repository is the **master home for the disease definitions themselves** —
the conditions, their groupings, and their ICD-10 codes. It deliberately
contains *no* risk functions.

The relative risks and how they are applied stay in the
[**tobalcepi**](https://github.com/stapm-platform/tobalcepi) R package, which computes
the relative risks and population attributable fractions of diseases related to
tobacco and alcohol. The split is:

| Concern | Home |
| --- | --- |
| Which conditions are in scope, their ICD-10 definitions, groupings, exposure flags | **this repository** |
| Relative-risk functions, dose-response curves, how risk is applied to individuals, PAFs | **tobalcepi** |

Previously the disease list was distributed *inside* tobalcepi. That earlier
copy (version 1.0.0) remains publicly available and unchanged on OSF, embedded
with the tobalcepi package: <https://osf.io/xq8mv/files/v6zxq>. Separating the
definitions into this repository lets the disease list be maintained, reviewed
and versioned on its own, independently of the risk-function code that consumes
it.

## Repository layout

```
.
├── lists/                          versioned disease lists (the data)
│   ├── stapm_disease_list_v1_0_0.csv   v1.0.0 (the 2022 published list)
│   ├── stapm_disease_list_v2_0_0.csv   v2.0.0 (current)
│   └── README.md                       naming convention
├── R/
│   ├── disease_list.R              read / validate / overlap-check / version utils (base R)
│   └── build.R                     render a list to Word
├── reports/
│   └── disease_list_report.Rmd     the Word template (parameterised by list version)
├── scripts/
│   ├── setup.R                     install the render packages
│   └── build_word_document.R       command-line entry point
├── output/                         generated .docx (git-ignored)
├── CHANGELOG.md
└── README.md
```

## Quick start

```r
# one-off: install the packages needed to render Word (reading/validating needs none)
source("scripts/setup.R")

# build the Word document from the latest list
source("R/build.R")
build_word_document()
```

Or from a terminal, at the repository root:

```bash
Rscript scripts/build_word_document.R            # latest version
Rscript scripts/build_word_document.R v2.0.0     # a specific version
```

The document is written to `output/stapm_disease_list_<version>.docx`.

> Run the scripts **from the repository root** so relative paths resolve. The
> render needs **pandoc** (bundled with RStudio, or install the system package).

## Working with the list

`read_disease_list()`, `validate_disease_list()` and `find_overlaps()` are plain
base R — no packages required — so you can check a list in any session:

```r
source("R/disease_list.R")
df <- read_disease_list(resolve_disease_list("v2.0.0"))
validate_disease_list(df)     # reports blanks, duplicates, and ICD-10 overlaps
```

`validate_disease_list()` runs an ICD-10 **overlap check** that respects the
code hierarchy (a three-character code contains its four-character children) and
`(excluding ...)` clauses. This is the check that catches double-counting — a
record that would fall under two conditions at once.

### The data file

One row per condition, with columns:

| Column | Meaning |
| --- | --- |
| `tobacco-related` | `x` if in the tobacco list, blank otherwise. |
| `alcohol-related` | `x` if in the alcohol list, blank otherwise. |
| `disease_type` | Grouping (e.g. *Cancers*, *Wholly attributable to alcohol*). |
| `Disease category name` | The condition's name. |
| `ICD-10 codes` | The codes that define the condition (conventions below). |

### ICD-10 code conventions

- Codes are comma-separated and written **without the decimal point**
  (`F502` = F50.2).
- A three-character code covers the whole block (`C50` = C50.0-C50.9).
- An `(excluding XXX)` clause carves codes out of a category.
- An `X` suffix (`K85X`) denotes the source data's unspecified
  fourth-character convention. It appears in v2.0.0; the v1.0.0 list does not
  use it.

## Versions

Each released list is a file in `lists/` named for its version (see
`lists/README.md`), and is tagged as a **GitHub Release** so it can always be
retrieved exactly. `CHANGELOG.md` records what changed and why. Because versions
are separate files, several can be active at once and the code is pointed at
whichever a piece of analysis needs.

Two versions are currently in the repository:

- **v2.0.0** — current. 94 conditions. Passes validation with no ICD-10
  overlaps.
- **v1.0.0** — the list published in 2022 (also on OSF, see above). 85 rows /
  84 conditions, in its original category structure. The validator reports one
  "overlap" on v1.0.0 — oesophageal adenocarcinoma and squamous cell carcinoma
  both map to C15 by design (same code, different risk functions), so this is
  expected, not a fault.

## Proposing a change

1. Open an **issue** describing the change (condition, codes, source).
2. Edit the CSV on a **branch**; small fixes can be made in the GitHub web
   editor. Update `CHANGELOG.md` under `[Unreleased]` in the same PR.
3. The validator (in `R/disease_list.R`) will flag any new ICD-10 overlap.
4. A maintainer reviews and merges. Changes that affect results are tagged as a
   new release and saved as a new `lists/` file.

## Provenance

Descends from: Gillespie, D. (2022). *Health conditions in the Sheffield Tobacco
and Alcohol Policy Model and sources for risk functions*, Version 1.0.0,
University of Sheffield (CC-BY 4.0), published with the tobalcepi package and
available at <https://osf.io/xq8mv/files/v6zxq>. The current list (v2.0.0)
extends that reference; see `CHANGELOG.md`.

The risk-function sources cited against each condition in the 2022 reference now
live with the risk functions in tobalcepi, not here.

## Licence

The word documents for the disease lists have a CC-BY 4.0 licence and the code in this repo has a GPLv3 licence.

## Maintainers

Duncan Gillespie duncan.gillespie@sheffield.ac.uk
