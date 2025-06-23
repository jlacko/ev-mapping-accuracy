library(dplyr)
library(sf)

mpo <- st_read("./data/mpo.gpkg", quiet = T)
osm <- st_read("./data/osm.gpkg", quiet = T)

tolerance <- units::set_units(25, "m")

# true positive OSM - MPO charger within tolerance from OSM one
tp_osm <- osm %>% 
   st_buffer(tolerance) %>% 
   st_contains(mpo, sparse = F) %>% 
   rowSums() %>% 
   pmin(1) %>% 
   as.logical()

# false positive OSM
fp_osm <- !tp_osm


# true positive MPO - OSM charger within tolerance from MPO one
tp_mpo <- mpo %>% 
   st_buffer(tolerance) %>% 
   st_contains(osm, sparse = F) %>% 
   rowSums() %>% 
   pmin(1) %>% 
   as.logical()

# false positive MPO
fp_mpo <- !tp_mpo

# summary
print(paste("OSM confirmed within tolerance from MPO:", sum(tp_osm),
            "of", length(tp_osm),
            "i.e.", round(100 * (sum(tp_osm) / length(tp_osm)), 2), "%"))

print(paste("OSM missing within tolerance from MPO:", sum(fp_osm),
            "of", length(fp_osm),
            "i.e.", round(100 * (sum(fp_osm) / length(fp_osm)), 2), "%"))

print(paste("MPO confirmed within tolerance from OSM:", sum(tp_mpo),
            "of", length(tp_mpo),
            "i.e.", round(100 * (sum(tp_mpo) / length(tp_mpo)), 2), "%"))

print(paste("MPO missing within tolerance from OSM:", sum(fp_mpo),
            "of", length(fp_mpo),
            "i.e.", round(100 * (sum(fp_mpo) / length(fp_mpo)), 2), "%"))