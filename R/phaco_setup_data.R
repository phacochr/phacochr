#' phaco_setup_data
#'
#' @import rappdirs
#' @import readr
#' @import utils
#' @import cli
#'
#' @export
#'
#' @examples
#' phaco_setup_data()

phaco_setup_data <- function(){
  # creer le chemin en fonction du systeme d'exploitation (Mac, Windows ou Linux)
  cat(paste0(" -- Chargement des donn","\u00e9","es pour PhacochR --"))
  start_time <- Sys.time()

  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr")) # bricolage pour windows
  dir.create(path_data, showWarnings = F)
  cat(paste0("\n","\033[K","\u2714", " Cr","\u00e9","ation du dossier : ", path_data))

  # Telecharger les donnees
  cat(paste0("\n","\u29D7"," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es ...","\n"))
   download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_best.zip",
                 paste0(path_data,"/phacochr_data_best.zip"))
   download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_statbel_urbis.zip",
                 paste0(path_data,"/phacochr_data_statbel_urbis.zip"))
   cat(paste0("\r","\u2714"," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es"))

  # dezippe et supprimer le fichier zip telecharge
  cat(paste0("\n","\u29D7"," D","\u00e9","compression des donn","\u00e9","es ..."))
  unzip(paste0(path_data,"/phacochr_data_best.zip"),exdir= path_data)
  unzip(paste0(path_data,"/phacochr_data_statbel_urbis.zip"),exdir= path_data)
  # supression des fichiers .zip
  file.remove(paste0(path_data,"/phacochr_data_best.zip"))
  file.remove(paste0(path_data,"/phacochr_data_statbel_urbis.zip"))
  cat(paste0("\r","\u2714"," D","\u00e9","compression des donn","\u00e9","es."))


  cli_progress_done()
  cat(paste0("\n","\u2714"," Importation des donn","\u00e9","es OK: PhacochR pr","\u00ea","t ","\u00e0", " g","\u00e9","ocoder."))


}
