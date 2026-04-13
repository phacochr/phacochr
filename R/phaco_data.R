#' phaco_data : Charger les donn<c3><a9>es qui sont utilis<c3><a9>es dans phacochr
#'
#' Cette fonction permet de charger les donn<c3><a9>es utilis<c3><a9>es par phacochr et qui sont stock<c3><a9>e dans l'ordinateur.
#'
#' @param data Cha<c3><ae>ne de caract<c3><a8>res indiquant le jeu de donn<c3><a9>es <c3><a0> charger.
#'   Les valeurs possibles sont :
#'   \itemize{
#'   \item \code{"rues"} : rues BeST pr<c3><a9>trait<c3><a9>es pour l'usage de \code{phacochr}
#'   \item \code{"adresses"} : adresses BeST pr<c3><a9>trait<c3><a9>es pour l'usage de \code{phacochr}
#'   \item \code{"sec"}, \code{"sec2024"} : secteurs statistiques Statbel (version 2019-2024)
#'   \item \code{"sec2025"} : secteurs statistiques Statbel (version 2025--...)
#'   \item \code{"sec2011"} : secteurs statistiques Statbel (version 2011-2017)
#'   \item \code{"sec_bxl"}, \code{"sec_bxl2024"} : secteurs statistiques de la R<c3><a9>gion de Bruxelles-Capitale (version 2019-2024)
#'   \item \code{"sec_bxl2025"} : secteurs statistiques de la R<c3><a9>gion de Bruxelles-Capitale (version 2025--...)
#'   \item \code{"sec_bxl2011"} : secteurs statistiques de la R<c3><a9>gion de Bruxelles-Capitale (version 2011-2017)
#'   \item \code{"communes"}, \code{"communes2024"} : communes de Belgique (version 2019--2024)
#'   \item \code{"communes2025"} : communes de Belgique (version 2025-...)
#'   \item \code{"communes2011"} : communes de Belgique (version 2011-2017)
#'   \item \code{"communes_bxl"}, \code{"communes_bxl2024"} : communes de la R<c3><a9>gion de Bruxelles-Capitale (version 2019-2024)
#'   \item \code{"communes_bxl2025"} : communes de la R<c3><a9>gion de Bruxelles-Capitale (version 2025-...)
#'   \item \code{"communes_bxl2011"} : communes de la R<c3><a9>gion de Bruxelles-Capitale (version 2011-2017)
#'   \item \code{"quartiers"}, \code{"quartiers2024"} : quartiers monitoring des quartiers (IBSA) sur base des secteurs statistiques (version 2019-2024)
#'   \item \code{"quartiers2025"} : quartiers monitoring des quartiers (IBSA) sur base des secteurs statistiques (version 2025-...)
#'   \item \code{"quartiers2011"} : quartiers monitoring des quartiers (IBSA) sur base des secteurs statistiques (version 2011-2017)
#'   \item \code{"couronnes"} : couronnes de Bruxelles (IBSA) sur base des secteurs statistiques (version 2019-2024)
#'   \item \code{"couronnes2024"} : couronnes de Bruxelles (IBSA) sur base des secteurs statistiques (version 2019-2024)
#'   \item \code{"couronnes2025"} : couronnes de Bruxelles (IBSA) sur base des secteurs statistiques (version 2025-...)
#'   \item \code{"qss"} : quartiers social-sant<c3><a9> (Vivalis) sur base des secteurs statistiques (version 2019-2024)
#'   \item \code{"bassins"} : bassins (Vivalis) sur base des secteurs statistiques (version 2019-2024)
#'   \item \code{"provinces"} : provinces de Belgique
#'   \item \code{"regions"} : r<c3><a9>gions de Belgique
#'   \item \code{"rbc"} : limites de la R<c3><a9>gion de Bruxelles-Capitale
#'   \item \code{"belgique"} : limites de la Belgique
#'   }
#'   Par d<c3><a9>faut, \code{data = NULL}.
#'
#' @param path_data Chemin absolu vers le dossier o<c3><b9> se trouve le donn<c3><a9>es. Par d<c3><a9>faut data_path = NULL et phacochr trouve le dossier d'installation choisi par d<c3><a9>faut.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Rues BeST
#' rues <- phaco_data("rues")
#'
#' # Adresses BeST
#' adresses <- phaco_data("adresses")
#'
#' # Secteurs statistiques
#' sec <- phaco_data("sec")
#' sec2011 <- phaco_data("sec2011")
#' sec2024 <- phaco_data("sec2024")
#' sec2025 <- phaco_data("sec2025")
#'
#' # Secteurs statistiques de Bruxelles
#' sec_bxl <- phaco_data("sec_bxl")
#' sec_bxl2011 <- phaco_data("sec_bxl2011")
#' sec_bxl2024 <- phaco_data("sec_bxl2024")
#' sec_bxl2025 <- phaco_data("sec_bxl2025")
#'
#' # Communes de Belgique
#' communes <- phaco_data("communes")
#' communes2011 <- phaco_data("communes2011")
#' communes2024 <- phaco_data("communes2024")
#' communes2025 <- phaco_data("communes2025")
#'
#' # Communes de Bruxelles
#' communes_bxl <- phaco_data("communes_bxl")
#' communes_bxl2011 <- phaco_data("communes_bxl2011")
#' communes_bxl2024 <- phaco_data("communes_bxl2024")
#' communes_bxl2025 <- phaco_data("communes_bxl2025")
#'
#' # IBSA
#' quartiers <- phaco_data("quartiers")
#' quartiers2011 <- phaco_data("quartiers2011")
#' quartiers2024 <- phaco_data("quartiers2024")
#' quartiers2025 <- phaco_data("quartiers2025")
#'
#' couronnes <- phaco_data("couronnes")
#' couronnes2024 <- phaco_data("couronnes2024")
#' couronnes2025 <- phaco_data("couronnes2025")
#'
#' # Vivalis
#' qss <- phaco_data("qss")
#' bassins <- phaco_data("bassins")
#'
#' # Autres niveaux administratifs
#' provinces <- phaco_data("provinces")
#' regions <- phaco_data("regions")
#' belgique <- phaco_data("belgique")
#' rbc <- phaco_data("rbc")
#'
#' Avec un chemin explicite vers les donn<c3><a9>es
#' sec <- phaco_data("sec", path_data = "/chemin/vers/data_phacochr/")
#' }



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
                     "qss", "bassins",
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
      "\"qss\", \"bassins\"\n",
      "\"couronnes\", \"couronnes2024\", \"couronnes2025\"\n",
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

  if(data=="provinces"){result<- readRDS(paste0(path_data,"STATBEL/autres/provinces.rds"))}
  if(data=="regions"){result<- readRDS(paste0(path_data,"STATBEL/autres/regions.rds"))}
  if(data=="belgique"){result<- readRDS(paste0(path_data,"STATBEL/autres/belgique.rds"))}
  if(data=="rbc"){result<- readRDS(paste0(path_data,"STATBEL/autres/rbc.rds"))}

  # IBSA
  if(data=="quartiers2011"){result<- readRDS(paste0(path_data,"IBSA/quartiers2011.rds"))}
  if(data=="quartiers2024"|data=="quartiers"){result<- readRDS(paste0(path_data,"IBSA/quartiers2024.rds"))}
  if(data=="quartiers2025"){result<- readRDS(paste0(path_data,"IBSA/quartiers2025.rds"))}

  if(data=="couronnes2024"|data=="couronnes"){result<- readRDS(paste0(path_data,"IBSA/couronnes2024.rds"))}
  if(data=="couronnes2025"){result<- readRDS(paste0(path_data,"IBSA/couronnes2025.rds"))}

  # OBSS
  if(data=="qss"){result<- readRDS(paste0(path_data,"OBSS/QSS_2024.rds"))}
  if(data=="bassins"){result<- readRDS(paste0(path_data,"OBSS/Bassins_2024.rds"))}


  # WARNINGS -----
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

  if(data=="qss"){warning("Vous chargez les quartiers social sant<c3><a9> (Vivalis) construits sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="bassins"){warning("Vous chargez les bassins (Vivalis) construits sur base des secteurs 2019-2024 (Statbel).",call. = F)}

  if(data=="couronnes"){warning("Vous chargez les couronnes (IBSA) construits sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="couronnes2024"){warning("Vous chargez les couronnes (IBSA) construits sur base des secteurs 2019-2024 (Statbel).",call. = F)}
  if(data=="couronnes2025"){warning("Vous chargez les couronnes (IBSA) construits sur base des secteurs 2025-... (Statbel).",call. = F)}

  return(result)
}
