#' phaco_geocode : geocodeur pour la Belgique
#'
#' phaco_geocode est la fonction principale du package phacochr.  A partir d’une liste d’adresses, elle permet de retrouver les coordonnees X-Y.
#'
#' @param data_to_geocode un dataframe avec les adresses a geocoder
#' @param colonne_rue nom de la colonne avec les rues
#' @param colonne_num_rue nom de la colonne avec les numéros
#' @param colonne_code_postal nom de la colonne avec les codes postaux
#' @param method_stringdist Méthode pour la jointure inexacte. Par défaut: "lcs". Choix possibles: "osa", "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw","soundex".
#' @param corrections_REGEX Correction orthographique. Par défaut: TRUE
#' @param error_max Nombre maximal d'erreurs entre le nom de la rue a trouver et le nom de la rue dans la base de donnée de référence (BeST). Par défaut: TRUE
#' @param approx_num_max Nombre de numéros d'écart maximum si le numéro n'a pas été trouve. Par défaut: 50
#' @param elargissement_com_adj Élargissement aux communes limitrophes. Par défaut: TRUE
#' @param lang_encoded Langue utilisée pour encoder les noms de rue. Par défaut: c("FR", "NL", "DE")
#'
#' @import dplyr
#' @import tidyr
#' @import readr
#' @import stringr
#' @import purrr
#' @import doParallel
#' @importFrom foreach %dopar% foreach getDoParRegistered
#' @import readxl
#' @import lubridate
#' @import fuzzyjoin
#' @importFrom stringdist stringdist
#' @import sf
#' @import rappdirs
#' @import knitr
#'
#' @export
#'
#' @examples
#' x <- data.frame(nom = c(paste0("Observatoire de la Sant","\u00e9"," et du Social"), "ULB"),
#' rue = c("rue Belliard","avenue Antoine Depage"),
#' num = c("71", "30"),
#' code_postal = c("1040","1000"))
#'
#' result <- phaco_geocode(data_to_geocode = x,
#' colonne_rue = "rue",
#' colonne_num_rue = "num",
#' colonne_code_postal = "code_postal")
#'
phaco_geocode <- function(data_to_geocode,
                          colonne_rue,
                          colonne_num_rue = NULL,
                          colonne_code_postal = NULL,
                          method_stringdist = "lcs",
                          corrections_REGEX = TRUE,
                          error_max = 4,
                          approx_num_max = 50,
                          elargissement_com_adj = TRUE,
                          lang_encoded = c("FR", "NL", "DE")){

  start_time <- Sys.time()

  # Definition du chemin ou se trouve les donnees
  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows

  # Ne pas lancer la fonction si les fichiers ne sont pas presents (cad qu'ils ne sont, en tout logique, pas installes)
  if(sum(
    file.exists(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_11.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_12.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_13.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_21.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_23.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_24.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_25.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_31.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_32.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_33.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_34.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_35.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_36.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_37.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_38.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_41.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_42.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_43.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_44.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_45.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_46.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_51.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_52.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_53.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_55.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_56.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_57.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_58.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_61.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_62.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_63.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_64.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_71.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_72.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_73.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_81.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_82.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_83.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_84.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_85.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_91.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_92.csv"),
                paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_93.csv"),
                paste0(path_data,"BeST/PREPROCESSED/table_commune_adjacentes.csv"),
                paste0(path_data,"BeST/PREPROCESSED/table_INS_recod_code_postal.csv"),
                paste0(path_data,"BeST/PREPROCESSED/table_postal_arrond.csv"),
                paste0(path_data,"STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv")
                )
    ) != 48) {

    stop(paste0("\u2716"," les fichiers ne sont pas install","\u00e9","s : lancez phaco_setup_data()"))

  }

  # Pour definir si le num de la rue ou le code postal sont integres (necessaire pour la suite du script)
  if(!is.null(colonne_num_rue)){
    num_rue <- "sep"
  } else {
    num_rue <- "int"
  }

  if(!is.null(colonne_code_postal)){
    code_postal <- "sep"
  } else {
    code_postal <- "int"
  }

  cat("--- PhacochR ---")


  # 0. FORMATAGE DES DONNEES ==================================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  cat(paste0("\n","-- Formatage des donn","\u00e9","es"))

  #cat(paste0("\n","\u29D7"," Pr","\u00e9","paration et v","\u00e9","rification des donn","\u00e9","es..."))


  ## 1. Formatage des donnees =================================================================================================================

  # Creation/formatage des colonnes pour le geocodage et creation d'un ID unique
  data_to_geocode <- data_to_geocode %>%
    mutate(rue_to_geocode = data_to_geocode[[colonne_rue]],
           ID_address = row_number()) %>%
    relocate(ID_address)

  if (num_rue == "sep") {
    data_to_geocode <- data_to_geocode %>%
      mutate(num_rue_to_geocode = data_to_geocode[[colonne_num_rue]])
  }

  if (code_postal == "sep") {
    data_to_geocode <- data_to_geocode %>%
      mutate(code_postal_to_geocode = data_to_geocode[[colonne_code_postal]],
             code_postal_to_geocode = str_squish(code_postal_to_geocode))
  }


  ## 2. Code postal ===========================================================================================================================

  # Extraction du code postal si interne au champ d'adresse
  if (code_postal == "int") {
    data_to_geocode <- data_to_geocode %>%
      mutate(code_postal_to_geocode = str_extract(rue_to_geocode, regex("([0-9]{4}\\s[a-z- ]+\\z)|([0-9]{4}(|\\s)\\z)", ignore_case = TRUE)),
             rue_to_geocode = str_replace(rue_to_geocode, regex("([0-9]{4}\\s[a-z- ]+\\z)|([0-9]{4}(|\\s)\\z)", ignore_case = TRUE), " "),
             code_postal_to_geocode = str_extract(code_postal_to_geocode, regex("[0-9]{4}", ignore_case = TRUE)))
  }


  ## 3. Detection des regions/arrondissements en Belgique =====================================================================================

  table_postal_arrond <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_postal_arrond.csv"), delim = ";", progress= F,  col_types = cols(.default = col_character()))

  data_to_geocode <- data_to_geocode %>%
    left_join(table_postal_arrond, by = c("code_postal_to_geocode" = "postcode"))

  # @@@@@@@@@@ Tout le script se lance uniquement s'il y a des codes postaux en Belgique ! @@@@@@@@@@
  # Dans le cas contraire => message d'erreur
  if (length(unique(data_to_geocode$Region[!is.na(data_to_geocode$Region)])) == 0){
    stop(paste0("\u2716"," il n'y a aucun code postal belge dans le fichier (ou erreur d'encodage)"))
  }

  cat(paste0("\n",colourise("\u2139", fg= "blue")," R","\u00e9","gion(s) d","\u00e9","tect","\u00e9","e(s) : ",
                paste(unique(data_to_geocode$Region[!is.na(data_to_geocode$Region)]),
                      collapse = ', ')))


  ## 4. Numero de rue =======================================================================================================================
  # Pour creer un numero de rue clean + aller chercher le numero de la rue dans le champ texte de l'adresse (s'il est present)

  # Dans le cas ou il y a une colonne separee avec le num de rue
  if (num_rue == "sep") {
    data_to_geocode <- data_to_geocode %>%
      mutate(num_rue_text = ifelse(str_detect(num_rue_to_geocode, regex("[0-9]", ignore_case = TRUE)), # J'extrait le num du champ texte (ssi il est absent de num_rue)
                                   NA,
                                   str_extract(rue_to_geocode, regex("(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]+)(?!((e |eme |de )))", ignore_case = TRUE))),
             num_rue_clean = ifelse(str_detect(num_rue_to_geocode, regex("[0-9]", ignore_case = TRUE)), # On cree un numero cleane : le num_rue (sans texte) OU le num du champ texte (ssi num_rue est vide)
                                    str_extract(num_rue_to_geocode, regex("[0-9]+", ignore_case = TRUE)),
                                    num_rue_text)) %>%
      mutate(num_rue_clean = as.numeric(num_rue_clean)) %>%
      relocate(num_rue_text, .before = code_postal_to_geocode) %>%
      relocate(num_rue_clean, .after = num_rue_text) %>%
      select(-num_rue_text)}

  # Dans le cas ou le num de rue est uniquement dans le champ texte
  if (num_rue == "int") {
    data_to_geocode <- data_to_geocode %>%
      mutate(num_rue_clean = str_extract(rue_to_geocode, regex("(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( ||i)(e|e)me |( |)de |( |)er |([a-z]{3,20})))", ignore_case = TRUE))) %>%
      mutate(num_rue_clean = as.numeric(num_rue_clean)) %>%
      relocate(num_rue_clean, .before = code_postal_to_geocode)}


  # I. REGEX adresses (corrections) =========================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  # On cree une nouvelle colonne avec le nom de rue corrige + des colonnes avec TRUE / FALSE pour identifier les familles de changements
  if ((code_postal == "int"|num_rue == "int")|(corrections_REGEX == TRUE & code_postal == "sep" & num_rue == "sep")){

    cat(paste0("\n","\u29D7"," Correction orthographique des adresses"))

    data_to_geocode <- data_to_geocode %>%
      mutate(rue_recoded = paste0(str_trim(rue_to_geocode, "left"),"   "),

             rue_recoded_virgule = str_detect(rue_recoded, regex("[,]", ignore_case = TRUE)),
             rue_recoded = str_replace_all(rue_recoded, regex("[,]", ignore_case = TRUE), " "),

             rue_recoded_parenthese = str_detect(rue_recoded, regex("[(].+[)]", ignore_case = TRUE)),
             rue_recoded = str_replace_all(rue_recoded, regex("[(].+[)]", ignore_case = TRUE), " "),

             rue_recoded_boite = str_detect(rue_recoded, regex("(bte|boite)\\s[0-9]+|(bte|boite)\\s[a-z]+|bus\\s[0-9]+|bus\\s[a-z]+", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(bte|boite)\\s[0-9]+|(bte|boite)\\s[a-z]+|bus\\s[0-9]+|bus\\s[a-z]+", ignore_case = TRUE), " "),

             rue_recoded_num = str_detect(rue_recoded, regex("((?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( |)er |( ||i)(e|e)me |( |)de |(-|)[a-z]{3,}))([^ ,0-9]+))|(([^ ,0-9]+)(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |))|([a-z]{3,20}))([0-9]++)(?!(( |)e |( ||i)(e|e)me |( |)de |( |)er )))|(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( ||i)(e|e)me |( |)de |( |)er ))", ignore_case = TRUE)),
             rue_recoded = str_replace_all(rue_recoded, regex("((?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( |)er |( ||i)(e|e)me |( |)de |(-|)[a-z]{3,}))([^ ,0-9]+))|(([^ ,0-9]+)(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |))|([a-z]{3,20}))([0-9]++)(?!(( |)e |( ||i)(e|e)me |( |)de |( |)er )))|(?<!(d(es|u) )|(Albert( |))|(L(e|e)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( ||i)(e|e)me |( |)de |( |)er ))", ignore_case = TRUE), " "),

             rue_recoded_BP = str_detect(rue_recoded, regex("\\sBP\\s|^BP\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("\\sBP\\s|^BP\\s", ignore_case = TRUE), " "),

             rue_recoded_Rez = str_detect(rue_recoded, regex("\\sRez\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("\\sRez\\s", ignore_case = TRUE), " "),

             rue_recoded_Commandant = str_detect(rue_recoded, regex("(c(m|)dt(.|)(\\s|))", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(c(m|)dt(.|)(\\s|))", ignore_case = TRUE), "Commandant "),

             rue_recoded_Lieutenant = str_detect(rue_recoded, regex("((^lt[.](\\s|)|^lt\\s)|(?<!^)\\s+lt[.](\\s|)|(?<!^)\\s+lt\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^lt[.](\\s|)|^lt\\s)", ignore_case = TRUE), "Luitenant "),
             rue_recoded = str_replace(rue_recoded, regex("((?<!^)\\s+lt[.](\\s|)|(?<!^)\\s+lt\\s)", ignore_case = TRUE), " Lieutenant "),

             rue_recoded_Saint = str_detect(rue_recoded, regex("(\\sst(\\s|[-]|[.])|^st(\\s|[-]|[.])|(\\ss|^s)te(\\s|[-]))", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("\\sst(\\s|[-]|[.])", ignore_case = TRUE), " Saint "),
             rue_recoded = str_replace(rue_recoded, regex("^st(\\s|[-]|[.])", ignore_case = TRUE), "Sint "),
             rue_recoded = str_replace(rue_recoded, regex("(\\ss|^s)te(\\s|[-])", ignore_case = TRUE), " Sainte "),

             rue_recoded = str_trim(rue_recoded, "left"), # On fait ca avant les REGEX avec ^ (ci-dessous), au cas ou les etapes precedentes auraient ajoute des blancs au debut des chaines de caracteres (notamment " Saint ", cf. precedent)

             rue_recoded_chaussee = str_detect(rue_recoded, regex("(^ch(s|)(e|e)e\\s|^ch([.]|\\s))", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^ch(s|)(e|e)e\\s|^ch([.]|\\s))", ignore_case = TRUE), "Chaussee "),

             rue_recoded_avenue = str_detect(rue_recoded, regex("(^av[.](\\s|)|^av(e|)\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^av[.](\\s|)|^av(e|)\\s)", ignore_case = TRUE), "Avenue "),

             rue_recoded_koning = str_detect(rue_recoded, regex("(^kon[.](\\s|)|^kon\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^kon[.](\\s|)(?=(elisabet|astrid))|^kon\\s)(?=(elisabet|astrid))", ignore_case = TRUE), "Koningin "),
             rue_recoded = str_replace(rue_recoded, regex("(^kon[.](\\s|)(?!(elisabet|astrid))|^kon\\s)(?!(elisabet|astrid))", ignore_case = TRUE), "Koning "),

             rue_recoded_professor = str_detect(rue_recoded, regex("(^prof[.](\\s|)|^prof\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^prof[.](\\s|)|^prof\\s)", ignore_case = TRUE), "Professor "),

             rue_recoded_square = str_detect(rue_recoded, regex("(^sq[.](\\s|)|^sq\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^sq[.](\\s|)|^sq\\s)", ignore_case = TRUE), "Square "),

             rue_recoded_steenweg = str_detect(rue_recoded, regex("stwg", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("stwg", ignore_case = TRUE), "steenweg"),

             rue_recoded_burg = str_detect(rue_recoded, regex("(^burg[.](\\s|)|^burg\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^burg[.](\\s|)|^burg\\s)", ignore_case = TRUE), "Burgemeester "),

             rue_recoded_dokter = str_detect(rue_recoded, regex("(^dr[.](\\s|)|^dr\\s|(?<!^)\\s+dr[.](\\s|)|(?<!^)\\s+dr\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(^dr[.](\\s|)|^dr\\s)", ignore_case = TRUE), "Dokter "),
             rue_recoded = str_replace(rue_recoded, regex("((?<!^)\\s+dr[.](\\s|)|(?<!^)\\s+dr\\s)", ignore_case = TRUE), " Docteur "),

             rue_recoded_boulevard = str_detect(rue_recoded, regex("((^b(|l)(|v)d(|[.])\\s)|(^b(|l)(|v)d[.]))", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("((^b(|l)(|v)d(|[.])\\s)|(^b(|l)(|v)d[.]))", ignore_case = TRUE), "Boulevard "),

             rue_recoded_route = str_detect(rue_recoded, regex("^Rte\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("^Rte\\s", ignore_case = TRUE), "Route "),

             # Ici on conditionne la correction au fait qu'il n'y ait pas de mots neerlandais, car correction uniquement francophone
             rue_recoded_Rue = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                      FALSE,
                                      str_detect(rue_recoded, regex("(^de\\sla\\s|^du\\s|^des\\s|^d[']|^de\\s|^r\\s|^de\\sl(\\s|)['])", ignore_case = TRUE))
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^de\\sla\\s", ignore_case = TRUE), "Rue de la ")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^du\\s", ignore_case = TRUE), "Rue du ")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^des\\s", ignore_case = TRUE), "Rue des ")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^d[']", ignore_case = TRUE), "Rue d'")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^de\\s", ignore_case = TRUE), "Rue de ")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^r\\s", ignore_case = TRUE), "Rue ")
             ),
             rue_recoded = ifelse(str_detect(rue_recoded, regex("(laan|straat|plein|dreef|lei)", ignore_case = TRUE)),
                                  rue_recoded,
                                  str_replace(rue_recoded, regex("^de\\sl(\\s|)[']", ignore_case = TRUE), "Rue de l'")
             ),

             rue_recoded_apostrophe = str_detect(rue_recoded, regex("(de\\sl\\s([']|)|rue\\sd\\s|[']\\s)", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("de\\sl\\s([']|)", ignore_case = TRUE), "de l'"),
             rue_recoded = str_replace(rue_recoded, regex("rue\\sd\\s", ignore_case = TRUE), "Rue d'"),
             rue_recoded = str_replace(rue_recoded, regex("[']\\s", ignore_case = TRUE), "'"),

             rue_recoded_place = str_detect(rue_recoded, regex("^pl\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("^pl\\s", ignore_case = TRUE), "Place "),

             rue_recoded_slash = str_detect(rue_recoded, regex("\\s/\\s", ignore_case = TRUE)),
             rue_recoded = str_replace_all(rue_recoded, regex("\\s/\\s", ignore_case = TRUE), " "),

             rue_recoded_Bis = str_detect(rue_recoded, regex("\\sBis\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("\\sBis\\s", ignore_case = TRUE), " "),

             rue_recoded_Rdc = str_detect(rue_recoded, regex("\\sRdc\\s", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("\\sRdc\\s", ignore_case = TRUE), " "),

             rue_recoded_No = str_detect(rue_recoded, regex(paste0("n", "\u00b0"), ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex(paste0("n", "\u00b0"), ignore_case = TRUE), " "),

             rue_recoded = str_squish(rue_recoded), # On fait ca avant le regex "(?<=\\s)[A-Ea-e]$" (ci-dessous), pour etre sur qu'il fonctionne (car avec un espace derriere la lettre, il n'agit plus)

             rue_recoded_lettre_end = str_detect(rue_recoded, regex("(?<=\\s)[A-Ea-e]$", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("(?<=\\s)[A-Ea-e]$", ignore_case = TRUE), " "),

             rue_recoded = str_squish(rue_recoded), # On fait ca avant le regex "(?<=\\s)[A-Ea-e]$" (ci-dessous), pour etre sur qu'il fonctionne (car avec un espace derriere la lettre, il n'agit plus)

             rue_recoded_double_lettre_end = str_detect(rue_recoded, regex("(?<=\\s)[A-Ea-e]$", ignore_case = TRUE)), # On le fait 2x, pour les doubles lettres seules a la fin (present dans BDD des pharmaciens)
             rue_recoded = str_replace(rue_recoded, regex("(?<=\\s)[A-Ea-e]$", ignore_case = TRUE), " "),

             rue_recoded = str_squish(rue_recoded), # On fait ca avant le regex "[-]$" (ci-dessous), pour etre sur qu'il fonctionne (car avec un espace derriere le tiret, il n'agit plus)

             rue_recoded_tiret = str_detect(rue_recoded, regex("[-]$", ignore_case = TRUE)),
             rue_recoded = str_replace(rue_recoded, regex("[-]$", ignore_case = TRUE), " "),

             rue_recoded = str_squish(rue_recoded) # A faire a la fin : pour les doubles espaces et les espaces en trop a gauche ou a droite
      )

    data_to_geocode <- data_to_geocode %>%
      mutate(rue_recoded_virgule = ifelse(rue_recoded_virgule == TRUE, "virgule", NA),
             rue_recoded_parenthese = ifelse(rue_recoded_parenthese == TRUE, "parenthese", NA),
             rue_recoded_boite = ifelse(rue_recoded_boite == TRUE, "boite", NA),
             rue_recoded_num = ifelse(rue_recoded_num == TRUE, "num", NA),
             rue_recoded_BP = ifelse(rue_recoded_BP == TRUE, "BP", NA),
             rue_recoded_Rez = ifelse(rue_recoded_Rez == TRUE, "Rez", NA),
             rue_recoded_Commandant = ifelse(rue_recoded_Commandant == TRUE, "Commandant", NA),
             rue_recoded_Lieutenant = ifelse(rue_recoded_Lieutenant == TRUE, "Lieutenant", NA),
             rue_recoded_Saint = ifelse(rue_recoded_Saint == TRUE, "Saint", NA),
             rue_recoded_chaussee = ifelse(rue_recoded_chaussee == TRUE, "chaussee", NA),
             rue_recoded_avenue = ifelse(rue_recoded_avenue == TRUE, "avenue", NA),
             rue_recoded_koning = ifelse(rue_recoded_koning == TRUE, "koning", NA),
             rue_recoded_professor = ifelse(rue_recoded_professor == TRUE, "professor", NA),
             rue_recoded_square = ifelse(rue_recoded_square == TRUE, "square", NA),
             rue_recoded_steenweg = ifelse(rue_recoded_steenweg == TRUE, "steenweg", NA),
             rue_recoded_burg = ifelse(rue_recoded_burg == TRUE, "Burgemeester", NA),
             rue_recoded_dokter = ifelse(rue_recoded_dokter == TRUE, "Dokter", NA),
             rue_recoded_boulevard = ifelse(rue_recoded_boulevard == TRUE, "boulevard", NA),
             rue_recoded_route = ifelse(rue_recoded_route == TRUE, "route", NA),
             rue_recoded_Rue = ifelse(rue_recoded_Rue == TRUE, "Rue", NA),
             rue_recoded_apostrophe = ifelse(rue_recoded_apostrophe == TRUE, "apostrophe", NA),
             rue_recoded_place = ifelse(rue_recoded_place == TRUE, "place", NA),
             rue_recoded_slash = ifelse(rue_recoded_slash == TRUE, "slash", NA),
             rue_recoded_Bis = ifelse(rue_recoded_Bis == TRUE, "Bis", NA),
             rue_recoded_Rdc = ifelse(rue_recoded_Rdc == TRUE, "Rdc", NA),
             rue_recoded_No = ifelse(rue_recoded_No == TRUE, paste0("n", "\u00b0"), NA),
             rue_recoded_lettre_end = ifelse(rue_recoded_lettre_end == TRUE, "lettre_fin", NA),
             rue_recoded_double_lettre_end = ifelse(rue_recoded_double_lettre_end == TRUE, "2e_lettre_fin", NA),
             rue_recoded_tiret = ifelse(rue_recoded_tiret == TRUE, "tiret", NA)
      )

    # On fusionne toutes les colonnes qui commencent par "rue_recoded_" en une
    data_to_geocode_REGEX <- data_to_geocode %>%
      select(ID_address, starts_with("rue_recoded_")) %>%
      unite("recode", 2:last_col(), sep = " ; ", remove = TRUE, na.rm = TRUE)

    data_to_geocode <- data_to_geocode %>%
      select(-starts_with("rue_recoded_")) %>%
      left_join(data_to_geocode_REGEX, by = "ID_address")

    # A FAIRE EN NL :
    #boulevard => blv
    #straat => str
    #Onze-Lieve-Vrouw => OLV

  }

  if (corrections_REGEX == FALSE & code_postal == "sep" & num_rue == "sep"){
    data_to_geocode <- data_to_geocode %>%
      mutate(rue_recoded = str_squish(rue_to_geocode),
             recode = NA)
  }

  # On repositionne "rue_recoded" et "recode" pour la lisibilite
  data_to_geocode <- data_to_geocode %>%
    relocate(rue_recoded, .after = rue_to_geocode) %>%
    relocate(recode, .after = rue_recoded)

  #freq(data_to_geocode$recode)

  cat(paste0("\033[K","\r",colourise("\u2714", fg="green")," Correction orthographique des adresses", "\033[K"))


  # II. GEOCODAGE ===========================================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ## 0. Parametres/fonctions ================================================================================================================

  # Fonction utilisee dans le script => https://www.r-bloggers.com/2018/07/the-notin-operator/
  `%ni%` <- Negate(`%in%`)

  # Parametres pour la parallelisation
  chk <- Sys.getenv("_R_CHECK_LIMIT_CORES_", "")
  if (nzchar(chk) && chk == "TRUE") {
    n.cores <- 2L # limite le nombre de coeurs a 2 pour les tests sur CRAN https://stackoverflow.com/questions/50571325/r-cran-check-fail-when-using-parallel-functions
  } else {
    n.cores <- parallel::detectCores() - 1
  }

  cat(paste0("\n","-- G","\u00e9","ocodage"))
  cat(paste0("\n","\u29D7"," Param","\u00e9","trage pour utiliser ", n.cores, " coeurs de l'ordinateur"))

  my.cluster <- parallel::makeCluster(
    n.cores,
    type = "PSOCK")
  doParallel::registerDoParallel(cl = my.cluster)
  foreach::getDoParRegistered()

  cat(paste0("\r",colourise("\u2714", fg="green")," Param","\u00e9","trage pour utiliser ", n.cores, " coeurs de l'ordinateur"))


  ## 1)  Jointure des rues  -----------------------------------------------------------------------------------------------------------------

  cat(paste0("\n","\u29D7"," D","\u00e9","tection des rues (matching inexact avec fuzzyjoin)"))

  ### i. Preparation des fichiers rues (BeST) -----------------------------------------------------------------------------------------------

  # J'importe les rues
  postal_street <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"), delim = ";", progress= F,  col_types = cols(.default = col_character())) %>%
    mutate(address_join_street = paste(str_to_lower(str_trim(street_FINAL_detected))))

  if (length(lang_encoded) != 3){
    postal_street <- postal_street %>%
      filter(langue_FINAL_detected %in% lang_encoded)
  }

  # On filtre + creation d'une cle de jointure
  data_to_geocode <- data_to_geocode %>%
    mutate(address_join = paste(str_to_lower(str_trim(rue_recoded))))


  ### ii) Boucle de jointure par commune ----------------------------------------------------------------------------------------------------

  # /!\ NOTE : la cle de jointure est en minuscule (d'ou les str_to_lower() avant), car stringdist identifie la diff de case comme une diff !
  res <- tibble()
  res <- foreach (i = unique(data_to_geocode$code_postal_to_geocode),
                  .combine = 'bind_rows',
                  .packages=c("tidyverse","fuzzyjoin"))  %dopar% {

                    data_to_geocode_i <- data_to_geocode %>%
                      filter(code_postal_to_geocode == i)

                    postal_street_i <- postal_street %>%
                      filter(postal_id == i)

                    stringdist_left_join(data_to_geocode_i,
                                         postal_street_i,
                                         by = c("address_join" = "address_join_street"),
                                         method = method_stringdist,
                                         max_dist = error_max,
                                         distance_col = "dist_fuzzy",
                                         nthread= n.cores)
                  }

  cat(paste0("\r",colourise("\u2714", fg="green")," D","\u00e9","tection des rues (matching inexact avec fuzzyjoin)", "\033[K"))

  # On ne retient que l'adresse detectee avec la distance minimale
  res <- res %>%
    group_by(ID_address) %>%
    mutate(min = min(dist_fuzzy)) %>%
    filter(dist_fuzzy == min | is.na(dist_fuzzy)) %>%
    select(-min, -postal_id)

  # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler dans un if statement + au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
  # Si ca ne se lance pas, on supprime les cles de jointure dont on n'a plus besoin
  if(sum(duplicated(res$ID_address)) == 0){
    res <- res %>%
      select(-address_join, -address_join_street)
  }

  if(sum(duplicated(res$ID_address)) > 0){

    cat(paste0("\n","\u29D7"," Ex-aequos : calcul de la distance Jaro-Winkler pour d","\u00e9","partager"))

    res <- res %>%
      mutate(distance_jw = stringdist(address_join, address_join_street, method = "jw", p=0.1, nthread= n.cores)) %>% # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler
      group_by(ID_address) %>%
      mutate(min_jw = min(distance_jw)) %>%
      filter(distance_jw == min_jw | is.na(distance_jw)) %>%
      sample_n(1) %>% # Au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
      select(-min_jw, -distance_jw, -address_join, -address_join_street)

    cat(paste0("\r",colourise("\u2714", fg="green")," Ex-aequos : calcul de la distance Jaro-Winkler pour d","\u00e9","partager"))
  }

  res <- res %>%
    relocate(street_FINAL_detected, .after = recode) %>%
    mutate(type_geocoding = NA)

  # Verif
  #sum(duplicated(res$ID_address))
  # Performance :
  #sum(!is.na(res$street_FINAL_detected))/nrow(res)


  ### iii) Elargissement de la boucle aux communes adjacentes -------------------------------------------------------------------------------
  # On supprime la contrainte de recherche de la rue dans la commune, pour augmenter le % de rues detectees

  if (elargissement_com_adj == TRUE) {

    cat(paste0("\n","\u29D7"," \u00c9","largissement pour les rues non trouv","\u00e9","es aux communes adjacentes"))

    # On ne retient que les adresses dont les rues n'ont pas ete detectees
    ADDRESS_last_tentative <- res %>%
      filter(is.na(dist_fuzzy)) %>%
      mutate(address_join = paste(str_to_lower(str_trim(rue_recoded)))) %>%
      select(-street_FINAL_detected, -street_id_phaco, -langue_FINAL_detected, -nom_propre_abv, -dist_fuzzy)

    if (nrow(ADDRESS_last_tentative) > 0){ # Un if au cas ou toutes les adresses auraient ete trouvees (alors il ne faut pas lancer la partie entre crochets)

      # On charge la table de conversion code postal > code INS recode (voir preprocessing)
      table_INS_recod_code_postal <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_INS_recod_code_postal.csv"), delim = ";",progress= F, col_types = cols(.default = col_character()))

      # On ajoute ce code INS recode 1) aux rues et 2) aux adresses non trouvees
      postal_street_adj <- postal_street %>%
        left_join(table_INS_recod_code_postal, by = c("postal_id" = "code_postal"))
      ADDRESS_last_tentative <- ADDRESS_last_tentative %>%
        left_join(table_INS_recod_code_postal, by = c("code_postal_to_geocode" = "code_postal"))

      # On charge la table des communes (= code INS recodes) adjacentes par commune (voir preprocessing)
      table_commune_adjacentes <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_commune_adjacentes.csv"), progress= F, delim = ";", col_types = cols(.default = col_character()))

      res_adj <- tibble()
      res_adj <- foreach (i = unique(ADDRESS_last_tentative$`Refnis code`),
                          .combine = 'bind_rows',
                          .packages=c("tidyverse","fuzzyjoin"))  %dopar% {

                            # On calcule un vecteur reprenant les communes adjacentes par commune i
                            com_adj_i <- table_commune_adjacentes$cd_munty_refnis_voisin[table_commune_adjacentes$cd_munty_refnis == i]

                            ADDRESS_last_tentative_i <- ADDRESS_last_tentative %>%
                              filter(`Refnis code` %in% com_adj_i) %>%
                              select(-`Refnis code`)

                            postal_street_adj_i <- postal_street_adj %>%
                              filter(`Refnis code` %in% com_adj_i) %>%
                              select(-`Refnis code`)

                            stringdist_left_join(ADDRESS_last_tentative_i,
                                                 postal_street_adj_i,
                                                 by = c("address_join" = "address_join_street"),
                                                 method = method_stringdist,
                                                 max_dist = error_max/2,
                                                 distance_col = "dist_fuzzy")
                          }

      # Ce if statement car res_adj peut avoir 0 observations => NOTE : elucider pourquoi ? Pourquoi ca n'arrive pas avec "res" (boucle precedente) ?
      if(nrow(res_adj) > 0){
        # On ne retient que l'adresse detectee avec la distance minimale
        res_adj <- res_adj %>%
          group_by(ID_address) %>%
          mutate(min = min(dist_fuzzy)) %>%
          filter(dist_fuzzy == min | is.na(dist_fuzzy)) %>%
          select(-min)

        # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler dans un if statement + au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
        # Si ca ne se lance pas, on supprime les cles de jointure dont on n'a plus besoin
        if(sum(duplicated(res_adj$ID_address)) == 0){
          res_adj <- res_adj %>%
            select(-address_join, -address_join_street)
        }

        if(sum(duplicated(res_adj$ID_address)) > 0){
          res_adj <- res_adj %>%
            mutate(distance_jw = stringdist(address_join, address_join_street, method = "jw", p=0.1, nthread= n.cores)) %>% # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler
            group_by(ID_address) %>%
            mutate(min_jw = min(distance_jw)) %>%
            filter(distance_jw == min_jw | is.na(distance_jw)) %>%
            sample_n(1) %>% # Au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
            select(-min_jw, -distance_jw, -address_join, -address_join_street)
        }

        res_adj <- res_adj %>%
          relocate(street_FINAL_detected, .after = recode) %>%
          mutate(type_geocoding = "elargissement_adj") %>%
          filter(!is.na(dist_fuzzy)) %>%
          mutate(code_postal_to_geocode = postal_id) %>%
          select(-postal_id)

        # On liste les ID_address geocodes dans cette nouvelle procedure
        ADDRESS_last_tentative_vector <- unique(res_adj$ID_address)

        # Et on les ajoute a res_bxl (prelablement deleste des adresses prealablement non trouvees mais desormais trouvees !)
        res <- res %>%
          filter(ID_address %ni% ADDRESS_last_tentative_vector) %>%
          bind_rows(res_adj)
      }
    }

    cat(paste0("\r",colourise("\u2714", fg="green")," \u00c9","largissement pour les rues non trouv","\u00e9","es aux communes adjacentes"))
  }


  ## 2)  Jointure des adresses --------------------------------------------------------------------------------------------------------------

  #### i. Preparation des fichiers adresses (BeST) ------------------------------------------------------------------------------------------
  cat(paste0("\n","\u29D7"," Chargement du fichier openaddress"))
    # Ici on cree une liste des adresses en n'important que les arrodissements detectes dans data_to_geocode
    openaddress_be <- paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_",
                             unique(data_to_geocode$arrond[!is.na(data_to_geocode$arrond)]),
                             ".csv") %>%
      map_dfr(read_delim,delim = ";",progress= F,  col_types = cols(.default = col_character())) %>%
      left_join(select(postal_street, street_FINAL_detected, postal_id, street_id_phaco), by= "street_id_phaco" ) %>% # On joint les noms de rue (non contenues dans le fichier openadress par economie de place) via postal_street et la cle de jointure unique "street_id_phaco" (voir preprocessing)
      mutate(house_number_sans_lettre = as.numeric(house_number_sans_lettre), # @@@@@@@@ QUESTION : POURQUOI ON FAIT CA ???????????????????
             address_join_geocoding = paste(house_number_sans_lettre, street_FINAL_detected, postal_id)) #%>%
    #select(-street_FINAL_detected, -postal_id, -street_id_phaco)

  # Ici on cree une liste des adresses en n'important que les arrodissements detectes dans data_to_geocode
  openaddress_be <- paste0(path_data,"BeST/PREPROCESSED/data_arrond_PREPROCESSED_",
                           unique(data_to_geocode$arrond[!is.na(data_to_geocode$arrond)]),
                           ".csv") %>%
    readr::read_delim( delim = ";",progress= F,  col_types = cols(.default = col_character())) %>%
    left_join(select(postal_street, street_FINAL_detected, postal_id, street_id_phaco), by= "street_id_phaco" ) %>% # On joint les noms de rue (non contenues dans le fichier openadress par economie de place) via postal_street et la cle de jointure unique "street_id_phaco" (voir preprocessing)
    mutate(house_number_sans_lettre = as.numeric(house_number_sans_lettre), # @@@@@@@@ QUESTION : POURQUOI ON FAIT CA ???????????????????
           address_join_geocoding = paste(house_number_sans_lettre, street_FINAL_detected, postal_id)) #%>%
  #select(-street_FINAL_detected, -postal_id, -street_id_phaco)

  cat(paste0("\r",colourise("\u2714", fg="green")," Chargement du fichier openaddress "))

  #### ii. Jointure avec les adresses  ------------------------------------------------------------------------------------------------------

  cat(paste0("\n","\u29D7"," Jointure avec les coordonn","\u00e9","es X-Y"))

  FULL_GEOCODING <- res %>%
    mutate(address_join_geocoding = paste(num_rue_clean, street_FINAL_detected, code_postal_to_geocode)) %>%
    left_join(select(openaddress_be, -street_FINAL_detected, -postal_id, -street_id_phaco), by = "address_join_geocoding") %>%
    #select(-house_number) %>%
    mutate(approx_num = 0)

  cat(paste0("\r",colourise("\u2714", fg="green")," Jointure avec les coordonn","\u00e9","es X-Y"))

  ### iii. Approximation numero -------------------------------------------------------------------------------------------------------------

  # Ne s'applique que si approx_num_max > 0
  if (approx_num_max > 0) {

    cat(paste0("\n","\u29D7"," Approximation ", "\u00e0", " + ou - ", approx_num_max*2, " num","\u00e9","ros pour les adresses non localis","\u00e9","es"))

    # On selectionne les lignes pour lesquelles un numero de police a ete encode, on a trouve la rue, mais pour lesquelles on n'a pas trouve de correspondance dans les fichiers openaddress.
    FULL_GEOCODING_APPROX <- FULL_GEOCODING %>%
      filter(!is.na(street_id_phaco) & !is.na(num_rue_clean) & is.na(house_number_sans_lettre)) %>%
      select (-address_join_geocoding, -x_31370, -y_31370, -cd_sector, -house_number_sans_lettre, -approx_num)

    if (nrow(FULL_GEOCODING_APPROX) > 0) { # A partir d'ici, plein de if statement pour eviter d'appliquer les operations sur un tableau vide (possible a chaque etape)
      # On fait une jointure avec openaddress sur base des noms de rue, uniquement du meme cote de la rue
      APPROX_1 <- FULL_GEOCODING_APPROX %>%
        select(ID_address, num_rue_clean, street_id_phaco) %>%
        inner_join(select(openaddress_be, street_id_phaco, house_number_sans_lettre, x_31370, y_31370, cd_sector),
                   by=c("street_id_phaco")) %>%
        distinct() %>%
        filter(num_rue_clean%%2 == house_number_sans_lettre%%2) #  On ne selectionne que les numeros du meme cote

      if (nrow(APPROX_1) > 0){
        # On ne retient que le numero avec la distance minimale
        APPROX_1 <- APPROX_1 %>%
          mutate(approx_num = abs(num_rue_clean - house_number_sans_lettre)) %>%
          group_by(ID_address) %>%
          mutate(min = min(approx_num)) %>%
          filter(min == approx_num) %>%  # selection plus proche
          sample_n(1) %>%
          select(-street_id_phaco, -num_rue_clean)

        #sum(duplicated(APPROX_1$ID_address))

        # On selectionne ceux qu'on n'a pas trouve en repartant de FULL_GEOCODING_APPROX avec un anti_join sur APPROX_1
        APPROX_2 <- FULL_GEOCODING_APPROX %>%
          select(ID_address, num_rue_clean, street_id_phaco) %>%
          anti_join(APPROX_1, by= "ID_address")

        if (nrow(APPROX_2) > 0){

          APPROX_2 <- APPROX_2 %>%
            # On fait une jointure avec openaddress sur base des noms de rue, cette fois n'importe quel cote de la rue
            inner_join(select(openaddress_be, street_id_phaco ,house_number_sans_lettre,x_31370, y_31370, cd_sector),
                       by=c("street_id_phaco"))
        }

        if (nrow(APPROX_2) > 0){
          # On ne retient que le numero avec la distance minimale
          APPROX_2 <- APPROX_2 %>%
            distinct() %>%
            mutate(approx_num = abs(num_rue_clean - house_number_sans_lettre)) %>%
            group_by(ID_address) %>%
            mutate(min = min(approx_num)) %>%
            filter(min == approx_num) %>%  # selection plus proche
            sample_n(1) %>%
            select(-street_id_phaco, -num_rue_clean)

          #sum(duplicated(APPROX_2$ID_address))
        }

        if (nrow(APPROX_2) == 0){
          APPROX_2 <- APPROX_2 %>%
            select(-street_id_phaco, -num_rue_clean)
        }

        # On rassemble les resultats
        FULL_GEOCODING_APPROX <- bind_rows(
          inner_join(FULL_GEOCODING_APPROX, APPROX_1, by= "ID_address"),
          inner_join(FULL_GEOCODING_APPROX, APPROX_2, by= "ID_address")) %>%
          filter(approx_num <= approx_num_max*2) %>%
          select(-min)

        FULL_GEOCODING <- FULL_GEOCODING %>%
          filter(ID_address %ni% FULL_GEOCODING_APPROX$ID_address) %>%
          bind_rows(FULL_GEOCODING_APPROX)

      }
    }

    cat(paste0("\r",colourise("\u2714", fg="green")," Approximation ", "\u00e0", " + ou - ", approx_num_max*2, " num","\u00e9","ros pour les adresses non localis","\u00e9","es"))
  }


  # III. FICHIER FINAL  =====================================================================================================================

  cat(paste0("\n","-- R","\u00e9","sultats"))

  cat(paste0("\n","\u29D7"," Cr","\u00e9","ation du fichier final et formatage des tables de v","\u00e9","rification"))


  ## 1) Jointure ----------------------------------------------------------------------------------------------------------------------------

  # Il manque potentiellement des lignes par rapport a la BD originale, car pas de code postal, ou qui ne matchent pas avec les donnees BeST => on les recupere par un antijoin(), et les ajoute
  MISSING <- data_to_geocode %>%
    anti_join(FULL_GEOCODING, by = "ID_address") %>%
    select(-address_join)

  FULL_GEOCODING <- FULL_GEOCODING %>%
    bind_rows(MISSING) %>%
    arrange(ID_address) %>%
    select(-rue_to_geocode, -address_join_geocoding)

  # J'enleve num_rue_to_geocode avec un if statement car la colonne n'est parfois pas creee
  if("num_rue_to_geocode" %in% colnames(FULL_GEOCODING)) {
    FULL_GEOCODING <- FULL_GEOCODING %>%
      select(-num_rue_to_geocode)
  }

  # Performance :
  #sum(!is.na(FULL_GEOCODING$x_31370))/nrow(FULL_GEOCODING)

  # On remet les bons noms de rue (ils sont abreges dans le cas des noms propres abreges)
  postal_street_join_final <- postal_street %>%
    filter(is.na(nom_propre_abv)) %>%
    select(street_id_phaco, street_FINAL_detected_full = street_FINAL_detected, langue_FINAL_detected)

  FULL_GEOCODING <- as.data.frame(FULL_GEOCODING) %>% # On transforme en dataframe sinon ca pose pb dans la suite (a cause du foreach a priori ?)
    left_join(postal_street_join_final, by = c("street_id_phaco", "langue_FINAL_detected")) %>%
    relocate(street_FINAL_detected_full, .after = street_FINAL_detected) %>%
    select(-street_FINAL_detected, street_FINAL_detected = street_FINAL_detected_full)

  # On joint les donnees de region, provinces, communes, quartiers (BXL)... aux secteurs stat

  table_secteurs_prov_commune_quartier <- readr::read_delim(paste0(path_data,"STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv"), delim = ";", progress= F, col_types = cols(.default = col_character()))

  FULL_GEOCODING <- FULL_GEOCODING %>%
    left_join(table_secteurs_prov_commune_quartier, by = "cd_sector")


  ## 2) Resultats recapitulatifs ------------------------------------------------------------------------------------------------------------

  Summary_region <- bind_rows(
    FULL_GEOCODING,
    FULL_GEOCODING %>% mutate(Region = "Total") # Technique tres astucieuse pour ajouter un total au tableau de synthese avec le group_by > summarise!
  ) %>%
    group_by(Region) %>%
    summarise("n" = n(),
              "Rue detect.(%)" = round((sum(!is.na(street_FINAL_detected))/n())*100,1),
              "stringdist (moy)" = mean(dist_fuzzy, na.rm = T),
              "Geocode(%)" = round((sum(!is.na(x_31370))/n())*100,1),
              #"Approx (% geocodes)" = (sum(approx_num > 0, na.rm = T)/(sum(!is.na(x_31370))))*100,
              "Approx. num(n)" = sum(approx_num > 0, na.rm = T),
              "Elarg. com.(n)" = (sum(type_geocoding == "elargissement_adj", na.rm = T)),
              "Abrev. noms(n)" = (sum(nom_propre_abv == 1, na.rm = T)),
              "Rue FR" = (sum(langue_FINAL_detected == "FR", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Rue NL" = (sum(langue_FINAL_detected == "NL", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Rue DE" = (sum(langue_FINAL_detected == "DE", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Coord non valides" = sum(x_31370 == "0.00000", na.rm = T),
              "Dupliques" = sum(duplicated(ID_address)))

  Summary_original <- tibble(Region = "Total (original)",
                             "n" = nrow(data_to_geocode),
                             "Rue detect.(%)" = NA,
                             "stringdist (moy)" = NA,
                             "Geocode(%)" = NA,
                             #"Approx (% geocodes)" = NA,
                             "Approx. num(n)"=NA,
                             "Elarg. com.(n)" = NA,
                             "Abrev. noms(n)" = NA,
                             "Rue FR" = NA,
                             "Rue NL" = NA,
                             "Rue DE" = NA,
                             "Coord non valides" = NA,
                             "Dupliques" = sum(duplicated(data_to_geocode$ID_address)))


  Summary_full <- bind_rows(Summary_original, Summary_region) %>%
    slice(match(c("Total (original)", "Bruxelles", "Flandre", "Wallonie", NA, "Total"), Region))
 # print(Summary_full)

  # J'enleve la region et les arrondissements, car doublon avec jointure dans le point precedent => pas ideal, mais necessaire pour importer les CSV par arrond avec map_dfr, pour le summary et au debut pour detecter les regions et ne pas executer si pas BE => optimiser ?
  FULL_GEOCODING <- FULL_GEOCODING %>%
    select(-Region, -arrond)


  ## 3) Creation de l'objet SF avec les coordonnees -----------------------------------------------------------------------------------------

  if (length(unique(data_to_geocode$Region[!is.na(data_to_geocode$Region)])) > 0){
    # NOTE : l'objet sf ne peut pas contenir de NA pour les coordonnees
    FULL_GEOCODING_sf <- FULL_GEOCODING %>%
      filter(!is.na(x_31370)) %>%
      st_as_sf(coords = c("x_31370", "y_31370")) %>%  # on cree l'objet sf
      st_set_crs(31370) # on definit le systeme de projection
  }

  result <- list()
  result$summary <- Summary_full
  result$data_geocoded <- FULL_GEOCODING
  result$data_geocoded_sf <- FULL_GEOCODING_sf
  # remplacer par 0 les NA (pas tres propre)
  result$summary$`Approx. num(n)`[is.na(result$summary$`Approx. num(n)`)]<-0

  # On stoppe la parallelisation
  parallel::stopCluster(cl = my.cluster)

  cat(paste0("\r",colourise("\u2714", fg="green")," Cr","\u00e9","ation du fichier final et formatage des tables de v","\u00e9","rification"))
  cat(paste0("\n",colourise("\u2714", fg="green")," G","\u00e9","ocodage termin","\u00e9"))
  cat(paste0("\n",colourise("\u2139", fg= "blue")," Statistiques concernant le g","\u00e9","ocodage:"))

  end_time <- Sys.time()

  tab<-knitr::kable(result$summary[2:nrow(result$summary),c(1:3,6:8,5)],
                    format = "pipe",
                    align="lrccccc")
  cat("\n",tab, sep="\n" )

  cat(paste0("\n",colourise("\u2139", fg= "blue"), " Temps de calcul total : ", round(difftime(end_time, start_time, units = "secs")[[1]], digits = 1), " s
             "))
  cat(paste0("\n",colourise("/!\\", fg="red"), " Toutes les adresses n'ont pas ","\u00e9","t","\u00e9"," trouv","\u00e9","es avec certitude ", colourise("/!\\", fg="red"),"
- check \'dist_fuzzy\' pour les erreurs de reconnaissance des rues
- check \'approx_num\' pour les approximations de num","\u00e9","ro
- check \'type_geocoding\' pour l'","\u00e9","argissement aux communes adjacentes
- check \'nom_propre_abv\' pour les abr","\u00e9","viations de noms propres
             "))

  cat(paste0("\n",colourise(paste0("-- Plus de r","\u00e9","sultats:"), fg= "light cyan"),
             "\n",colourise('\u2192', fg= "blue")," Tableau synth","\u00e9","tique : ","$summary",
             "\n",colourise('\u2192', fg= "blue")," Donn","\u00e9","es g","\u00e9","ocod","\u00e9","es : $data_geocoded",
             "\n",colourise('\u2192', fg= "blue")," Donn","\u00e9","es g","\u00e9","ocod","\u00e9","es en format sf : $data_geocoded_sf"))


  return(result)
}

