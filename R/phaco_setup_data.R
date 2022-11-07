#' phaco_setup_data : Téléchargement et installation des données pour géocoder
#'
#' Cette fonction permet d'installer sur l'ordinateur les fichiers nécessaires pour le geocodage des adresses.
#'
#' @import rappdirs
#' @import utils
#'
#' @export
#'
#' @examples
#' \donttest{
#' phaco_setup_data()
#' }

phaco_setup_data <- function(){

  cat(colourise(paste0(" -- Chargement des donn","\u00e9","es pour PhacochR --"), fg="light green" ))
  start_time <- Sys.time()

  # Creer le chemin en fonction du systeme d'exploitation (Mac, Windows ou Linux)
  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr")) # bricolage pour windows
  cat(paste0("\n",colourise("\u2714", fg="green"), " Cr","\u00e9","ation du dossier : ", path_data))
  dir.create(path_data, recursive = T, showWarnings = F)

  # Test si le repertoire a ete cree
  if(dir.exists(path_data) == FALSE) {
    cat("\n")
    stop(paste0("\u2716"," le dossier d'installation n'a pas pu", " \u00ea", "tre cr","\u00e9\u00e9", " : v","\u00e9","rifiez vos droits d'","\u00e9","criture sur le disque"))
  }

  # Telecharger les donnees

  options(timeout=300)

  cat(paste0("\n","\u29D7"," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es ...","\n"))
  download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_best.zip",
                paste0(path_data,"/phacochr_data_best.zip"))
  download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_statbel_urbis.zip",
                paste0(path_data,"/phacochr_data_statbel_urbis.zip"))

  # Test si les donnees ont ete telechargees
  if(sum(
    file.exists(paste0(path_data,"/phacochr_data_best.zip"),
                paste0(path_data,"/phacochr_data_statbel_urbis.zip")
                )
    ) != 2) {
    options(timeout=60)
    cat("\n")
    stop(paste0("\u2716"," les fichiers n'ont pas pu", " \u00ea", "tre download","\u00e9","s : relancez phaco_setup_data() ou v","\u00e9","rifiez votre connexion"))
  }

  cat(paste0("\r",colourise("\u2714", fg="green")," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es"))

  # dezippe et supprimer le fichier zip telecharge
  cat(paste0("\n","\u29D7"," D","\u00e9","compression des donn","\u00e9","es"))
  unzip(paste0(path_data,"/phacochr_data_best.zip"),exdir= path_data)
  unzip(paste0(path_data,"/phacochr_data_statbel_urbis.zip"),exdir= path_data)

  # supression des fichiers .zip
  file.remove(paste0(path_data,"/phacochr_data_best.zip"))
  file.remove(paste0(path_data,"/phacochr_data_statbel_urbis.zip"))

  cat(paste0("\r",colourise("\u2714", fg="green")," D","\u00e9","compression des donn","\u00e9","es"))

  cat(paste0("\n",colourise("\u2714", fg="green")," Importation des donn","\u00e9","es OK: PhacochR pr","\u00ea","t ","\u00e0", " g","\u00e9","ocoder."))

  options(timeout=60)

}
