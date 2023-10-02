
library(tidyverse)
library(sf)
library(wellknown)

occ <- read_csv("data/dwca/occ.csv")[,-1]
events <- read_csv("data/dwca/events.csv")[,-1]

events_abundance_coord <- events |>
  filter(samplingProtocol == "Quadrat count") |>
  filter(!is.na(footprintWKT)) |>
  mutate(centroid = st_centroid(st_as_sfc(footprintWKT))) |>
  mutate(decimalLongtitude = st_coordinates(centroid)[, 1],
         decimalLatitude = st_coordinates(centroid)[, 2]) |>
  dplyr::select(eventID, decimalLatitude, decimalLongtitude, geodeticDatum = footprintSRS)


events_transectos_coord <- events |>
  filter(samplingProtocol == "Point Quadrat Transect") |>
  filter(!is.na(footprintWKT)) |>
  mutate(centroid = st_centroid(st_as_sfc(footprintWKT))) |>
  mutate(decimalLongtitude = st_coordinates(centroid)[, 1],
         decimalLatitude = st_coordinates(centroid)[, 2]) |>
  dplyr::select(eventID, decimalLatitude, decimalLongtitude, geodeticDatum = footprintSRS)




events_aux_tr <- events |>
  filter(samplingProtocol == "Point Quadrat Transect") |>
  filter(is.na(footprintWKT)) |>
  inner_join(events_transectos_coord, by = c("parentEventID" = "eventID")) |>
  dplyr::select(eventID, decimalLatitude, decimalLongtitude, geodeticDatum)


events_aux_ab <- events |>
  filter(samplingProtocol == "Quadrat count") |>
  filter(is.na(footprintWKT)) |>
  inner_join(events_abundance_coord, by = c("parentEventID" = "eventID")) |>
  dplyr::select(eventID, decimalLatitude, decimalLongtitude, geodeticDatum)


occ2 <- occ |>
  inner_join(bind_rows(
    events_aux_tr, events_aux_ab),
    by = "eventID")


write_csv(occ2, "data/dwca/occ_coordinates.csv")
