# _VIMC Dengue Colombia_

This repository contains scripts for the processing and preparation of dengue case data from Colombia, using data from SIVIGILA via the [`sivirep`](https://epiverse-trace.github.io/sivirep/) R package.

## Folder Structure

### 📁 `scripts/`
This folder contains all the R scripts used for data preparation:

#### `0.data_download.R`
Downloads raw dengue case data using the `sivirep` package.  
The dataset is saved to the `data/` folder.  
The current version was downloaded on **Monday, August 4 at 9:08 PM**.

#### `1.data_cleaning.R`
Performs validation and cleaning of key variables such as:
- Age
- Location of case (municipality and department)
- Final condition (alive or deceased)
- And other relevant fields in the dataset.

#### `2.age_structure_neil.R`
Organizes weekly case counts by age group, department (admin level 2), and municipality (admin level 3).

Age groups are binned as follows:
- 1-year bands up to 20 years old
- Then 5-year bands above 20

The resulting dataset has the following structure:

| department | municipality     |  onset     | year_epi | week_epi | age_group | cases |
|------------|------------------|------------|----------|----------|-----------|--------|
| amazonas   | el_encanto_cd    | 2007-05-25 | 2007     | 21       | 19        | 1      |
| amazonas   | el_encanto_cd    | 2007-05-31 | 2007     | 22       | 21-25     | 1      |
| amazonas   | el_encanto_cd    | 2012-04-09 | 2012     | 15       | 19        | 1      |
| amazonas   | el_encanto_cd    | 2012-04-09 | 2012     | 15       | 20        | 1      |
| amazonas   | el_encanto_cd    | 2022-08-22 | 2022     | 34       | 7         | 1      |
| amazonas   | el_encanto_cd    | 2022-11-17 | 2022     | 46       | 41-45     | 1      |

---

## 📁 `data/`
This folder contains all raw and processed datasets generated from the scripts.  
It is recommended to add this folder to `.gitignore` if data should not be tracked.

---

## Dependencies

- `sivirep`
- `dplyr`
- `lubridate`
- `readr`
- `tidyr`
- (Other packages used within the scripts)

---

## Contact

If you have questions, suggestions, or comments, please create an issue in this repository or write to the following email: zulma.cucunuba@javeriana.edu.co

## Funding

This project is funded by the [Vaccine Impact Modelling Consortium (VIMC)](https://www.vaccineimpact.org/).
