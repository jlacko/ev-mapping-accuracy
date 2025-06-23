library(dplyr)
library(sf)

mpo <- st_read("./data/mpo.gpkg", quiet = T)
ochm <- st_read("./data/ochm.gpkg", quiet = T)

tolerance <- units::set_units(25, "m")

# true positive OCHM - MPO charger within tolerance from OCHM one
tp_ochm <- ochm %>% 
   st_buffer(tolerance) %>% 
   st_contains(mpo, sparse = F) %>% 
   rowSums() %>% 
   pmin(1) %>% 
   as.logical()

# false positive OCHM
fp_ochm <- !tp_ochm


# true positive MPO - OCHM charger within tolerance from MPO one
tp_mpo <- mpo %>% 
   st_buffer(tolerance) %>% 
   st_contains(ochm, sparse = F) %>% 
   rowSums() %>% 
   pmin(1) %>% 
   as.logical()

# false positive MPO
fp_mpo <- !tp_mpo

# summary
print(paste("OCHM confirmed within tolerance from MPO:", sum(tp_ochm),
            "of", length(tp_ochm),
            "i.e.", round(100 * (sum(tp_ochm) / length(tp_ochm)), 2), "%"))

print(paste("OCHM missing within tolerance from MPO:", sum(fp_ochm),
            "of", length(fp_ochm),
            "i.e.", round(100 * (sum(fp_ochm) / length(fp_ochm)), 2), "%"))

print(paste("MPO confirmed within tolerance from OCHM:", sum(tp_mpo),
            "of", length(tp_mpo),
            "i.e.", round(100 * (sum(tp_mpo) / length(tp_mpo)), 2), "%"))

print(paste("MPO missing within tolerance from OCHM:", sum(fp_mpo),
            "of", length(fp_mpo),
            "i.e.", round(100 * (sum(fp_mpo) / length(fp_mpo)), 2), "%"))