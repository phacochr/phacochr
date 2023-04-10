#' phaco_map_s : Carte statique des résultats
#'
#' Cette fonction produit facilement une carte statique a partir de l'objet issu du geocodage.
#'
#' @param FULL_GEOCODING_sf L'objet sf à cartographier issu de phaco_geocode().
#' @param title_carto Le titre de la carte produite.
#' @param colonne_ponderation Un poids pour les points a cartographier.
#' @param filter_bxl Afficher uniquement Bruxelles.
#' @param aggreg_sector Procède à l'agrégation des points par secteur statistique pour réaliser la cartographie.
#' @param zoom_geocoded Zoomer sur les points.
#' @param nom_admin Afficher les noms des entités administratives sur la carte.
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
                        title_carto = "adresses geocodees",
                        filter_bxl = FALSE,
                        aggreg_sector = FALSE,
                        zoom_geocoded = FALSE,
                        nom_admin = TRUE){

  # Ne pas lancer la fonction si les arguments ne sont pas corrects
  # La logique : une boucle sur les arguments de la fonction stockes dans une liste (pour ne pas changer leur type : string, logical...)
  list_arg_logical <- list(filter_bxl = filter_bxl,
                           aggreg_sector = aggreg_sector,
                           zoom_geocoded = zoom_geocoded,
                           nom_admin = nom_admin)

  for (i in seq_along(list_arg_logical)) {
    if(length(list_arg_logical[[i]]) > 1) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_logical[i]), " doit etre un vecteur de longueur 1"))
    }
    if(!is.logical(list_arg_logical[[i]])) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_logical[i]), " doit etre une valeur logique"))
    }
  }

  # Ici plus de boucle, pas necessaire
  if(!is.null(colonne_ponderation)) {
    if(length(colonne_ponderation) > 1) {
      cat("\n")
      stop(paste0("\u2716 "," colonne_ponderation doit etre un vecteur de longueur 1"))
    }
    if(!is.character(colonne_ponderation)){
      cat("\n")
      stop(paste0("\u2716"," colonne_ponderation doit etre un vecteur string"))
    }
  }
  if(length(title_carto) > 1) {
    cat("\n")
    stop(paste0("\u2716 "," title_carto doit etre un vecteur de longueur 1"))
  }
  if(!is.character(title_carto)) {
    cat("\n")
    stop(paste0("\u2716"," title_carto doit etre un vecteur string"))
  }

  # Definition du chemin ou se trouve les donnees
  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows

  # Ne pas lancer la fonction si les fichiers ne sont pas presents (cad qu'ils ne sont, en toute logique, pas installes)
  if(sum(
    file.exists(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"),
                paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg")
    )
  ) != 7) {
    cat("\n")
    stop(paste0("\u2716"," les fichiers ne sont pas install","\u00e9","s : lancez phaco_setup_data()"))
  }

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

  # Si la colonne phaco_anonymous existe dans les donnees => agregation par secteur stat activee
  if("phaco_anonymous" %in% names(FULL_GEOCODING_sf_carto)){
    aggreg_sector <- TRUE
  }

  # On cree un calcul des effectifs par sect stat en cas d'anonymisation (joint avec BXL_SS ou BE_SS)
  if(aggreg_sector == TRUE){
    n_geocoding <- FULL_GEOCODING_sf_carto %>%
      as.data.frame() %>%
      select(-geometry) %>%
      group_by(cd_sector) %>%
      summarise(n_cd_sector = sum(CARTO_weight, na.rm = T)) %>%
      select(cd_sector, n_cd_sector)
  }


  # 1. BRUXELLES ============================================================================================================================

  # S'il y a des points uniquement a Bruxelles
  if ((str_detect(paste(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)]), collapse = " "), "04000")) & (length(unique(FULL_GEOCODING_sf_carto$cd_rgn_refnis[!is.na(FULL_GEOCODING_sf_carto$cd_rgn_refnis)])) == 1)){


    # a) Geopackages --------------------------------------------------------------------------------------------------------------------------

    BXL_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"), quiet=T)
    if(aggreg_sector == TRUE){
      BXL_SS <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"), quiet=T) %>%
        left_join(n_geocoding, by = "cd_sector") # Je joins les effectifs par sect stat
    } else {
      BXL_SS <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"), quiet=T)
    }
    BRUXELLES <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"), quiet=T)


    # b) Carto --------------------------------------------------------------------------------------------------------------------------------

    mf_map(x = BXL_SS, col = "white", border = "gray85")
    mf_map(x = BXL_communes, col = NA, border = "gray40", lwd = 1.5, add = TRUE)
    mf_map(x = BRUXELLES, col = NA, border = "black", lwd = 2, add = TRUE)
    if(aggreg_sector == TRUE){
      mf_map(
        x = suppressWarnings(st_point_on_surface(BXL_SS[!is.na(BXL_SS$n_cd_sector),])),
        var = "n_cd_sector",
        type = "prop",
        inches = 0.10,
        col = "#fa6096",
        border = "#a00b3f",
        leg_pos = "topleft",
        leg_title = "Nombre d'adresses",
        leg_val_rnd = 0,
        add = TRUE
      )
    } else {
      mf_map(x = FULL_GEOCODING_sf_carto,
             col = alpha("#d61d5e", FULL_GEOCODING_sf_carto$CARTO_weight*0.5),
             cex = 0.8,
             pch = 16,
             add = TRUE)
    }
    if(nom_admin == TRUE){
      mf_label(
       x = suppressWarnings(st_point_on_surface(BXL_communes)),
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

    BE_communes <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"), quiet=T)
    BE_provinces <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"), quiet=T)
    BE_regions <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"), quiet=T)
    if(aggreg_sector == TRUE){
      BE_SS <- st_read(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"), quiet=T, crs= 31370) %>%
        st_set_crs(31370) %>%
        st_zm(drop = TRUE) %>%
        left_join(n_geocoding, by = "cd_sector") # Je joins les effectifs par sect stat
    }
    #BELGIQUE <- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg"), quiet=T)


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
    if(aggreg_sector == TRUE){
      mf_map(
        x = suppressWarnings(st_point_on_surface(BE_SS[!is.na(BE_SS$n_cd_sector),])),
        var = "n_cd_sector",
        type = "prop",
        inches = 0.04,
        col = "#fa6096",
        border = "#a00b3f",
        leg_pos = "topleft",
        leg_title = "Nombre d'adresses",
        leg_val_rnd = 0,
        add = TRUE
      )
    } else {
      mf_map(x = FULL_GEOCODING_sf_carto,
             col = alpha("#d61d5e", FULL_GEOCODING_sf_carto$CARTO_weight*0.5),
             cex = 0.4,
             pch = 16,
             add = TRUE)
    }
    if(nom_admin == TRUE){
      mf_label(
       x = suppressWarnings(st_point_on_surface(BE_provinces)),
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
