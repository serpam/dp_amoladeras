library(rgbif)
library(sf)
library(giscoR)
library(ggplot2)
library(tidyverse)
library(tidyterra)
library(geodata)
library(elevatr)
library(ggmapinset)
library(vroom)
library(mapSpain)


###### Load data
## Andalusia ENP
enp <- st_read("data/geoinfo/enp.shp")

## FAME 5 x 5
fame_utm <- st_read("data/geoinfo/atlas_5x5_andalucia.shp")

## FAME dist
fame <- st_read("data/geoinfo/datos_fame.shp")


###### GBIF Data
# Get taxa key of Ae and C. europaeum
# taxa <- c("Androcymbium europaeum", "Colchicum europaeum")
#
# taxon_keys <- taxa |>
#   name_backbone_checklist() |>  # match to backbone
#   filter(!matchType == "NONE") |>
#   pull(usageKey)
#
# # download the data
# occ_download(
#   pred_in("taxonKey", taxon_keys), # important to use pred_in
#   pred("hasCoordinate", TRUE),
#   pred("hasGeospatialIssue", FALSE),
#   format = "SIMPLE_CSV"
# )
#
# # Citation Info:
# #   Please always cite the download DOI when using this data.
# # https://www.gbif.org/citation-guidelines
# # DOI: 10.15468/dl.jpdgs9
# # Citation:
# #   GBIF Occurrence Download https://doi.org/10.15468/dl.jpdgs9 Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2023-06-07
#
# d <- occ_download_get('0014400-230530130749713', path = "data/raw_data/gbif/", overwrite = TRUE)
# gbif_raw <- occ_download_import(d)
# write_csv(gbif_raw, "data/raw_data/gbif/gbif_raw.csv")


## Aprox 1.
ae <- occ_search(scientificName = "Androcymbium europaeum")
ce <- occ_search(scientificName = "Colchicum europaeum")

df <- bind_rows((ae$data |> as.data.frame()),
                (ce$data |> as.data.frame())) |>
  dplyr::select(scientificName,decimalLatitude,decimalLongitude) |> as.data.frame()

# N records by taxa
df |> group_by(scientificName) |> count()

# ntotal records
nrow(df)
# 344

# nrecords with valid coordinates
df |> filter(!is.na(decimalLatitude)) |> group_by(scientificName) |> count()
# 235

# n records with unique coordinates
df |> filter(!is.na(decimalLatitude)) |> dplyr::select(-scientificName) |> unique() |> nrow()
# 139

# convert to spatial object
df_spat <- df |>
  filter(!is.na(decimalLatitude)) |>
  mutate(id = 1) |>
  group_by(scientificName, decimalLatitude, decimalLongitude) |>
  summarise(n = length(id)) |>
  st_as_sf(
    coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE)

# Filter by boundary (valid points)
# get boundary of Andalusia
and <- esp_get_ccaa(ccaa = "Andalucia",  resolution = "01", epsg = 4326)

gbif <- st_intersection(df_spat, (and |> st_as_sf()))




























# Elevation data
## Generate a bbox to download the elevation data
b <- st_as_sfc(st_bbox(c(xmin = -3.5, xmax = -1.5, ymax = 37.5, ymin = 36.5), crs = st_crs(4326)))
elevation <- elevatr::get_elev_raster(b, z = 9)
elev <- terra::rast(elevation)
names(elev) <- "alt"


# Crop by mask
r <- mask(elev,
          (and |> terra::vect())
)

## Create hillshade effect
slope <- terrain(r, "slope", unit = "radians")
aspect <- terrain(r, "aspect", unit = "radians")
hill <- shade(slope, aspect, 30, 270)

# normalize names
names(hill) <- "shades"



## Read FAME data



## MAP


pal_greys <- hcl.colors(1000, "Grays")

ggplot() +
  geom_spatraster(data = hill) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  geom_sf(data = fame, fill="springgreen4", color = "springgreen4") +
  geom_sf(data = and, fill = "transparent", col = "black") +
  geom_sf(data = gbif_filter, fill="blue", col = "blue", size = .75, shape = 19) +
  # geom_sf(data = b, fill = "transparent") +
  # geom_sf(data = b, fill = "transparent", color="red", size = 7, shape = 21) +
  # geom_sf(data = bbox, fill="red") +
  coord_sf(
    xlim = c(-2.8,-1.9),
    ylim = c(36.6, 37.1)
  ) + theme_bw() +
  theme(legend.position = "none",
        panel.grid = element_blank())



library(mapSpain)
library(sf)
library(tidyverse)





url <- http://www.juntadeandalucia.es/medioambiente/mapwms/REDIAM_mapa_sombras_acimut_315?request=GetCapabilities&service=WMS


zona <- esp_get_prov(c("Granada", "Almeria")) |>
  st_transform(3857)



