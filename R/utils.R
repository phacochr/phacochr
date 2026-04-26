#' Colourise text for display in the terminal.
#' Source: https://github.com/r-lib/testthat/blob/717b02164def5c1f027d3a20b889dae35428b6d7/R/colour-text.r
#'
#' If R is not currently running in a system that supports terminal colours
#' the text will be returned unchanged.
#'
#' Allowed colours are: black, blue, brown, cyan, dark gray, green, light
#' blue, light cyan, light gray, light green, light purple, light red,
#' purple, red, white, yellow
#'
#' @param text character vector
#' @param fg foreground colour, defaults to white
#'
#' @noRd
#'
colourise <- function(text, fg = "black") {
  term <- Sys.getenv()["TERM"]
  colour_terms <- c("xterm-color","xterm-256color", "screen", "screen-256color")
  if(!any(term %in% colour_terms, na.rm = TRUE)) {
    return(text)
  }
  col_escape <- function(col) {
    paste0("\033[", col, "m")
  }
  col <- .fg_colours[tolower(fg)]
  init <- col_escape(col)
  reset <- col_escape("0")
  paste0(init, text, reset)
}
.fg_colours <- c(
  "black" = "0;30",
  "blue" = "0;34",
  "green" = "0;32",
  "cyan" = "0;36",
  "red" = "0;31",
  "purple" = "0;35",
  "brown" = "0;33",
  "light gray" = "0;37",
  "dark gray" = "1;30",
  "light blue" = "1;34",
  "light green" = "1;32",
  "light cyan" = "1;36",
  "light red" = "1;31",
  "light purple" = "1;35",
  "yellow" = "1;33",
  "white" = "1;37"
)


#' Negation of %in%
#'
#' @description
#' `%ni%` is the negation of `%in%`. It returns `TRUE` for elements of `x`
#' that are not in `y`. `%!in%`, `%ni%` or `%notin%` are equivalent.
#'
#' @name notin
#'
#' @param x A vector
#' @param y A vector or list to match against
#'
#' @return A logical vector
#'
#' @examples
#' # Basic usage
#' 1:5 %ni% c(2, 4)
#' 1:5 %!in% c(2, 4)
#' 1:5 %notin% c(2, 4)
#'
#' @export
`%ni%` <- function(x, y) {
  !x %in% y
}

#' @rdname notin
#' @export
`%!in%` <- `%ni%`

#' @rdname notin
#' @export
`%notin%` <- `%ni%`


