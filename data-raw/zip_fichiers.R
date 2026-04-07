
#  Ziper les fichiers

path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/"))


zip::zip(
  zipfile = file.path(path_data, "phacochr_data_autre.zip"),
  files = c("CHARLEROI",
            "IBSA",
            "OBSS",
            "BeST",
            "STATBEL/autres" ,
            "STATBEL/code_postaux",
            "STATBEL/communes",
            "STATBEL/prenoms"),
  root = path_data
)

zip::zip(
  zipfile = file.path(path_data, "phacochr_data_statbel_secteurs.zip"),
  files = "STATBEL/secteurs_statistiques",
  recurse = TRUE,
  root = path_data
)

# Copie des fichiers dans le dossier phacochr_data pour l'upload
file.copy(
  from = paste0(path_data, "phacochr_data_statbel_secteurs.zip"),
  to   = "../phacochr_data/data_phacochr/phacochr_data_statbel_secteurs.zip"
)

file.copy(
  from = paste0(path_data, "phacochr_data_autre.zip"),
  to   = "../phacochr_data/data_phacochr/phacochr_data_autre.zip"
)

# #Test unzip
# zip::unzip(paste0(path_data,"phacochr_data_statbel_secteurs.zip"),
#            exdir = path_data)
#
# zip::unzip(paste0(path_data,"phacochr_data_autre.zip"),
#            exdir = path_data)