q <- "http://www.juntadeandalucia.es/medioambiente/mapwms/REDIAM_mapa_sombras_acimut_315?"
opts <- list(
  service = "WMS", # Common to all WMS
  version = "1.1.1", # Common to all WMS
  request = "GetMap", # Common to all WMS
  format = "image/png", # Adapt the format
  transparent = "false", # Depends of what you want to all WMS
  layers = "mapa_sombras_2_315", # Specific of your WMS
  SRS = "EPSG:3857", # Mostly this value, worth checking
  width = 512,
  height = 512,
  bbox = "{bbox}" # This is needed for the internals
)

url <- paste0(q, paste0(names(opts), "=", values = opts, collapse = "&"))

url

# Hijack mapSpain internals
# Trick a df
df <- data.frame(
  field = "url_static",
  value = url
)

# Note that I use ::: instead of :: to get access to the internal functions
# All params needed
tiles <- mapSpain:::getwms(
  x = zona,
  provs = df,
  cache_dir = "./test",
  update_cache = FALSE,
  res = 512,
  verbose = FALSE,
  transparent = TRUE,
  options = list()
)



my_wms <- list(
  id = "IDEAndalucia",
  q =
    paste0(
      "https://www.ideandalucia.es/wms/ortofoto2016?",
      "request=GetMap&service=WMS&version=1.1.1",
      "&format=image/png&srs=epsg:3857",
      "&layers=ortofotografia_2016_pancromatico&styles="
    ))


my_wms <- esp_make_provider(
  id = "ww",
  q = "http://www.juntadeandalucia.es/medioambiente/mapwms/REDIAM_mapa_sombras_acimut_315?",
  service = "WMS",
  layers = "mapa_sombras_2_315"
)



gettile <- esp_getTiles(zona, my_wms, bbox_expand = 0.5)
tidyterra::autoplot(gettile)

tidyterra::autoplot(gettile) +
  ggplot2::geom_sf(data = , fill = NA, color = "white", linewidth = 3)





# Plot with tidyterra
library(tidyterra)

autoplot(tiles) +
  geom_sf(data = granada, color = "red", fill = NA, linewidth = 1)




custom_wms <- esp_make_provider(
  id = "iiii",
  q = "http://www.juntadeandalucia.es/medioambiente/mapwms/REDIAM_mapa_sombras_acimut_315?",
  service = "WMS",
  version = "1.3.0",
  format = "image/png",
  layers = "mapa_sombras_2_315"
)

custom_wms_tile <- esp_getTiles(zona, custom_wms)

autoplot(custom_wms_tile) +
  geom_sf(data = zona, fill = NA, color = "red")


x <- esp_get_prov(prov = "Almería", epsg = 3857)

my2 <- esp_make_provider(
  id = "dd",
  q = "https://wmts-mapa-lidar.idee.es/lidar?service=WMTS",
  service = "WMS",
  layers = "EL.GridCoverageDSM"
)

gettile <- esp_getTiles(b, type = "LIDAR")

tidyterra::autoplot(gettile) +
  ggplot2::geom_sf(data = x, fill = NA, color = "white", linewidth = 3)


https://wmts-mapa-lidar.idee.es/lidar?service=WMTS
EL.GridCoverageDSM

&request=GetTile&version=1.0.0&Format=image/png&layer=&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}


segovia <- esp_get_prov_siane("almeria", epsg = 3857)
tile2 <- esp_getTiles(b, type = "LiDAR", zoom = 18)

library(tidyterra)
ggplot() +
 # geom_spatraster_rgb(data = tile2) +
  geom_sf(data = fame, fill="purple", color = "purple") +
  geom_sf(data = gbif, fill="black", col = "white", size = 2, shape = 21) +
  geom_sf(fill = NA) +
  coord_sf(
    xlim = bb[c(1,3)],
    ylim = bb[c(2,4)]
  ) +
  theme_bw() +
  theme(legend.position = "none",
        panel.grid = element_blank())



ggplot() +
  geom_spatraster(data = hill) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  geom_sf(data = fame, fill="springgreen4", color = "springgreen4") +
  geom_sf(data = and, fill = "transparent", col = "black") +
  geom_sf(data = gbif_filter, fill="blue", col = "blue", size = .75, shape = 19) +
  # geom_sf(data = b, fill = "transparent") +
  # geom_sf(data = b, fill = "transparent", color="red", size = 7, shape = 21) +
  # geom_sf(data = bbox, fill="red") +
  coord_sf(
    xlim = c(-2.8,-1.9),
    ylim = c(36.6, 37.1)
  ) + theme_bw() +
  theme(legend.position = "none",
        panel.grid = element_blank())







> st_bbox(segovia)
xmin      ymin      xmax      ymax
-349563.1 4292056.4 -181461.8 4567650.7




