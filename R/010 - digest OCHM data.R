# ze surových jsonů z open charge mapy připraví něco čistšího...

library(dplyr)
library(sf)

# hláška pro diváky: začátek
cat(paste("začátek zpracování", Sys.time(),"\n"))

# sezam jsonů ke zpracování
raw_jsony <- paste0("./ocm-export/data/CZ/",
                    list.files(path = "./ocm-export/data/CZ/", 
                        recursive = T, 
                        pattern = "*.json"))

# inicializace  prázdného data frejmu
clean_data <- data.frame()

# vektor country names https://github.com/openchargemap/ocm-docs/blob/master/Database/Scripts/ReferenceData/dbo.Country.Table.sql
cntries <- c('GB', 'US','IE', 'HK','AF', 'AX','AL', 'DZ','AS', 'AD','AO', 'AI','AQ', 'AG','AR', 'AM','AW', 'AU','AT', 'AZ','BS', 'BH','BD', 'BB','BY', 'BE','BZ', 'BJ','BM', 'BT','BO', 'BQ','BA', 'BW','BV', 'BR','IO', 'BN','BG', 'BF','BI', 'KH','CM', 'CA','CV', 'KY','CF', 'TD','CL', 'CN','CX', 'CC','CO', 'KM','CG', 'CD','CK', 'CR','CI', 'HR','CU', 'CW','CY', 'CZ','DK', 'DJ','DM', 'DO','EC', 'EG','SV', 'GQ','ER', 'EE','ET', 'FK','FO', 'FJ','FI', 'FR','GF', 'PF','TF', 'GA','GM', 'GE','DE', 'GH','GI', 'GR','GL', 'GD','GP', 'GU','GT', 'GG','GN', 'GW','GY', 'HT','HM', 'VA','HN', 'HU','IS', 'IN','ID', 'IR','IQ', 'IM','IL', 'IT','JM', 'JP','JE', 'JO','KZ', 'KE','KI', 'KP','KR', 'KW','KG', 'LA','LV', 'LB','LS', 'LR','LY', 'LI','LT', 'LU','MO', 'MK','MG', 'MW','MY', 'MV','ML', 'MT','MH', 'MQ','MR', 'MU','YT', 'MX','FM', 'MD','MC', 'MN','ME', 'MS','MA', 'MZ','MM', 'NA','NR', 'NP','NL', 'NC','NZ', 'NI','NE', 'NG','NU', 'NF','MP', 'NO','OM', 'PK','PW', 'PS','PA', 'PG','PY', 'PE','PH', 'PN','PL', 'PT','PR', 'QA','RE', 'RO','RU', 'RW','BL', 'SH','KN', 'LC','MF', 'PM','VC', 'WS','SM', 'ST','SA', 'SN','RS', 'SC','SL', 'SG','SX', 'SK','SI', 'SB','SO', 'ZA','GS', 'ES','LK', 'SD','SR', 'SJ','SZ', 'SE','CH', 'SY','TW', 'TJ','TZ', 'TH','TL', 'TG','TK', 'TO','TT', 'TN','TR', 'TM','TC', 'TV','UG', 'UA','AE', 'UM','UY', 'UZ','VU', 'VE','VN', 'VG','VI', 'WF','EH', 'YE','ZM', 'ZW')

# named vektor typů využití - UsageTypeID má číselník https://github.com/openchargemap/ocm-docs/blob/master/Database/Scripts/ReferenceData/dbo.UsageType.Table.sql
usage_types <- c("0" = "Unknown",
                 "1" = "Public",
                 "2" = "Private - Restricted Access",
                 "3" = "Privately Owned - Notice Required",
                 "4" = "Public - Membership Required",
                 "5" = "Public - Pay At Location",
                 "6" = "Private - For Staff, Visitors or Customers",
                 "7" = "Public - Notice Required")

