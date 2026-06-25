# Changelog

All changes to the STAPM disease list are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow semantic-style versioning (see `README.md`).


## [2.0.0] - 25/06/2026

Contributors: Duncan Gillespie, Abi Stevely, Colin Angus  

First version maintained in this repository (previously the list was
distributed inside the tobalcepi package). 94 conditions
with no ICD-10 overlaps.

The alcohol related conditions were reviewed based on Carr et al. 2026 (https://doi.org/10.1111/add.70435).  

Tobacco related conditions were reviewed based on 
Reitsma et al. 2021 (https://doi.org/10.1016/S0140-6736(21)01169-7), 
Dai et al. 2022 (https://doi.org/10.1038/s41591-022-01978-x), and the 2018 Royal College of Physicians report, "Hiding in Plain Sight". 

Some ICD-10 codes wholly attributable to tobacco and vaping were also added in.  

Consistency has been maintained with v1 of the disease list - 
not changing the ICD-10 definitions of the disease categories previously used on our work.  

The focus is on adding new diseases to keep up with the evolving evidence base on 
disease attribution to tobacco and/or alcohol.  

The ICD-10 codes for the new diseases added have deliberately been kept broad, 
pending a further review of the epidemiological evidence for the effects of tobacco and/or alcohol. 
After that review, the definitions of the diseases used in modelling may be made narrower.  


### Added (conditions not in v1.0.0)

- Malignant melanoma — C43, C44 *(Cancers)*. Relationship to tobacco.
- Cardiomyopathy — A39.5, B33.2, D86.8, I40, I42 (excl. I42.6), I43, I51.4,
  I51.5 *(Cardiovascular)* Relationship to alcohol.
- Other_alzheimers — F00, G31.1, G31.8, G31.9 *(Mental health)*. Relationship to alcohol (broader that just G30).
- Peptic ulcer disease — K25-K28, K92.0-K92.2 *(Other)*. Relationship to tobacco.
- Gallbladder diseases — K80-K83, K87 *(Other)*. Relationship to tobacco.
- Other sexually transmitted diseases — A50-A58, A60, A63, B63, I98.0,
  K67.0-K67.2, M03.1, M73.0, M73.1, N70, N71, N73, N74 *(Partially-attributable acute)*. Relationship to alcohol.
- HIV/AIDS — B20-B24 *(Partially-attributable acute)*. Relationship to alcohol.
- Mental and behavioural disorders due to use of tobacco — F17
  *(Wholly attributable to tobacco)*
- Toxic effect of tobacco and nicotine — T65.2 *(Wholly attributable to tobacco)*
- Vaping-related disorder — U07.0 *(Wholly attributable to tobacco)*

### Changed

- **Attribution flags updated:** Alzheimer's disease is now tobacco and alcohol (was
  tobacco-only).


### Fixed

- *Toxic effect of tobacco and nicotine*
  (T65.2) was added as its own tobacco-attributable condition, and T65.2 was
  excluded from *Accidental poisoning by exposure to noxious substances* (which
  uses the full T65 block). Without the exclusion the same record could be
  counted under both.

## [1.0.0] - 2022-05-30

Contributors: Duncan Gillespie, Laura Webster, Colin Angus

- Initial published reference: *Health conditions in the Sheffield Tobacco and
  Alcohol Policy Model and sources for risk functions* (D. Gillespie,
  University of Sheffield), released under CC-BY 4.0.
- Published with, and embedded in, the tobalcepi R package. Remains publicly
  available and unchanged at <https://osf.io/xq8mv/files/v6zxq>.
- 84 conditions (85 rows; oesophageal cancer split into two subtypes sharing
  C15). Encoded here as `lists/stapm_disease_list_v1_0_0.csv` in the
  repository's CSV conventions.
