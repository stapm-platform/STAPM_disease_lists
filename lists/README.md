# Disease lists

This folder holds the versioned disease lists. More than one version can live
here at once; the code can be pointed at whichever you need.

Currently present:

- `stapm_disease_list_v2_0_0.csv` — v2.0.0 (current)
- `stapm_disease_list_v1_0_0.csv` — v1.0.0 (the 2022 published list; also on
  OSF at <https://osf.io/xq8mv/files/v6zxq>)

## File naming convention

```
stapm_disease_list_v<MAJOR>_<MINOR>_<PATCH>.csv
```

For example: `stapm_disease_list_v2_0_0.csv`

- The version in the filename matches the git tag / GitHub Release and the
  entry in `../CHANGELOG.md` — one identity for each version, three places it
  appears. (The version is shown in dotted form, e.g. v2.0.0, in tags, the
  changelog and generated documents; the filename uses underscores because they
  are safer in filenames than dots before the extension.)
- Bump **MAJOR** when conditions are added/removed or ICD-10 definitions change
  in a way that affects results; **MINOR** for coding clarifications that don't
  change which records are captured; **PATCH** for typos/formatting.
- Work in progress can use a pre-release suffix, e.g.
  `stapm_disease_list_v3_0_0-draft.csv`. The tooling sorts pre-releases below
  their final release, so a `-draft` is never picked as "latest" by accident.

The tooling accepts either underscores or dots as separators, so older
dot-named files (`stapm_disease_list_v2.0.0.csv`) are still discovered. The date
is deliberately not in the filename: the version is the single source of truth,
and the date lives in `../CHANGELOG.md` and the git history.

## Pointing the code at a list

```r
source("R/build.R")
build_word_document()              # uses the highest version here
build_word_document("v2.0.0")      # a specific version (dots or underscores)
```
