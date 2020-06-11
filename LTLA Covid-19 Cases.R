library(tidyverse)
library(readr)
library(rgdal)
library(leaflet)


cases_df <- read_csv("coronavirus-cases_latest.csv")

uptla_df <- cases_df %>% filter(`Area type` == "Upper tier local authority")

ltla_df <- cases_df %>% filter(`Area type` == "Lower tier local authority")
ltla_df <- ltla_df %>% select(-c(`Area code`, `Previously reported cumulative cases`, `Change in daily cases`, `Previously reported daily cases`, `Change in cumulative cases`))

ltla_df <- ltla_df %>% rename(daily_lab_cases = "Daily lab-confirmed cases")

uk_la <- readOGR("uk_la.geojson")

names(uk_la)
      
bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = ltla_df$daily_lab_cases, bins = bins)


leaflet(uk_la) %>%
      setView(0, 30, 2.2) %>%
      addTiles() %>% 
      addPolygons(
        fillColor = ~pal(ltla_df$daily_lab_cases),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = paste(uk_la$name, "Payment Volume:", ltla_df$daily_lab_cases),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")) %>%
      addLegend(pal = pal, values = ~ltla_df$daily_lab_cases, opacity = 0.7, title = "Total Volume of Payments Sent",
                position = "bottomright") %>%
      addControl("Payer Country: Volume of Payments", position = "topleft")
