################################################################################
# Weekly counts in 1 year age bands up to, 20, then 5 year age bands
# August 2025
#################################################################################

library(dplyr)
library(lubridate)

rm(list=ls())


# data
dengue_col <- readRDS("data/cleandat_2007_2023.RDS")


# Create age ranges
dengue_col <- dengue_col %>%
  mutate(grupo_edad = case_when(
    is.na(edad) ~ NA_character_,
    edad < 1 ~ "0",
    edad >= 1 & edad < 21 ~ as.character(floor(edad)),  # From 1 to 20 individual
    edad >= 21 & edad <= 25 ~ "21-25",
    edad > 25 & edad <= 30 ~ "26-30",
    edad > 30 & edad <= 35 ~ "31-35",
    edad > 35 & edad <= 40 ~ "36-40",
    edad > 40 & edad <= 45 ~ "41-45",
    edad > 45 & edad <= 50 ~ "46-50",
    edad > 50 & edad <= 55 ~ "51-55",
    edad > 55 & edad <= 60 ~ "56-60",
    edad > 60 & edad <= 65 ~ "61-65",
    edad > 65 & edad <= 70 ~ "66-70",
    edad > 70 & edad <= 75 ~ "71-75",
    edad > 75 & edad <= 80 ~ "76-80",
    edad > 80 ~ "81+"
  ))

# extract week with epiweek
dengue_col <- dengue_col %>%
  mutate(
    fec_not = as.Date(fec_not), 
    epi_semana = epiweek(fec_not),
    epi_ano = epiyear(fec_not)
  )

# Group and count
weekly_counts <- dengue_col %>%
  filter(!is.na(grupo_edad), !is.na(fec_not), !is.na(departamento), !is.na(municipio)) %>%
  rename(
    department = departamento,
    municipality = municipio,
    year_epi = epi_ano,
    week_epi = epi_semana,
    age_group = grupo_edad,
    notif_date = fec_not 
  ) %>%
  group_by(department, municipality, notif_date, year_epi, week_epi, age_group) %>%
  summarise(cases = n(), .groups = "drop") %>%
  arrange(department, municipality, year_epi, week_epi, age_group)


# output
sum(weekly_counts$cases)

#Save data with new structure
saveRDS(weekly_counts, "data/weekly_counts_2007_2023.RDS")

head(weekly_counts)
