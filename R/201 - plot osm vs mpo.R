library(ggplot2)

source("./R/101 - evaluation osm vs mpo.R")

chrt_src <- data.frame(source = c("OSM", "OSM", "MPO", "MPO"),
                       status = c("found", "missing", "found", "missing"),
                       count = c(sum(tp_osm), sum(fp_osm), sum(tp_mpo), sum(fp_mpo)),
                       stringsAsFactors = T)

# Wes Anderson or bust!

ggplot(chrt_src, aes(x = source, y = count, group = source)) +
   geom_col(aes(fill = status)) +
   geom_text(aes(label = scales::number(count, big.mark = " ")), 
             position = position_stack(vjust = 1/2)) +
   labs(subtitle = "OSM / MPO comparison",
        title = "EV chargers in Czechia",
        fill = "Status") +
   scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
   scale_fill_manual(values = wesanderson::wes_palette("Zissou1", n = 5, type = "discrete")[c(2, 4)])+
   theme_minimal() +
   theme(axis.title = element_blank(),
         legend.title = element_text(hjust = 1/2),
         legend.text = element_text(hjust = 1))
   

ggsave("osm-mpo-comparison.png", 
       width = 800, height = 1000, dpi = 175,
       units = "px")
