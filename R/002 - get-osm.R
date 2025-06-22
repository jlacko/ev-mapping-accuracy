# download the current OSM for Czechia, if not available

if (!file.exists("./data-raw/czech-republic-latest.osm.pbf")) {
   curl::curl_download("https://download.geofabrik.de/europe/czech-republic-latest.osm.pbf",
                       "./data-raw/czech-republic-latest.osm.pbf")
}

