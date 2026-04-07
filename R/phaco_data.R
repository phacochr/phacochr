#' phaco_data : Charger les données qui sont utilisées dans phacochr
#'
#' Cette fonction permet de charger les données utilisées par phacochr et qui sont stockée dans l'ordinateur.
#'
#' @param data Nom des données à charger: "rues" (les rues BeST prétaitées pour l'usage de phacochr), "adresses" (les adresses BeST prétaitées pour l'usage de phacochr), "sec" (les secteurs statistiques), "communes_bel" (les communes de Belgiques), "provinces" (les provinces de Belgiques), "regions" (les régions de Belgiques), "belgique" (les limites de la Belgiques), "rbc" (la Région de Bruxelles-Capitale), "communes_bxl" (les communes de la Région de Bruxelles-Capitale), "quartiers_bxl" (les quartiers monitoring de Bruxelles), "rbc" (les limites de la Région de Bruxelles-Capitale), "sec_bxl" (les secteurs statistiques de la Région des Bruxelles-Capitale). Par défaut: NULL
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @export
#'
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

  if(sum(data %in% c("rues", "adresses",
                     "sec","sec2024","sec2025","sec2011",
                     "sec_bxl","sec_bxl2011", "sec_bxl2024", "sec_bxl2025",
                     "communes", "communes2011","communes2024","communes2025",
                     "communes_bxl", "communes_bxl2011","communes_bxl2024","communes_bxl2025",
                     "quartiers", "quartiers2011","quartiers2024", "quartiers2025",
                     "QSS_2024", "Bassins_2024",
                     "provinces", "regions", "belgique", "rbc")) == 0) {
    cat("\n")
    stop(paste0(
      "\u2716", " Dans phaco_data(\"data\") \"data\" doit prendre une des valeurs :\n",
      "\"rues\", \"adresses\",\n",
      "\"sec\",\"sec2024\",\"sec2025\",\"sec2011\",\n",
      "\"sec_bxl\",\"sec_bxl2011\", \"sec_bxl2024\", \"sec_bxl2025\",\n",
      "\"communes\", \"communes2011\",\"communes2024\",\"communes2025\",\n",
      "\"communes_bxl\", \"communes_bxl2011\",\"communes_bxl2024\",\"communes_bxl2025\",\n",
      "\"quartiers\", \"quartiers2011\",\"quartiers2024\", \"quartiers2025\",\n",
      "\"provinces\", \"regions\", \"belgique\", \"rbc\""
    ))
  }

# PATH -----
 if(is.null(path_data)){path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/"))}

# DATA -----
#  BeST
  if(data=="rues"){result<- readRDS(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.rds"))}
  if(data=="adresses"){
    result <- list.files(path = paste0(path_data,"BeST/PREPROCESSED/"), pattern = "^data_arrond_PREPROCESSED.*\\.rds$", full.names = TRUE) |>
      purrr::map_dfr(readRDS)
    }

# STATBEL
  if(data=="sec2011"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_2011_2017.rds"))}
  if(data=="sec2024"|data=="sec"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20240101.rds"))}
  if(data=="sec2025"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20250101.rds"))}

  if(data=="sec_bxl2011"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_2011_2017.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}
  if(data=="sec_bxl"|data=="sec_bxl2024"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20240101.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}
  if(data=="sec_bxl2025"){result<- readRDS(paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20250101.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}

  if(data=="communes2011"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2011.rds"))}
  if(data=="communes2024"|data=="communes"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2024.rds"))}
  if(data=="communes2025"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2025.rds"))}

  if(data=="communes_bxl2011"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2011.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}
  if(data=="communes_bxl2024"|data=="communes_bxl"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2024.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}
  if(data=="communes_bxl2025"){result<- readRDS(paste0(path_data,"STATBEL/communes/communes2025.rds")) |>
    filter(as.numeric(cd_rgn_refnis)==04000)}

  if(data=="quartiers2011"){result<- readRDS(paste0(path_data,"IBSA/quartiers2011.rds"))}
  if(data=="quartiers2024"|data=="quartiers"){result<- readRDS(paste0(path_data,"IBSA/quartiers2024.rds"))}
  if(data=="quartiers2025"){result<- readRDS(paste0(path_data,"IBSA/quartiers2025.rds"))}

  if(data=="QSS_2024"){result<- readRDS(paste0(path_data,"OBSS/QSS_2024.rds"))}
  if(data=="Bassins_2024"){result<- readRDS(paste0(path_data,"OBSS/Bassins_2024.rds"))}

  if(data=="provinces"){result<- readRDS(paste0(path_data,"STATBEL/autres/provinces.rds"))}
  if(data=="regions"){result<- readRDS(paste0(path_data,"STATBEL/autres/regions.rds"))}
  if(data=="belgique"){result<- readRDS(paste0(path_data,"STATBEL/autres/belgique.rds"))}
  if(data=="rbc"){result<- readRDS(paste0(path_data,"STATBEL/autres/rbc.rds"))}


  # WARNINGS

  if(data=="sec2011"){warning("Vous chargez les secteurs statistique 2011-2017 (Statbel).",call. = F)}
  if(data=="sec2024"|data=="sec"){warning("Vous chargez les secteurs statistique 2019-2024 (Statbel).",call. = F)}
  if(data=="sec2025"){warning("Vous chargez les secteurs statistique 2025-... (Statbel).",call. = F)}

  if(data=="sec_bxl2011"){warning("Vous chargez les secteurs statistique 2011-2017 (Statbel).",call. = F)}
  if(data=="sec_bxl2024"|data=="sec_bxl"){warning("Vous chargez les secteurs statistique 2019-2024 (Statbel).",call. = F)}
  if(data=="sec_bxl2025"){warning("Vous chargez les secteurs statistique 2025-... (Statbel).",call. = F)}

  if(data=="communes2011"){warning("Vous chargez les communes construites sur base des secteurs 2011-2017 (Statbel).",call. = F)}
  if(data=="communes2024"|data=="communes"){warning("Vous chargez les communes construites sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="communes2025"){warning("Vous chargez les communes construites sur base des secteurs 2025-... (Statbel).",call. = F)}

  if(data=="communes_bxl2011"){warning("Vous chargez les communes construites sur base des secteurs 2011-2017 (Statbel).",call. = F)}
  if(data=="communes_bxl2024"|data=="communes_bxl"){warning("Vous chargez les communes construites sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="communes_bxl2025"){warning("Vous chargez les communes construites sur base des secteurs 2025-... (Statbel).",call. = F)}

  if(data=="quartiers2011"){warning("Vous chargez les quartiers monitoring (IBSA) construits sur base des secteurs 2011-2017 (Statbel).",call. = F)}
  if(data=="quartiers2024"|data=="quartiers"){warning("Vous chargez les quartiers monitoring (IBSA) construits sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="quartiers2025"){warning("Vous chargez les quartiers monitoring (IBSA) construits sur base des secteurs 2025-... (Statbel).",call. = F)}



  return(result)
}




