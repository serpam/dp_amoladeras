# Distribution map
library(sf)
library(tidyverse)
library(tidyterra)
library(geodata)
library(elevatr)
library(terra)
library(giscoR)
library(mapSpain)
library(ggsn)
library(rnaturalearthdata)
library(cowplot)

### Read Data
## FAME 5 x 5
fame_utm <- st_read("data/geoinfo/atlas_5x5_andalucia.shp")
miteco_utm <- st_read("data/geoinfo/utm_miteco.shp")

# get boundary of Andalusia
and <- esp_get_ccaa(ccaa = "Andalucia",  resolution = "01", epsg = 4326)

# World data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Elevation data
## Generate a bbox to download the elevation data
b <- st_as_sfc(st_bbox(c(xmin = -3.5, xmax = -1.5, ymax = 37.5, ymin = 36.5), crs = st_crs(4326)))
elevation <- elevatr::get_elev_raster(b, z = 9)
elev <- terra::rast(elevation)
names(elev) <- "alt"


# Crop by mask
r <- mask(elev,
          (and |> terra::vect()))

## Create hillshade effect
slope <- terrain(r, "slope", unit = "radians")
aspect <- terrain(r, "aspect", unit = "radians")
hill <- shade(slope, aspect, 30, 270)

# normalize names
names(hill) <- "shades"


# Centroid of Amoladeras
ae <- st_read("data/geoinfo/amoladeras_parcelas.shp")
x <- ae |> st_transform(4326) |> st_bbox()

ae_centroid <- data.frame(
  long = mean(x[1],x[3]),
  lat = mean(x[2],x[4])
)




# Map
pal_greys <- hcl.colors(1000, "Grays")

aemap <- ggplot() +
  geom_spatraster(data = hill) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  geom_sf(data = fame_utm, fill=alpha("darkblue", 0.2), color = "darkblue", linewidth = .5) +
  geom_sf(data = miteco_utm, fill="transparent", color = "black", linewidth = .6) +
  geom_sf(data = and, fill = "transparent", col = "black", linewidth = .6) +
  # geom_sf(data = b, fill = "transparent") +
  # geom_sf(data = b, fill = "transparent", color="red", size = 7, shape = 21) +
  # geom_sf(data = bbox, fill="red") +
  coord_sf(
    xlim = c(-2.8,-1.8),
    ylim = c(36.6, 37.2)
  ) +
  geom_point(data = ae_centroid,
             aes(long, lat), colour = "red", size = 4) +
  theme_bw() +
  xlab("") + ylab("") +
  theme(legend.position = "none",
        panel.grid = element_blank()) +
  ggsn::north(location = "bottomright",
              scale = 0.8, symbol = 12,
              x.min = -2, x.max = -1.8, y.min = 36.6, y.max = 36.7) +
  ggsn::scalebar(location = "bottomright",
                 dist = 10, dist_unit = "km", transform = TRUE,
                 x.min = -2.4, x.max = -2, y.min = 36.6, y.max = 36.8,
                 st.bottom = FALSE, height = 0.075,
                 st.dist = 0.1, st.size = 3)




general_map <- ggplot() +
  geom_sf(data = world) +
  geom_rect(aes(xmin = -2.8, xmax = -1.8, ymin = 36.6, ymax = 37.2),
            color = "red", fill = NA) +
  xlim(-11, 5) +
  ylim(34, 45) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill = "white", size = 14),
        plot.background = element_rect(fill=alpha("white", .3), color=NA),
        axis.text = element_text(face = "bold", colour = "black")) +
  coord_sf(crs=4326,
           label_graticule = "NE")


#  theme(panel.background = element_rect(fill = "lightblue"))


### Composed Map
mapa_ae <- ggdraw(aemap) +
  draw_plot(
    general_map, x = 0.08, y = .65, width = 0.3, height = 0.3
  )

ggsave(mapa_ae,
       file="scripts/bdj/mapa_distribution.jpg",
       dpi = 600,
       device = "jpeg")













######
library(mapSpain)
almeria <- esp_get_munic(munic="Almería")


my_wms <- esp_make_provider(
  id = "A_test",
  q = "https://www.ideandalucia.es/wms/mta10r_2001-2013?",
  service = "WMS",
  layers = "mta10r_2001-2013"
)

gettile <- esp_getTiles(almeria, my_wms, bbox_expand = 0.5)

tidyterra::autoplot(gettile) +
  # ggplot2::geom_sf(data = ae, fill = NA, color = "white", linewidth = 3) +
  coord_sf(
    xlim = c(-2.3,-2.2),
    ylim = c(36.82, 36.9)
  )


base_pnoa <- esp_getTiles(almeria, "PNOA", bbox_expand = 0.1, zoommin = 1)




tile <-
  esp_getTiles(almeria,
               type = "IGNBase.Todo",
               zoommin = 1
  )


ggplot() +
  base_gglayer(ext)


library(basemaps)
set_defaults(map_service = "osm", map_type = "world_imagery")

ggplot() +
  basemap_gglayer(ae) +
  coord_sf()



basemap_plot(ae)
basemap_ggplot(ae)


  geom_spatraster_rgb(data = tile, maxcell = 10e6) +
  geom_sf(data = ae, fill=alpha("darkblue", 0.2), color = "darkblue", linewidth = .5)




  geom_sf(data = fame_utm, fill=alpha("darkblue", 0.2), color = "darkblue", linewidth = .5) +
  geom_sf(data = miteco_utm, fill="transparent", color = "black", linewidth = .6) +
  geom_sf(data = and, fill = "transparent", col = "black", linewidth = .6) +
  # geom_sf(data = b, fill = "transparent") +
  # geom_sf(data = b, fill = "transparent", color="red", size = 7, shape = 21) +
  # geom_sf(data = bbox, fill="red") +
  coord_sf(
    xlim = c(-2.8,-1.8),
    ylim = c(36.6, 37.2)
  ) +
  geom_point(data = ae_centroid,
             aes(long, lat), colour = "red", size = 4) +
  theme_bw() +
  xlab("") + ylab("") +
  theme(legend.position = "none",
        panel.grid = element_blank()) +
  ggsn::north(location = "bottomright",
              scale = 0.8, symbol = 12,
              x.min = -2, x.max = -1.8, y.min = 36.6, y.max = 36.7) +
  ggsn::scalebar(location = "bottomright",
                 dist = 10, dist_unit = "km", transform = TRUE,
                 x.min = -2.4, x.max = -2, y.min = 36.6, y.max = 36.8,
                 st.bottom = FALSE, height = 0.075,
                 st.dist = 0.1, st.size = 3)


