# EV Stations Mapping Accuracy
How accurate are crowdsourced EV maps?

Researchers of Spatial Data Science and Transport Science often rely on crowdsourced data, such as Open Street Map. A question often arises: how reliable are such data? Can publication quality results be expected from them? On a very basic level: can we (can I?) trust them?

I have come to realize that a possible test of the data quality is location of EV charging stations in Czechia (coincidently an area of active research by yours truly).

Czech EV stations are required by law to register with our Ministry of Industry and Trade (MPO), and a [list is published online](https://mpo.gov.cz/cz/energetika/statistika/statistika-a-evidence-cerpacich-a-dobijecich-stanic/seznam-verejne-pristupnych-dobijecich-stanic--280706/). This list, which includes GPS coordinates, can be easily compared to crowdsourced data, such as [Open Street Map](https://www.openstreetmap.org/) and [Open Charge Map](https://openchargemap.org/).

<p style="text-align:center;"><img src="https://s3.eu-central-1.amazonaws.com/www.jla-data.net/img/osm-mpo-comparison.png" alt="plot comparing EV stations in Czechia as per MPO and OSM data"/></p>

The comparison is still a very active work in process, but the preliminary findings are:

- out of 1913 stations reported in OSM 839 can be confirmed to official MPO data (match of 43.86%)
- out of 3105 stations reported to MPO 1198 can be confirmed to OSM (match of 38.58%)
- out of 552 stations reported in OCHM 175 can be confirmed to official MPO data (match of 31.7%)
- out of 3105 stations reported to MPO 304 can be confirmed to OCHM (match of 9.79%)

There is a small mismatch in that I used a tolerance of 25 meters to paper over inaccuracies in GPS coordinates, and in some cases multiple chagers matched to one target (it is a common case that EV charging points are clustered).

In any case I would trust the official MPO data the most, followed by OSM - and OCHM the very least, with a big grain of salt.

For those inclined to verify my results: code, in statistical programming language R, is in R folder, together with reproducible code to digest OSM and OCHM databases relevant to Czechia.