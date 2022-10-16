#' phaco_map_s
#'
#' @param FULL_GEOCODING_sf un objet sf a cartographier
#' @param title_carto le titre de la carte produite
#' @param colonne_ponderation un poids pour les points a cartographier
#' @param filter_bxl afficher uniquement bruxelles
#' @param zoom_geocoded zoomer sur les points
#' @param nom_admin afficher les noms des entites administratives
#'
#' @import dplyr
#' @import sf
#' @import mapsf
#' @import rappdirs
#' @importFrom scales alpha
#'
#' @export
#'
#'
phaco_map_s <- function(FULL_GEOCODING_sf,
                        colonne_ponderation = NULL,
                        title_carto = paste0("adresses g","\u00e9","ocod","\u00e9","es"),
                        filter_bxl = FALSE,
                        zoom_geocoded = FALSE,
                        nom_admin = TRUE){

  # Filtrer ou pas BXL
  if (filter_bxl == TRUE){
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf %>%
      filter(cd_rgn_refnis == "04000")
  } else {
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf
  }

  # Je cree les variables necessaires
  if (!is.null(colonne_ponderation)) {
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf_carto %>%
      mutate(CARTO_weight = as.numeric(FULL_GEOCODING_sf_carto[[colonne_ponderation]]))
  } else {
    FULL_GEOCODING_sf_carto <- FULL_GEOCODING_sf_carto %>%
      mutate(CARTO_weight = 1)
  }

  # Definition du chemin ou se trouve les donnees
  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows


  # 1. BRUXELLES ============================================================================================================================

  # S'il y a des points uniquement a Bruxelles
  if ((str_detect(paste(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)]), collapse = " "), "04000")) & (length(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)])) == 1)){


    # a) Geopackages --------------------------------------------------------------------------------------------------------------------------

    BXL_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"))
    BXL_SS <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"))
    BRUXELLES <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"))


    # b) Carto --------------------------------------------------------------------------------------------------------------------------------

    mf_map(x = BXL_SS, col = "white", border = "gray85")
    mf_map(x = BXL_communes, col = NA, border = "gray40", lwd = 1.5, add = TRUE)
    mf_map(x = BRUXELLES, col = NA, border = "black", lwd = 2, add = TRUE)
    mf_map(x = FULL_GEOCODING_sf_carto,
           col = alpha("#d61d5e", FULL_GEOCODING_sf_carto$CARTO_weight*0.5),
           cex = 0.8,
           pch = 16,
           add = TRUE)
    if(nom_admin == TRUE){
      mf_label(
       x = st_point_on_surface(BXL_communes),
       var = "tx_munty_descr_fr",
       col= "#18707b",
       halo = TRUE,
       overlap = FALSE,
       lines = FALSE
     )
    }
    mf_layout(
      title = paste("Cartographie :", title_carto),
      credits = "Phacochr\nhttps://github.com/phacochr/phacochr",
      arrow = FALSE
    )
    mf_arrow(pos = "topright")


  # 2. FLANDRE/WALLONIE =====================================================================================================================

  # S'il y a des points en Flandre ou en Wallonie
  } else {

    # a) Geopackages --------------------------------------------------------------------------------------------------------------------------

    BE_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"))
    BE_provinces <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"))
    BE_regions <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"))
    #BELGIQUE <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg"))


    # b) Carto --------------------------------------------------------------------------------------------------------------------------------

    if(zoom_geocoded == TRUE){
      mf_init(FULL_GEOCODING_sf_carto) # Pour zoomer sur les points
      mf_map(x = BE_communes, col = "white", border = "gray92", add = TRUE)
    } else {
      mf_map(x = BE_communes, col = "white", border = "gray92")
    }
    mf_map(x = BE_provinces, col = NA, border = "gray60", lwd = 1.5, add = TRUE)
    mf_map(x = BE_regions, col = NA, border = "black", lwd = 2, add = TRUE)
    #mf_map(x = BELGIQUE, col = NA, border = "black", lwd = 2.5, add = TRUE)
    if(zoom_geocoded == TRUE){
      mf_map(x = FULL_GEOCODING_sf_carto,
           col = alpha("#d61d5e", FULL_GEOCODING_sf_carto$CARTO_weight*0.5),
           cex = 0.8,
           pch = 16,
           add = TRUE)
    } else {
      mf_map(x = FULL_GEOCODING_sf_carto,
             col = alpha("#d61d5e", FULL_GEOCODING_sf_carto$CARTO_weight*0.5),
             cex = 0.4,
             pch = 16,
             add = TRUE)
    }
    if(nom_admin == TRUE){
      mf_label(
       x = st_point_on_surface(BE_provinces),
       var = "tx_prov_descr_fr",
       col= "#18707b",
       halo = TRUE,
       overlap = FALSE,
       lines = FALSE
       )
    }
    mf_layout(
      title = paste("Cartographie :", title_carto),
      credits = "Phacochr\nhttps://github.com/phacochr/phacochr",
      arrow = FALSE
    )
    mf_arrow(pos = "topright")
  }

}
