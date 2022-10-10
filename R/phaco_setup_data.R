#' phaco_setup_data
#'
#' @return
#' @import rappdirs
#' @import readr
#' @import utils
#'
#' @export
#'
#' @examples
#' phaco_setup_data()

phaco_setup_data <- function(){
  # creer le chemin en fonction du systeme d'exploitation (Mac, Windows ou Linux)

  path_data<- user_data_dir("phacochr")
  message(paste0("Importation des données dans le dossier :", path_data))
  #dir.create()
  # Telecharger les donnees
  download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr.zip",paste0(path_data,"/data_phacochr.zip"))
  # dezippe et supprimer le fichier zip telecharge
  unzip(paste0(path_data,"/data_phacochr.zip"),exdir= path_data)
  file.remove(paste0(path_data,"/data_phacochr.zip"))
  message(paste0("Données importées"))
}
