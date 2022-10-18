#' phaco_map_i
#'
#' @param FULL_GEOCODING_sf un objet sf a cartographier
#' @param title_carto le titre de la carte produite
#' @param filter_bxl afficher uniquement bruxelles
#' @param zoom_geocoded zoomer sur les points
#'
#' @import dplyr
#' @import sf
#' @import tmap
#' @import rappdirs
#'
#' @export
#'
#'
phaco_map_i <- function(FULL_GEOCODING_sf,
                        title_carto = paste0("adresses geocodees"),
                        filter_bxl = FALSE,
                        zoom_geocoded = FALSE) {

  # NOTE : remettre l'id = name_to_show

  # Definition du chemin ou se trouve les donnees
  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows

  # Ne pas lancer la fonction si les fichiers ne sont pas presents (cad qu'ils ne sont, en tout logique, pas installes)
  if(sum(
    file.exists(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg")
    )
  ) != 6) {
    stop(paste0("\u2716"," les fichiers ne sont pas install","\u00e9","s : lancez phaco_setup_data()"))
  }

  # Filtrer ou pas BXL
  if (filter_bxl == TRUE){
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf %>%
      filter(cd_rgn_refnis == "04000")
  } else {
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf
  }

  # * Type de carte : "static" ou "interactif"
  # Les deux types sont programmes dans le script ci-dessous, mais en static tmap produit des resultats differents selon que l'on est sous windows ou linux avec les memes parametres => pas ok
  # tmap est donc utilise uniquement pour produire des cartes interactives
  mode_carto <- "interactif"


  # 1. BRUXELLES ============================================================================================================================

  # S'il y a des points uniquement a Bruxelles
  if ((str_detect(paste(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)]), collapse = " "), "04000")) & (length(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)])) == 1)){


    # a) Geopackages --------------------------------------------------------------------------------------------------------------------------

    BXL_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"), quiet=T)
    BXL_SS <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"), quiet=T)
    BRUXELLES <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"), quiet=T)


    # b) Carto --------------------------------------------------------------------------------------------------------------------------------

    if(zoom_geocoded == FALSE){ # je cree une bbox pour delimiter les limites de la carte
      bbox_bxl <- st_bbox(BXL_communes)
    }
    if(zoom_geocoded == TRUE){ # Si je veux un zoom sur les points
      bbox_bxl <- st_bbox(FULL_GEOCODING_sf_carto)
    }

    tmap_mode("view") # Le mode dans le cas d'une carte interactive
    Carto_map <- tm_shape(BXL_communes, bbox = bbox_bxl) +
      tm_borders("black", lwd = 1, lty = "dashed") +
      tm_shape(BRUXELLES) +
      tm_borders("black", lwd = 1.5, lty = "dashed") +
      tm_shape(FULL_GEOCODING_sf_carto, bbox = bbox_bxl) +
      tm_dots("#d61d5e",
              size = 0.01,
              shape = 16,
              border.col = "#d61d5e",
              alpha = 1) +
      tm_layout(title = paste("Cartographie :", title_carto)) +
      tm_basemap(leaflet::providers$CartoDB.Positron) +
      tm_basemap(leaflet::providers$CartoDB.PositronNoLabels) +
      tm_basemap(leaflet::providers$OpenStreetMap) +
      tm_view(bbox = bbox_bxl)

    Carto_map


  # 2. FLANDRE/WALLONIE =====================================================================================================================

  # S'il y a des points en Flandre ou en Wallonie
  } else {

    # a) Geopackages --------------------------------------------------------------------------------------------------------------------------

    BE_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"), quiet=T)
    BE_provinces <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"), quiet=T)
    BE_regions <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"), quiet=T)
    BELGIQUE <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg"), quiet=T)


    # b) Carto --------------------------------------------------------------------------------------------------------------------------------

    if(zoom_geocoded == FALSE){ # je cree une bbox pour delimiter les limites de la carte
      bbox_belgique <- st_bbox(BE_regions)
    }
    if(zoom_geocoded == TRUE){ # Si je veux un zoom sur les points
      bbox_belgique <- st_bbox(FULL_GEOCODING_sf_carto)
    }

    tmap_mode("view") # Le mode dans le cas d'une carte interactive
    Carto_map <- tm_shape(BE_provinces, bbox = bbox_belgique) +
      tm_borders("black", lwd = 1, lty = "dashed") +
      #tm_shape(BE_regions) +
      #tm_borders("black", lwd = 1, lty = "dashed") +
      tm_shape(BELGIQUE) +
      tm_borders("black", lwd = 1, lty = "dashed") +
      tm_shape(FULL_GEOCODING_sf_carto, bbox = bbox_belgique) +
      tm_dots("#d61d5e",
              size = 0.005,
              shape = 16,
              border.col = "#d61d5e",
              alpha = 1) +
      tm_basemap(leaflet::providers$CartoDB.Positron) +
      tm_basemap(leaflet::providers$CartoDB.PositronNoLabels) +
      tm_basemap(leaflet::providers$OpenStreetMap) +
      tm_view(bbox = bbox_belgique) +
      tm_layout(title = paste("Cartographie :", title_carto))

    Carto_map

  }
}
