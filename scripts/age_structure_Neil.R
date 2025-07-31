################################################################################
# Weekly counts in 1 year age bands up to, 20, then 5 year age bands
#JUL 2025
#################################################################################

library(dplyr)
library(lubridate)

rm(list=ls())


#DATA
dengue_col <- readRDS("data/cleandat_2007_2023.RDS")


# Create age ranges
dengue_col <- dengue_col %>%
  mutate(grupo_edad = case_when(
    is.na(edad) ~ NA_character_,
    edad < 1 ~ "0",
    edad >= 1 & edad < 21 ~ as.character(floor(edad)),  # De 1 a 20 individual
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

# Group and count
conteos_semanales <- dengue_col %>%
  filter(!is.na(grupo_edad), !is.na(con_fin), !is.na(departamento), !is.na(municipio)) %>%
  group_by(departamento, municipio, con_fin, ano, semana, grupo_edad) %>%
  summarise(casos = n(), .groups = "drop") %>%
  arrange(departamento, municipio, ano, semana, grupo_edad)

# output
head(conteos_semanales)
sum(conteos_semanales$casos)

#Save data with new structure
saveRDS(conteos_semanales, "data/weekly_counts_2007_2023.RDS")

