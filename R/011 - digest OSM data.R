# načíst státy, vybrat objekty dle definice; funkcí protože chceme opakovatelně

library(dplyr)
library(fs)
library(sf)
library(stringr)

# hláška pro diváky: začátek
cat(paste("začátek zpracování", Sys.time(),"\n"))
   
# všechny soubory
osm <- fs::dir_ls(paste0("./data-raw/"))

# ten z nich, který končí na osm pbf (jen ten je ten pravý! :)
osm <- osm[str_detect(osm, "osm.pbf$")]

# extrahovat objekty požadovaného typu
points <- st_read(osm, layer = "points") %>% 
   dplyr::filter(str_detect(other_tags, "charging_station")) %>% 
   mutate(country_code = "CZ",
          object_type = "charging_station",
          object_id = osm_id) %>% 
   select(country_code, object_type, object_id, name) 

points %>% 
   st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
   st_write("./data/osm.gpkg", append = FALSE)

# hláška pro diváky: konec
cat(paste("konec zpracování", Sys.time(),"\n"))