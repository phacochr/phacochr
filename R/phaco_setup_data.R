#' phaco_setup_data : Téléchargement et installation des données pour géocoder
#'
#' Cette fonction permet d'installer sur l'ordinateur les fichiers nécessaires pour le geocodage des adresses.
#'
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' phaco_setup_data()
#' }

phaco_setup_data <- function(path_data = NULL){

  cat(colourise(paste0(" -- Chargement des donn","\u00e9","es pour PhacochR --"), fg="light green" ))
  start_time <- Sys.time()

  # Creer le chemin en fonction du systeme d'exploitation (Mac, Windows ou Linux)
  if(is.null(path_data)){
    path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr")) # bricolage pour windows
  }

  cat(paste0("\n",colourise("\u2714", fg="green"), " Cr","\u00e9","ation du dossier : ", path_data))
  dir.create(path_data, recursive = T, showWarnings = F)

  # Test si le repertoire a ete cree
  if(dir.exists(path_data) == FALSE) {
    cat("\n")
    stop(paste0("\u2716"," le dossier d'installation n'a pas pu", " \u00ea", "tre cr","\u00e9\u00e9", " : v","\u00e9","rifiez vos droits d'","\u00e9","criture sur le disque"))
  }

  # On supprime les anciennes donnes de phacochr si l'utilisateur est OK
  if(utils::askYesNo(paste0("Voulez-vous supprimer les anciennes donn","\u00e9","es de phacochr ? Ces fichiers sont inutiles ", "\u00e0", " partir de phacochr 1.0"))){
    cat(paste0("\n","\u29D7"," Suppression des anciennes donn","\u00e9","es ...","\n"))

    phaco_rm_old_data()

    cat(paste0("\r",colourise("\u2714", fg="green")," Suppression des anciennes donn","\u00e9","es"))
  }

  # Telecharger les donnees

  options(timeout=300)

  cat(paste0("\n","\u29D7"," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es ...","\n"))

  utils::download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_statbel_secteurs.zip",
                paste0(path_data,"/phacochr_data_statbel_secteurs.zip"))
  utils::download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/phacochr_data_autre.zip",
                paste0(path_data,"/phacochr_data_autre.zip"))

  # Test si les donnees ont ete telechargees
  if(sum(
    file.exists(paste0(path_data,"/phacochr_data_statbel_secteurs.zip"),
                paste0(path_data,"/phacochr_data_autre.zip")
                )
    ) != 2) {
    options(timeout=60)
    cat("\n")
    stop(paste0("\u2716"," les fichiers n'ont pas pu", " \u00ea", "tre download","\u00e9","s : relancez phaco_setup_data() ou v","\u00e9","rifiez votre connexion"))
  }

  cat(paste0("\r",colourise("\u2714", fg="green")," T","\u00e9","l","\u00e9","chargement des donn","\u00e9","es"))

  # dezippe et supprimer le fichier zip telecharge
  cat(paste0("\n","\u29D7"," D","\u00e9","compression des donn","\u00e9","es"))

  utils::unzip(paste0(path_data,"/phacochr_data_statbel_secteurs.zip"),exdir= path_data)
  utils::unzip(paste0(path_data,"/phacochr_data_autre.zip"),exdir= path_data)


  # supression des fichiers .zip
  file.remove(paste0(path_data,"/phacochr_data_statbel_secteurs.zip"))
  file.remove(paste0(path_data,"/phacochr_data_autre.zip"))

  cat(paste0("\r",colourise("\u2714", fg="green")," D","\u00e9","compression des donn","\u00e9","es"))

  cat(paste0("\n",colourise("\u2714", fg="green")," Importation des donn","\u00e9","es OK: PhacochR pr","\u00ea","t ","\u00e0", " g","\u00e9","ocoder."))

  options(timeout=60)

}