# named vektor statutů -  StatusTypeID má číselník https://github.com/openchargemap/ocm-docs/blob/master/Database/Scripts/ReferenceData/dbo.StatusType.Table.sql  
status_types <- c("0" = "Unknown",
                  "10" = "Currently Available (Automated Status)",
                  "20" = "Currently In Use (Automated Status)",
                  "30" = "Temporarily Unavailable",
                  "50" = "Operational",
                  "75" = "Partly Operational (Mixed)",
                  "100" = "Not Operational",
                  "150" = "Planned For Future Date",
                  "200" = "Removed (Decomissioned)") 

# iterace přez nalezené jsony
for (i in seq_along(raw_jsony)) {
  
wrk_json <- jsonlite::fromJSON(raw_jsony[i], flatten = T)

# sekce DQ checks jsonu:

# když není Quantity, tak doplnit defaultem 1
if (!"Quantity" %in% names(wrk_json$Connections)) {
  wrk_json$Connections$Quantity <- 1
}

# když není LevelID, tak doplnit defaultem 0
if (!"LevelID" %in% names(wrk_json$Connections)) {
  wrk_json$Connections$LevelID <- 0
}

# když není UsageTypeID, tak doplnit defaultem 0
if (!"UsageTypeID" %in% names(wrk_json)) {
  wrk_json$UsageTypeID <- 0
}

# když není StatusTypeID na záznamu, tak doplnit defaultem 0
if (!"StatusTypeID" %in% names(wrk_json)) {
  wrk_json$StatusTypeID <- 0
}

# když není StatusTypeID na zásuvce, tak doplnit defaultem 0
if (!"StatusTypeID" %in% names(wrk_json$Connections)) {
  wrk_json$Connections$StatusTypeID <- 0
}

if(inherits(wrk_json$Connections, "data.frame")) {
# vysčítání connectionnů metodikou https://github.com/openchargemap/ocm-system/blob/master/Localisation/src/OCM_UI_LocalisationResources.en.json

# ConnectionTypeID má číselník https://github.com/openchargemap/ocm-docs/blob/master/Database/Scripts/ReferenceData/dbo.ConnectionType.Table.sql
  
  wrk_levels <- wrk_json$Connections %>% 
    filter(! StatusTypeID %in% c(100, 150, 200)) %>%  # = vykosit vypnuté, plánované v budoucnu a zrušené
    group_by(LevelID) %>% 
    summarise(pocet = sum(Quantity),
              connections = n())
} else {
  # když conectiony nejsou definované - default = jedna connectiona neznámého typu
  wrk_levels <- data.frame(LevelID = 0,
                           pocet = 1)
}

clean_data <- clean_data %>% 
  bind_rows(data.frame(id = wrk_json$ID,
                       uuid = wrk_json$UUID,
                       title = wrk_json$AddressInfo$Title,
                       town = coalesce(wrk_json$AddressInfo$Town, 
                                       wrk_json$AddressInfo$StateOrProvince,
                                       ""),
                       country_code = cntries[wrk_json$AddressInfo$CountryID],
                       lat = wrk_json$AddressInfo$Latitude,
                       lon = wrk_json$AddressInfo$Longitude,
                       comments = coalesce(wrk_json$GeneralComments,
                                           wrk_json$AddressInfo$AccessComments,
                                           ""),
                       usage_type = usage_types[as.character(wrk_json$UsageTypeID)],
                       status_type = status_types[as.character(wrk_json$StatusTypeID)],
                       power_unknown = sum(subset(wrk_levels, LevelID == 0)$pocet),
                       power_low = sum(subset(wrk_levels, LevelID == 1)$pocet),
                       power_medium = sum(subset(wrk_levels, LevelID == 2)$pocet),
                       power_high = sum(subset(wrk_levels, LevelID == 3)$pocet),
                       connections = sum(wrk_levels$connections),
                       stations_bays = coalesce(wrk_json$NumberOfPoints, 1),
                       created = as.POSIXct(wrk_json$DateCreated),
                       updated = as.POSIXct(wrk_json$DateLastStatusUpdate),
                       verified = as.POSIXct(wrk_json$DateLastVerified)))

}

clean_data %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
  st_write("./data/ochm.gpkg", append = FALSE)

# hláška pro diváky: cíle bylo dosaženo
cat(paste("konec zpracování", Sys.time(),"\n"))