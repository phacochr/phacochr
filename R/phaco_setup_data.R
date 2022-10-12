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
  start_time <- Sys.time()
  path_data<- user_data_dir("phacochr")
  dir.create(path_data, showWarnings = F)
  cli_progress_step(paste0("Cr","\u00e9","ation du dossier :", path_data))
  # Telecharger les donnees
  cli_progress_step(paste0("T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es"))
   download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr.zip",paste0(path_data,"/data_phacochr.zip"))

  # dezippe et supprimer le fichier zip telecharge
  cli_progress_step(paste0("D","\u00e9","compression des donn","\u00e9","es ..."))
  unzip(paste0(path_data,"/data_phacochr.zip"),exdir= path_data)
  file.remove(paste0(path_data,"/data_phacochr.zip"))
  cli_progress_done()
  cli_alert_success(paste0("Importation des donn","\u00e9","es OK: PhacochR pr","\u00ea","t ","\u00e0", " g","\u00e9","ocoder."))


}
