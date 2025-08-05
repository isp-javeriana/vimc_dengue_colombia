#####################################################################
# Download complete dengue cases with SIVIREP
# SIVIREP Package: https://epiverse-trace.github.io/sivirep/
# August 2025
#####################################################################


#==========================================
# Install sivirep (It is only done once)
#==========================================

#1. Instalar Rtools: https://cran.r-project.org/bin/windows/Rtools/

#2. Instalar sivirep:
install.packages("pak")
pak::pak("epiverse-trace/sivirep")
#.rs.restartR()

library(sivirep)


#==========================================
# Download case reports
#==========================================

#Total number of cases per year 2007 to 2023
dat<-import_data_event(nombre_event = "DENGUE",
                              years =c(2007:2023),
                              cache = TRUE)

dat_limpia <- limpiar_data_sivigila(data_event = dat) #standardize age in years

#Save dataset
saveRDS(dat_limpia, "data/dat_denguesivirep2007_2023.RDS")


