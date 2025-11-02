################################################################################
# Weekly counts in 1 year age bands up to, 20, then 5 year age bands
# August 2025
#################################################################################

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

rm(list=ls())

# data
dengue_col <- readRDS("data/cleandat_2007_2023.RDS")

# Create age ranges
dengue_col <- dengue_col |>
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
  ),
  age_lower = case_when(
    is.na(edad) ~ NA_character_,
    edad < 5 ~ "0",
    edad >= 5 & edad < 10 ~ "5",  
    edad >= 10 & edad < 15 ~ "10",
    edad >= 15 & edad < 20 ~ "15",
    edad >= 20 & edad < 30 ~ "20",
    edad >= 30 & edad < 40 ~ "30",
    edad >= 40 & edad < 50 ~ "40",
    edad >= 50 & edad < 60 ~ "50",
    edad >= 60 & edad < 70 ~ "60",
    edad >= 70 & edad < 80 ~ "70",
    edad >= 80 & edad < 90 ~ "80",
    edad >= 90 ~ "90"
  ))

which(is.na(dengue_col$edad))
which(is.na(dengue_col$grupo_edad))
which(is.na(dengue_col$age_lower))

# Extract week with epiweek
dengue_col <- dengue_col |>
  mutate(
    ini_sin = as.Date(ini_sin), 
    epi_semana = epiweek(ini_sin),
    epi_ano = epiyear(ini_sin),
    iso_week = isoweek(ini_sin),
    iso_year = isoyear(ini_sin)
  )



#-------------------------------------------------------------------------------
#verification of weeks that generate overlapping years:

dengue_colv<-dengue_col %>% 
  select("cod_dpto_o","cod_mun_o","ini_sin",
         "semana","ano","epi_semana","epi_ano",
         "iso_week","iso_year","grupo_edad","age_lower") %>% 
  arrange("ini_sin")

# Week 53 of 2014
week53_2014 <- dengue_colv %>%
  filter(semana == 53, ano == 2014) #Week and year that the records bring by default
print("Week 53 of 2014 (SIVGILA):")
print(unique(week53_2014$ini_sin))


week53_2014 <- dengue_colv %>%
  filter(epi_semana == 53, epi_ano == 2014) #Week and year obtained using the epiweek and epiyear functions
print("Week 53 of 2014 (EPI functions):")
print(unique(week53_2014$ini_sin))

week53_2014 <- dengue_colv %>%
  filter(iso_week == 53, iso_year == 2014) #Week and year obtained using the isoweek and isoyear functions
print("Week 53 of 2014 (ISO functions):")
print(unique(week53_2014$ini_sin))


# Week 1 of 2015
week1_2015 <- dengue_colv %>%
  filter(semana == "01" & ano == 2015) #Week and year that the records bring by default
print("Week 1 of 2015:")
print(unique(week1_2015$ini_sin)) 

week1_2015 <- dengue_colv %>%
  filter(epi_semana == 1, epi_ano == 2015) #Week and year obtained using the epiweek and epiyear functions
print("Week 1 of 2015:")
print(unique(week1_2015$ini_sin))

week1_2015 <- dengue_colv %>%
  filter(iso_week == "01" & iso_year == 2015) #Week and year obtained using the isoweek and isoyear functions
print("Week 1 of 2015:")
print(unique(week1_2015$ini_sin))


#records by week
data_grapver <- dengue_colv %>%
  select(semana, ano, epi_semana, epi_ano, iso_week, iso_year) %>%
  mutate(across(everything(), as.character)) %>%
  mutate(ano_num = as.numeric(ano)) %>%
  filter(ano_num %in% c(2013, 2014, 2015)) %>%
  pivot_longer(
    cols = c(semana, epi_semana, iso_week),
    names_to = "variable_semana",
    values_to = "semana"
  ) %>%
  pivot_longer(
    cols = c(ano, epi_ano, iso_year),
    names_to = "variable_ano",
    values_to = "ano"
  ) %>%
  mutate(
    type = case_when(
      grepl("iso", variable_semana) ~ "ISO",
      grepl("epi", variable_semana) ~ "EPI",
      TRUE ~ "DEFAULT"
    ),
    week_num = as.numeric(semana),
    ano_num = as.numeric(ano)
  ) %>%
  filter(!is.na(week_num), !is.na(ano_num)) %>%
  group_by(type, ano_num, week_num) %>%
  summarise(n_records = n(), .groups = "drop")

data_grapver <- data_grapver %>%
  filter(ano_num >= 2013, ano_num <= 2015) %>%
  mutate(time_continuous = ano_num + (week_num - 1)/52)

# Graphic
ggplot(data_grapver, aes(x = time_continuous, y = n_records, color = type)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1.5, alpha = 0.6) +
  scale_x_continuous(
    name = "Year",
    breaks = 2013:2015,
    labels = 2013:2015,
    limits = c(2013, 2015.99)  # Hasta final de 2015
  ) +
  scale_color_manual(values = c("DEFAULT" = "blue", "EPI" = "red", "ISO" = "green")) +
  labs(
    title = "Dengue Cases by Epidemiological Week (2013–2015)",
    x = "Epidemiological Week",
    y = "Number of Records",
    color = ""
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    legend.position = "top"
  )

# It is decided to use iso functions to obtain the year and epidemiological week.


#--------------------------------------------------------------------------------------

# Group and count (onset as onset of symptoms )
weekly_counts <- dengue_col |>
  filter(
    !is.na(grupo_edad),
    !is.na(age_lower),
    !is.na(ini_sin),
    !is.na(departamento_ocurrencia),
    !is.na(municipio_ocurrencia)
  ) |>
  rename(
    cod_department = cod_dpto_o,
    cod_municipality = cod_mun_o,
    department = departamento_ocurrencia,
    municipality = municipio_ocurrencia,
    year_epi = iso_year, # epi_ano,
    week_epi = iso_week, #epi_semana,
    age_group = grupo_edad,
    onset = ini_sin 
  ) |>
  group_by(cod_department, cod_municipality, department, municipality, onset, year_epi, week_epi, age_lower) |>
  summarise(cases = n(), 
            .groups = "drop") |>
  mutate(cod_municipality=as.character(cod_municipality)) %>% 
  arrange(department, municipality, year_epi, week_epi, age_lower)


# output
sum(weekly_counts$cases) # 1'309.552 (151 reports excluded for not having a date of onset of symptoms )

str(weekly_counts)
#Save data with new structure
saveRDS(weekly_counts, "data/weekly_counts_2007_2023.RDS")

