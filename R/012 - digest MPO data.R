library(dplyr)
library(sf)

readxl::read_excel("data-raw/Seznam_verDS_2025_05_31_v00.xlsx",
                              range = "b6:ab3111") %>% 
   st_as_sf(coords = c("LON (východní délka)",
                       "LAT (severní šířka)"),
            crs = 4326) %>% 
   st_write("./data/mpo.gpkg", append = FALSE)