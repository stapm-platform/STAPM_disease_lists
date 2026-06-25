# Changelog

All notable changes to the STAPM disease list are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow semantic-style versioning (see `README.md`).

When you cut a release, move the relevant notes from `[Unreleased]` into a new
version section and set its date.

## [Unreleased]

_Nothing yet._

## [2.0.0] - YYYY-MM-DD

First release maintained in this repository (previously the list was
distributed inside the tobalcepi package). 94 conditions; passes validation
with no ICD-10 overlaps.

### Added (conditions not in v1.0.0)

- Malignant melanoma — C43, C44 *(Cancers)*
- Cardiomyopathy — A39.5, B33.2, D86.8, I40, I42 (excl. I42.6), I43, I51.4,
  I51.5 *(Cardiovascular)*
- Other_alzheimers — F00, G31.1, G31.8, G31.9 *(Mental health)*
- Peptic ulcer disease — K25-K28, K92.0-K92.2 *(Other)*
- Gallbladder diseases — K80-K83, K87 *(Other)*
- Other sexually transmitted diseases — A50-A58, A60, A63, B63, I98.0,
  K67.0-K67.2, M03.1, M73.0, M73.1, N70, N71, N73, N74 *(Partially-attributable acute)*
- HIV/AIDS — B20-B24 *(Partially-attributable acute)*
- Mental and behavioural disorders due to use of tobacco — F17
  *(Wholly attributable to tobacco)*
- Toxic effect of tobacco and nicotine — T65.2 *(Wholly attributable to tobacco)*
- Vaping-related disorder — U07.0 *(Wholly attributable to tobacco)*

### Changed

- **Groupings reorganised.** v1.0.0's attribution-based categories (*Partially
  attributable chronic/acute*, *Conditions less common among smokers*, *Wholly
  attributable to alcohol acute/chronic*) were replaced by the
  organ-system / attribution groupings used now (*Cancers*, *Cardiovascular*,
  *Mental health*, *Other*, *Respiratory*, *Partially-attributable acute*,
  *Wholly attributable to alcohol*, *Wholly attributable to tobacco or nicotine
  product use*).
- **Conditions renamed**, e.g. *Malignant neoplasm of the oral cavity* →
  *Oral cavity cancer*.
- **Oesophageal cancer merged.** v1.0.0's two subtype rows (adenocarcinoma and
  squamous cell carcinoma, both C15) became a single *Oesophageal cancer* row.
- **Attribution flags updated:** Tuberculosis is now alcohol-only (was tobacco
  and alcohol); Alzheimer's disease is now tobacco and alcohol (was
  tobacco-only); Fire injuries is now tobacco and alcohol (was alcohol-only).
- **Catch-all codes added.** The unspecified fourth-character `X` codes (K70X,
  K85X, K86X, F10X) were added to the relevant wholly-attributable and
  pancreatitis conditions.

### Fixed

- **T65.2 double-counting removed.** *Toxic effect of tobacco and nicotine*
  (T65.2) was added as its own tobacco-attributable condition, and T65.2 was
  excluded from *Accidental poisoning by exposure to noxious substances* (which
  uses the full T65 block). Without the exclusion the same record could be
  counted under both. This is the only ICD-10 overlap the validator had flagged.

## [1.0.0] - 2022-05-30

- Initial published reference: *Health conditions in the Sheffield Tobacco and
  Alcohol Policy Model and sources for risk functions* (D. Gillespie,
  University of Sheffield), released under CC-BY 4.0.
- Published with, and embedded in, the tobalcepi R package. Remains publicly
  available and unchanged at <https://osf.io/xq8mv/files/v6zxq>.
- 84 conditions (85 rows; oesophageal cancer split into two subtypes sharing
  C15). Encoded here as `lists/stapm_disease_list_v1_0_0.csv` in the
  repository's canonical CSV conventions; the original document used ICD-10
  ranges and decimal points.
