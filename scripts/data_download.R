#DESCARGA COMPLETA DE CASOS DE DENGUE CON SIVIREP
#JULIO 2025

#remove.packages("sivirep")
#pak::pak("epiverse-trace/sivirep@fix-review-items")
#Limpia la sesión de R
#Importa el paquete
library(sivirep)

#Número total de casos por año 2007 a 2023

dat<-import_data_event(nombre_event = "DENGUE",
                              years =c(2007:2023),
                              cache = TRUE)

dat_limpia <- limpiar_data_sivigila(data_event = dat) #estandariza la edad en años
saveRDS(dat_limpia, "data/dat_DengueSivirep2007-2023.RDS")