#' phaco_check_rds_data
#'
#' Internal function to check if rds files are installed
#'
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @return TRUE or FALSE.
#'
#' @noRd
#'
phaco_check_rds_data <- function(path_data = NULL) {

  if(is.null(path_data)){
    path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows
  }

  verif <- sum(
    file.exists(
      paste0(path_data, "BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_11.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_12.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_13.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_21.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_23.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_24.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_25.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_31.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_32.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_33.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_34.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_35.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_36.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_37.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_38.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_41.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_42.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_43.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_44.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_45.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_46.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_51.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_52.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_53.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_55.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_56.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_57.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_58.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_61.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_62.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_63.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_64.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_71.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_72.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_73.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_81.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_82.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_83.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_84.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_85.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_91.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_92.rds"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_93.rds"),
      paste0(path_data, "BeST/PREPROCESSED/table_commune_adjacentes.rds"),
      paste0(path_data, "BeST/PREPROCESSED/table_INS_recod_code_postal.rds"),
      paste0(path_data, "BeST/PREPROCESSED/table_postal_arrond.rds"),
      paste0(path_data, "BeST/PREPROCESSED/table_postal_com_name.rds"),
      paste0(path_data, "STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.rds")
    )
  ) == 49

  return(verif)

}


#' phaco_check_csv_data
#'
#' Internal function to check if (old) csv files are installed
#'
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @return TRUE or FALSE.
#'
#' @noRd
#'
phaco_check_csv_data <- function(path_data = NULL) {

  if(is.null(path_data)){
    path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows
  }

  verif <- sum(
    file.exists(
      paste0(path_data, "BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_11.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_12.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_13.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_21.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_23.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_24.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_25.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_31.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_32.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_33.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_34.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_35.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_36.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_37.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_38.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_41.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_42.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_43.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_44.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_45.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_46.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_51.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_52.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_53.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_55.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_56.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_57.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_58.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_61.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_62.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_63.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_64.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_71.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_72.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_73.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_81.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_82.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_83.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_84.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_85.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_91.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_92.csv"),
      paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_93.csv"),
      paste0(path_data, "BeST/PREPROCESSED/table_commune_adjacentes.csv"),
      paste0(path_data, "BeST/PREPROCESSED/table_INS_recod_code_postal.csv"),
      paste0(path_data, "BeST/PREPROCESSED/table_postal_arrond.csv"),
      paste0(path_data, "BeST/PREPROCESSED/table_postal_com_name.csv"),
      paste0(path_data, "STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv")
    )
  ) == 49

  return(verif)

}


#' phaco_rm_old_data
#'
#' Internal function to remove old data installed
#'
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
#'
#' @noRd
#'
phaco_rm_old_data <- function(path_data = NULL) {

  if(is.null(path_data)){
    path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows
  }

  file.remove(paste0(path_data, "BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_11.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_12.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_13.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_21.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_23.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_24.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_25.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_31.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_32.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_33.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_34.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_35.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_36.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_37.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_38.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_41.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_42.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_43.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_44.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_45.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_46.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_51.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_52.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_53.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_55.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_56.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_57.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_58.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_61.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_62.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_63.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_64.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_71.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_72.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_73.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_81.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_82.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_83.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_84.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_85.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_91.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_92.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_93.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/table_commune_adjacentes.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/table_INS_recod_code_postal.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/table_postal_arrond.csv"), showWarnings = FALSE)
  file.remove(paste0(path_data, "BeST/PREPROCESSED/table_postal_com_name.csv"), showWarnings = FALSE)

  file.remove(paste0(path_data, "STATBEL/code_postaux/Conversion Postal code_Refnis code_va01012019.xlsx"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/code_postaux/Lien statbel.txt"), showWarnings = FALSE)

  file.remove(paste0(path_data, "STATBEL/prenoms/TA_POP_2018_F.xlsx"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/prenoms/TA_POP_2018_M.xlsx"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/prenoms/Lien.txt"), showWarnings = FALSE)

  unlink(paste0(path_data, "STATBEL/PREPROCESSED"), force = TRUE, recursive = TRUE)

  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/Licence open data_FR.pdf"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/Licence open data_NL.pdf"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20220101-readme-de.doc"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20220101-readme-en.doc"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20220101-readme-fr.doc"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20220101-readme-nl.doc"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/source_secteurs_statistiques.txt"), showWarnings = FALSE)
  file.remove(paste0(path_data, "STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv"), showWarnings = FALSE)

  unlink(paste0(path_data, "URBIS"), force = TRUE, recursive = TRUE)

}


#' phaco_special_char_insensitive
#'
#' Internal function to format street for matching
#'
#' @noRd
#'
phaco_special_char_insensitive <- function(x){

  x <- str_replace_all(x, regex("[-]", ignore_case = TRUE), " ")

  x <- str_replace_all(x, regex("[\u00e0\u00e2\u00e2\u00e3\u00e4\u00e5]", ignore_case = TRUE), "a")
  x <- str_replace_all(x, regex("[\u00e8\u00e9\u00ea\u00eb]", ignore_case = TRUE), "e")
  x <- str_replace_all(x, regex("[\u00ec\u00ed\u00ee\u00ef]", ignore_case = TRUE), "i")
  x <- str_replace_all(x, regex("[\u00f2\u00f3\u00f4\u00f5\u00f6\u00f8]", ignore_case = TRUE), "o")
  x <- str_replace_all(x, regex("[\u00f9\u00fa\u00fb\u00fc]", ignore_case = TRUE), "u")
  x <- str_replace_all(x, regex("[\u00fd\u00ff]", ignore_case = TRUE), "y")
  x <- str_replace_all(x, regex("[\u00f1]", ignore_case = TRUE), "n")
  x <- str_replace_all(x, regex("[\u00e7]", ignore_case = TRUE), "c")

  return(x)
}
