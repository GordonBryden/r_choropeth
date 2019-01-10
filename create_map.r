library(RColorBrewer)
library(ggplot2)
library(dplyr)
library(rgdal)

#Load in shapefile and convert to ggplot compatable dataframe
#myMap2<-readOGR("./nuts3","nuts3")
raw_map<-readOGR("./NUTS_Level_3","NUTS_Level_3_January_2018_Full_Clipped_Boundaries_in_the_United_Kingdom")
dataframe_map<- fortify(raw_map,region = "nuts318cd")

#Load in data, filter out London
my_data <- read.csv("uk_gva_capita.csv",stringsAsFactors = FALSE) %>%
  filter(!substr(NUTS,1,3) == "UKI")

#Append data to map, dropping non-matched regions. Use left join to keep non-matched
map_data<-dataframe_map  %>%
  left_join(my_data,
            by = c("id" = "NUTS")) %>%
  droplevels()

save.image("map.rdata")

#Just run from here if you're reloading
load("map.rdata")

#Create png of image

png('gva_per_capita.png')

ggplot() + geom_map(data = map_data,
                    map = map_data,
                    aes( x = long,
                         y = lat,
                         group = group,
                         map_id=id, 
                         fill=value
                         )) +
  coord_equal() + #apply projection to map (cortesian)
  #check out colorbrewer2.org for map colour
  scale_fill_gradient(low = "#efedf5", high = "#252ba1",na.value = "grey40",
                      name = "GVA per capita") +
  #Now remove all "graph" elements to leave map only
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),#legend.position="none",
            panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank()) 

dev.off()
