
library(tidyverse)
library(sf)
# library(wellknown)

occ <- read_csv("data/dwca/occ.csv")
events <- read_csv("data/dwca/events.csv")

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
  dplyr::select(eventID, decimalLatitude, decimalLongitude, geodeticDatum)


occ2 <- occ |>
  inner_join(bind_rows(
    events_aux_tr, events_aux_ab),
    by = "eventID") |>
  mutate(across(.cols=everything(), ~ifelse(is.na(.), "", .)))


write_csv(occ2, "data/dwca/v2_3/occ.csv")


# Remove NA of all variables
# Reformat eventDate
# Change to EPSG 4326
events_fixed <- events |>
  mutate(across(.cols=-eventDate, ~ifelse(is.na(.), "", .))) |>
  mutate(eventDate = lubridate::ymd(eventDate))

write_csv(events_fixed, "data/dwca/v2_3/events.csv")


# For the occurrence file we done the change at targets (add rank) and also in the script
# add_coordinates_to_occ.R

# For the emof
emof <- read_csv("data/dwca/emof.csv")

emof_fixed <- emof |>
  mutate(measurementValue = ifelse(measurementType == "diversity index",
                                   round(measurementValue, 3),
                                   measurementValue)) |>
  mutate(across(.cols=-measurementDeterminedDate, ~ifelse(is.na(.), "", .))) |>
  mutate(measurementDeterminedDate = lubridate::ymd(measurementDeterminedDate))
write_csv(emof_fixed, "data/dwca/v2_3/emof.csv")
