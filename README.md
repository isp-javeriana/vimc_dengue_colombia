# _VIMC Dengue Colombia_

This repository contains scripts for the processing and preparation of dengue case data from Colombia, using data from SIVIGILA via the [`sivirep`](https://epiverse-trace.github.io/sivirep/) R package.

## Folder Structure

### 📁 `scripts/`
This folder contains all the R scripts used for data preparation:

#### `0.data_population.R`
Download and organization of population data for each municipality and department in Colombia, downloaded from DANE [(National Administrative Department of Statistics of Colombia (https://www.dane.gov.co/index.php/estadisticas-por-tema/demografia-y-poblacion/proyecciones-de-poblacion)]. The organized files are stored in the `data/pobcol/` folder.  
To merge it with the case data, we recommend using the variables “cod_department” and “cod_municipality” which refer to the code that identifies each location at the administrative level, bearing in mind that the names of the locations may vary depending on the source (e.g., the department of Valle del Cauca may appear only as Valle depending on the file).

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

It also filters the records, leaving only those with occurrence sites in municipalities at 2,300 meters above sea level or less, according to published [evidence for Colombia on Aedes aegypti](https://revistabiomedica.org/index.php/biomedica/article/view/3301).

#### `2.age_structure_neil.R`
Organizes weekly case counts by age group, department (admin level 2), and municipality (admin level 3).

Age groups are categorized in two different ways:
First way: variable `age_group`
- 1-year bands up to 20 years old
- Then 5-year bands above 20

Second way: using the variable `age_lower`
- children under 5 years old = 0
- 10-year-old group = the youngest age in the group

The resulting dataset has the following structure:

| cod_department | cod_municipality | department | municipality  | onset      | year_epi | week_epi | age_lower | cases |
|---------------|-----------------|------------|--------------|------------|----------|----------|-----------|-------|
| 91            | 91263           | amazonas   | el_encanto_cd | 2007-05-22 | 2007     | 21       | 15        | 1     |
| 91            | 91263           | amazonas   | el_encanto_cd | 2007-05-30 | 2007     | 22       | 20        | 1     |
| 91            | 91263           | amazonas   | el_encanto_cd | 2012-04-07 | 2012     | 14       | 15        | 1     |
| 91            | 91263           | amazonas   | el_encanto_cd | 2012-04-07 | 2012     | 14       | 20        | 1     |
| 91            | 91263           | amazonas   | el_encanto_cd | 2022-08-18 | 2022     | 33       | 5         | 1     |
| 91            | 91263           | amazonas   | el_encanto_cd | 2022-11-10 | 2022     | 45       | 40        | 1     |

*`year_epi` y `week_epi` fueron obtenidos usando las funciones `isoweek()` y `isoyear()`.


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