coord_sf(
  xlim = c(-2.8,-1.9),
  ylim = c(36.6, 37.1)
)




bbox <- st_bbox(event) |>
  st_as_sfc() |>
  st_sf()
st_crs(bbox) <- st_crs(4326)

amoladeras <- st_centroid(bbox)

b <- st_bbox(c(xmin=-2.8, ymin=36.6, xmax=-1.9, ymax=37.1), crs = 4326) |>
  st_as_sfc() |>
  st_sf() |>
  st_transform(3857)

bb <- st_bbox(b)


|>
  st_bbox()






f <-
ft <- f |> st_as_sfc() |>
  st_transform(3857)


st_bbox(segovia)

# Caountry limits
### Spain boundary
spa <- gisco_get_countries(
  spatialtype = "RG",
  resolution = '01',
  epsg = "4326",
  country = "ESP"
)




# Map

## Prepare elevation







pal_greys <- hcl.colors(1000, "Grays")








# Map
ggplot() +
  geom_spatraster(data = hill) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA)







all_countries <- gisco_get_countries(
  resolution = res,
  epsg = target_crs,
  spatialtype = "RG"
)



aedf <- st_as_sf(
  (ae$data |>
     as.data.frame() |>
     dplyr::filter(!is.na(decimalLatitude))
   ),
  coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE)


cedf <- st_as_sf(
  (ce$data |>
     as.data.frame() |>
     dplyr::filter(!is.na(decimalLatitude))
  ),
  coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE)




# Prepare data
dwc_event <- vroom::vroom("data/dwca/events.csv") |>
  filter(is.na(parentEventID)) |>
  dplyr::select(-'...1') |>
  mutate()

event <- st_as_sf(dwc_event, wkt = "footprintWKT", crs = st_crs(25830)) |>
  st_transform(4326)

bbox <- st_bbox(event) |>
  st_as_sfc() |>
  st_sf()
st_crs(bbox) <- st_crs(4326)

amoladeras <- st_centroid(bbox)

b <- bbox |>
  st_transform("+proj=utm +zone=30 +ellps=WGS84") |>
  st_buffer(dist = 1500, endCapStyle = "SQUARE") |>
  st_transform(4326)



ccaa <- esp_get_ccaa(
  moveCAN = FALSE, resolution = res,
  epsg = target_crs
)




res <- "01"

# Same crs
target_crs <- 4326

all_countries <- gisco_get_countries(
  resolution = res,
  epsg = target_crs,
  spatialtype = "RG"
)

pal_greys <- hcl.colors(1000, "Grays")

ggplot() +
  # geom_spatraster(data = hill) +
  # scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  geom_sf(data = fame, fill="springgreen4", color = "springgreen4") +
  geom_sf(data = all_countries, fill = "transparent", col = "black") +
  geom_sf(data = gbif_filter, fill="blue", col = "blue", size = .75, shape = 19) +
  geom_sf(data = b, fill = "transparent") +
  # geom_sf(data = b, fill = "transparent", color="red", size = 7, shape = 21) +
  # geom_sf(data = bbox, fill="red") +
  coord_sf(
    xlim = c(-2.8,-1.9),
    ylim = c(36.6, 37.1)
  ) + theme_bw() +
  theme(legend.position = "none",
        panel.grid = element_blank())











library(tidyverse)





ggplot() +
  borders(regions = c("Morocco", "Spain", "Portugal", "France")) +
  coord_fixed(xlim = c(-10, 2), ylim = c(36, 44), ratio = 1.3) +
  ylab("Latitude") + xlab("Longitude") +
  theme_bw() +
  theme(
    panel.grid = element_blank()
  )


install.packages("ggmapinset")



 +
  geom_sf(data = aedf, fill = "darkgoldenrod1", col = "black", size = 2, shape = 21) +
  geom_sf(data = cedf, fill = "red", col = "black", size = 2, shape = 21) +

  coord_sf(
    xlim = c(-3,-1.9),
    ylim = c(36.5, 37.2)
  ) + theme_bw() +
  geom_sf(data = fame, fill="gray")




##### Test datos AE


# Ojo en la REDIAM en la capa Localizacion Flora
# https://portalrediam.cica.es/descargas?path=%2F04_RECURSOS_NATURALES%2F01_BIODIVERSIDAD%2F02_FLORA%2F02_FLORA_INTERES%2FLocalizacionFlora
# no aparece A. europaeum, ni Colchicum europaeum, ni A. gramineum, ni C. gramineum
g <- vroom::vroom("/Users/ajpelu/Downloads/dwca-rediam-flora-v1.3/occurrence.txt")
gae <- g |> filter(genus == "Androcymbium")

buf <- st_read("/Users/ajpelu/Downloads/Shapes/LocalizacionFlora.shp")


