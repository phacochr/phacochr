#' phaco_data : Charger les données qui sont utilisées dans phacochr
#'
#' Cette fonction permet de charger les données utilisées par phacochr et qui sont stockée dans l'ordinateur.
#'
#' @param data Nom des données à charger: "rues" (les rues BeST prétaitées pour l'usage de phacochr), "adresses" (les adresses BeST prétaitées pour l'usage de phacochr), "sec" (les secteurs statistiques), "communes_bel" (les communes de Belgiques), "provinces" (les provinces de Belgiques), "regions" (les régions de Belgiques), "belgique" (les limites de la Belgiques), "rbc" (la Région de Bruxelles-Capitale), "communes_bxl" (les communes de la Région de Bruxelles-Capitale), "quartiers_bxl" (les quartiers monitoring de Bruxelles), "rbc" (les limites de la Région de Bruxelles-Capitale), "sec_bxl" (les secteurs statistiques de la Région des Bruxelles-Capitale). Par défaut: NULL

#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @import readr
#' @import purrr
#' @import readxl
#' @import sf
#' @import rappdirs
#'
#' @export
#'
#' @export
#' @examples
#' \dontrun{
#' # Rues BeST
#' rues <- phaco_data("rues")
#' # Adresses BeST
#' adresses <- phaco_data("adresses")
#' # Secteurs Statistiques
#' sec<-phaco_data("sec")
#' # Communes Belgique
#' communes_bel <- phaco_data("communes_bel")
#' # Provinces
#' provinces <- phaco_data("provinces")
#' # Regions
#' regions <- phaco_data("regions")
#' # Belgique
#' belgique <- phaco_data("belgique")
#' # Région de Bruxelles-Capital
#' rbc <- phaco_data("rbc")
#' # Communes de la Région de Bruxelles-Capitale
#' communes_bxl <- phaco_data("communes_bxl")
#' #  Quartier monitoring de la Région de Bruxelles-Capitale
#' quartiers_bxl <- phaco_data("quartiers_bxl")
#' # Limites de la Région de Bruxelles-Capital
#' rbc <- phaco_data("rbc")
#' # Secteurs Statistiques de la Région de Bruxelles-Capitale
#' sec_bxl <- phaco_data("sec_bxl")
#' }
#'
#'



phaco_data <- function(data=NULL,
                       path_data = NULL) {
# CHECk ERROR -----
  if(is.null(data)) {
    cat("\n")
    stop(paste0("\u2716 Indiquez quel jeux de donn","\u00e9","es vous voulez charger. Par exemple communes_bel <- phaco_data(data= \"communes_bel\") "))}

  if(sum(data %in% c("rues", "adresses", "sec", "communes_bel", "provinces", "regions", "belgique", "rbc", "communes_bxl", "quartiers_bxl", "rbc", "sec_bxl")) == 0) {
    cat("\n")
    stop(paste0("\u2716"," data doit prendre une des valeurs : \"rues\", \"adresses\", \"sec\", \"communes_bel\", \"provinces\", \"regions\", \"belgique\", \"rbc\", \"communes_bxl\", \"quartiers_bxl\", \"rbc\", \"sec_bxl\"'"))
  }

# PATH -----
 if(is.null(path_data)){path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochrdev"),"/data_phacochr/"))}

# DATA -----
#  BeST
  if(data=="rues"){result<- st_read(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"))}
  if(data=="adresses"){
    result <- list.files(path = paste0(path_data,"BeST/PREPROCESSED/"), pattern = "^data_arrond_PREPROCESSED.*\\.csv$", full.names = TRUE) %>%
      map_dfr(read_delim, delim = ";", progress= F#,
              #col_types = cols(.default = col_character())
              )}

# STATBEL
  if(data=="sec"){result<- st_read(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"))}
  if(data=="communes_bel"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"))}
  if(data=="provinces"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"))}
  if(data=="regions"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"))}
  if(data=="belgique"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg"))}
  if(data=="rbc"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"))}
  if(data=="communes_bxl"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"))}
  if(data=="quartiers_bxl"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_quartiers_PREPROCESSED.gpkg"))}
  if(data=="rbc"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"))}
  if(data=="sec_bxl"){result<- st_read(paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"))}

  return(result)
}

