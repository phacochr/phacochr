
#' phaco_setup_data
#'
#'
#' @return
#' @import rappdirs
#'
#' @export
#'
#' @examples
#'phaco_setup_data()

phaco_setup_data <- function(){
  library(rappdirs)
  # créer le chemin en fonction du système d'exploitation (Mac, Windows ou Linux)
  path_data<- user_data_dir("phacochr")
  #dir.create()
  # Télécharger les données
  download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr.zip",paste0(path_data,"/data_phacochr.zip"))
  # dézippé et supprimer le fichier zip téléchargé
  unzip(paste0(path_data,"/data_phacochr.zip"),exdir= path_data)
  file.remove(paste0(path_data,"/data_phacochr.zip"))
}
