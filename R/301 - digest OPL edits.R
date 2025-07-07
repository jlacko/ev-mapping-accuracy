# digest osm edits from processed csv form (see /python/300 - digest opl edits.py)

library(readr)
library(dplyr)
library(sf)

# initialize empty gpkg, if necessary...
if (!file.exists("./data/edits.gpkg")) { 
   
 data.frame(node = integer(),
            timestamp = as.POSIXct(character()),
            user = integer(),
            okres = integer(),
            kraj = integer(),
            lon = numeric(),
            lat = numeric()) %>% 
   st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
   st_write("./data/edits.gpkg", append = F, quiet = T)
   
} # /end if
   
# function to write to gpkg as a side effect
save_chunk <- function(x, pos) {
   
   print(paste(Sys.time(), "processing chunk at", pos))
   
   x %>% 
      filter(!is.na(lat) & !is.na(lon)) %>% 
      st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
      st_join(RCzechia::okresy(), left = F) %>% 
      select(node, timestamp, user, okres = KOD_OKRES, kraj = KOD_KRAJ) %>% 
      st_write("./data/edits.gpkg", append = T, quiet = T)
   
} # /end function

# do the action! note that only side effects are happening; the actual output is discarded :)
read_csv_chunked("./data/history.csv",
                 chunk_size = 1e7,
                 SideEffectChunkCallback$new(save_chunk),
                 col_names = c("node", "timestamp", "user", "lon", "lat")) 


# big fat warning: gígabytes of edits take hours to process - act accordingly...   

