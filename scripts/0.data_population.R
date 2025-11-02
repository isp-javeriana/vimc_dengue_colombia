################################
# Population by municipality
# October 2025
################################

library(httr)
library(readxl)
library(tidyverse)
library(dplyr)
library(tidyr)


# ============================================================
# Debugging of DANE population projections (2005–2017)
# ============================================================

rm(list = ls())


# Download file from DANE (National Administrative Department of Statistics of Colombia)
url_pob_dane <- "https://www.dane.gov.co/files/censo2018/proyecciones-de-poblacion/Municipal/DCD-area-sexo-edad-proypoblacion-Mun-2005-2017_VP.xlsx"
response <- GET(url_pob_dane)

temp_file <- tempfile(fileext = ".xlsx")
writeBin(content(response, "raw"), temp_file)

population1 <- read_excel(temp_file, skip = 11)

# Convert the age columns to long format
population_long <- population1 |>
  pivot_longer(
    cols = matches("^(Hombres_|Mujeres_|Total_)"), 
    names_to = "variable",
    values_to = "population"
  )

# Separate sex and age
population_long <- population_long |>
  separate(variable, into = c("sex", "age"), sep = "_") |>
  mutate(
    age = str_replace(age, "y más", "85+"),  
    age = str_replace_all(age, "\\s+", "_")  
  )

# Filter only Totals by age
population_total <- population_long |>
  filter(sex == "Total") |>
  select(DP, DPNOM, MPIO, DPMP,AÑO, `ÁREA GEOGRÁFICA`, age, population)

# Convert to wide format (years as columns)
pob_2005_2017 <- population_total |>
  mutate(AÑO = paste0("A_", AÑO)) |>  
  pivot_wider(
    names_from = AÑO,
    values_from = population
  ) |>
  rename(geographical_area = `ÁREA GEOGRÁFICA`)

# Save the result
dir.create("data/pobcol", showWarnings = FALSE, recursive = TRUE)
saveRDS(pob_2005_2017, "data/pobcol/pob_municipalites_2005_2017.rds")


#-------------------------------------------------------------------------------

# ------------------------------------------------------------
# Debugging of DANE population projections (2018–2023)
# ------------------------------------------------------------


# Download file from DANE (National Administrative Department of Statistics of Colombia)
url2_pob_dane <- "https://www.dane.gov.co/files/censo2018/proyecciones-de-poblacion/Municipal/PPED-AreaSexoEdadMun-2018-2042_VP.xlsx"
response2 <- GET(url2_pob_dane)

temp_file2 <- tempfile(fileext = ".xlsx")
writeBin(content(response2, "raw"), temp_file2)

# Read headers (rows 8 and 9) from the third sheet and filter required years.
headers <- read_excel(temp_file2, sheet = 3, skip = 7, n_max = 2, col_names = FALSE)
col_names <- apply(headers, 2, function(x) paste0(na.omit(x), collapse = "_"))
proypoblacion_Mun_2018_2042 <- read_excel(temp_file2, sheet = 3, skip = 9, col_names = col_names)
population2 <- proypoblacion_Mun_2018_2042 |>
  filter(AÑO <= 2023)

# Convert the age columns to long format
population_long2 <- population2 |>
  select(DP, DPNOM, DPMP, MPIO, AÑO, `ÁREA GEOGRÁFICA`,
         `Hombres`, `Mujeres`, `TOTAL_Total`,
         starts_with("Hombres"), starts_with("Mujeres"), starts_with("Total")) |>
 pivot_longer(
    cols = starts_with("Hombres") | starts_with("Mujeres") | starts_with("Total"),
    names_to = "variable",
    values_to = "population"
  ) |>
 mutate(
    sex = case_when(
      str_detect(variable, "Hombre") ~ "Hombres",
      str_detect(variable, "Mujer") ~ "Mujeres",
      str_detect(variable, "Total") ~ "Total"
    ),
    age = str_extract(variable, "\\d+"),
    age = ifelse(is.na(age) & str_detect(variable, "más"), "100", age),
    age = as.numeric(age),
    age = ifelse(age >= 85, "85_85+", as.character(age))
 )


# Filter only Totals by age
population_total2 <- population_long2 |>
  filter(sex == "Total") |>
  select(DP, DPNOM, MPIO, DPMP,AÑO, `ÁREA GEOGRÁFICA`, age, population) |> 
  filter(!is.na(age)) |>
  group_by(DP, DPNOM, MPIO, DPMP, `ÁREA GEOGRÁFICA`, age, AÑO) |>
  summarise(population = sum(population, na.rm = TRUE), .groups = "drop")

# Convert to wide format (years as columns)
pob_2018_2023 <- population_total2 |>
  mutate(AÑO = paste0("A_", AÑO)) |>  
  pivot_wider(
    names_from = AÑO,
    values_from = population
  ) |>
  rename(geographical_area = `ÁREA GEOGRÁFICA`)


# Save the result
saveRDS(pob_2018_2023, "data/pobcol/pob_municipalites_2018_2023.rds")



# ------------------------------------------------------------
# Unification 2005–2023
# ------------------------------------------------------------

cols_comun <- c("DP", "DPNOM", "MPIO", "DPMP", "geographical_area", "age")

pob_2005_2017 <- pob_2005_2017 |>
  mutate(across(all_of(cols_comun), as.character))

pob_2018_2023 <- pob_2018_2023 |>
  mutate(across(all_of(cols_comun), as.character))

# Unir datasets por filas según columnas comunes
popolation_2005_2023 <- full_join(
  pob_2005_2017, pob_2018_2023,
  by = cols_comun) |> 
  select(cod_department=DP, department=DPNOM, cod_municipality=MPIO, municipality=DPMP,  geographical_area, age, starts_with("A_")) |>
  arrange(department, municipality, suppressWarnings(as.numeric(age)))

# Guardar los resultados finales
saveRDS(popolation_2005_2023, "data/pobcol/pob_municipalites_2005_2023.rds")

#-------------------------------------------------------------------------------





