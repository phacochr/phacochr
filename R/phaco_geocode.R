#' phaco_geocode : Géocodeur pour la Belgique
#'
#' A FAIRE : exemple solo ne fonctionne pas : bug => A regler !
#'
#' Cette fonction est la principale du package phacochr. A partir d’une liste d’adresses, elle permet de retrouver leurs coordonnees X-Y.
#'
#' @param data_to_geocode Un dataframe avec les adresses a geocoder.
#' @param rue Nom de la colonne avec les rues.
#' @param num Nom de la colonne avec les numéros.
#' @param code_postal Nom de la colonne avec les codes postaux.
#' @param method_stringdist Méthode pour la jointure inexacte. Par défaut: "lcs". Choix possibles: "osa", "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw","soundex".
#' @param corrections_REGEX Correction orthographique. Par défaut: TRUE. Cette option n'est désactivable que si la rue est contenue dans une colonne séparée (c'est-à-dire qu'elle ne contient ni le numéro ni le code postal).
#' @param error_max Nombre maximal d'erreurs entre le nom de la rue a trouver et le nom de la rue dans la base de donnée de référence (BeST). Par défaut: TRUE.
#' @param approx_num_max Nombre de numéros d'écart maximum si le numéro n'a pas été trouve. Par défaut: 50.
#' @param elargissement_com_adj Élargissement aux communes limitrophes. Par défaut: TRUE.
#' @param mid_street Indique les coordonnées du milieu de la rue si les coordonnées du numéro ne sont pas trouvée. Par défaut: TRUE.
#' @param lang_encoded Langue utilisée pour encoder les noms de rue. Par défaut: c("FR", "NL", "DE").
#' @param anonymous Anonymisation des résultats en ajoutant uniquement les informations des entités administratives (secteurs statistiques, quartiers, (sous-)communes, etc.). Dans ce cas, les coordonnées X-Y indiquées sont le centroïde du secteur statistique. De plus, toutes les informations relatives à l'adresse dans les données originales sont supprimées. Par défaut: FALSE.
#' @param path_data Chemin absolu vers le dossier où se trouve le données. Par défaut data_path = NULL et phacochr trouve le dossier d'installation choisi par défaut.
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
#'\dontrun{
#' x <- data.frame(nom = c(paste0("Observatoire de la Sant","\u00e9"," et du Social"), "ULB"),
#' rue = c("rue Belliard","avenue Antoine Depage"),
#' num = c("71", "30"),
#' code_postal = c("1040","1000"))
#'
#' result <- phaco_geocode(data_to_geocode = x,
#' colonne_rue = "rue",
#' colonne_num = "num",
#' colonne_code_postal = "code_postal")
#' }

phaco_geocode <- function(data_to_geocode,
                          # colonne_rue = NULL,
                          # colonne_num = NULL,
                          # colonne_code_postal = NULL,
                          # colonne_num_rue = NULL,
                          # colonne_num_rue_code_postal = NULL,
                          # colonne_rue_code_postal = NULL,
                          rue,
                          num,
                          code_postal,
                          method_stringdist = "lcs",
                          corrections_REGEX = TRUE,
                          error_max = 4,
                          approx_num_max = 50,
                          elargissement_com_adj = TRUE,
                          mid_street = TRUE,
                          lang_encoded = c("FR", "NL", "DE"),
                          anonymous = FALSE,
                          path_data = NULL) {


  start_time <- Sys.time()

  # Assert situation

  rlang::check_required(rue)
  rlang::check_required(code_postal)

  rue_sym <- ensym(rue)
  num_sym <- ensym(num)
  cp_sym <- ensym(code_postal)

  have_number <- FALSE
  integrated_number <- FALSE
  integrated_postcode <- FALSE


  if (!missing(num)) {
    have_number <- TRUE

    if (setequal(data_to_geocode |> pull(!!rue_sym), data_to_geocode |> pull(!!num_sym))) {
      integrated_number <- TRUE
    }
  }

  if (setequal(data_to_geocode |> pull(!!rue_sym), data_to_geocode |> pull(!!cp_sym))) {
    integrated_postcode <- TRUE
  }

  # print(glue::glue("
  #   have_number : {have_number}
  #   integrated_number : {integrated_number}
  #   integrated_postcode : {integrated_postcode}"))


  # Definition du chemin ou se trouve les donnees
  if(is.null(path_data)){
    path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr_branchdev"),"/data_phacochr/")) # bricolage pour windows
  }

  # Fonction utilisee dans le script => https://www.r-bloggers.com/2018/07/the-notin-operator/
  `%ni%` <- Negate(`%in%`)

  # Ne pas lancer la fonction si les arguments ne sont pas corrects
  # La logique : une boucle sur les arguments de la fonction stockes dans une liste (pour ne pas changer leur type : string, logical...)
  # list_arg_null_string <- list(path_data = path_data)
  #
  # for (i in seq_along(list_arg_null_string)) {
  #   if(length(list_arg_null_string[[i]]) > 1) {
  #     cat("\n")
  #     stop(paste0("\u2716 ", names(list_arg_null_string[i]), " doit etre un vecteur de longueur 1"))
  #   }
  #   if(!is.null(list_arg_null_string[[i]])) {
  #     if(!is.character(list_arg_null_string[[i]])){
  #       cat("\n")
  #       stop(paste0("\u2716 ", names(list_arg_null_string[i]), " doit etre un vecteur string"))
  #     }
  #   }
  # }

  list_arg_logical <- list(corrections_REGEX = corrections_REGEX,
                           elargissement_com_adj = elargissement_com_adj,
                           mid_street = mid_street,
                           anonymous = anonymous)

  for (i in seq_along(list_arg_logical)) {
    if(length(list_arg_logical[[i]]) > 1) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_logical[i]), " doit etre un vecteur de longueur 1"))
    }
    if(!is.logical(list_arg_logical[[i]])) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_logical[i]), " doit etre une valeur logique"))
    }
  }

  list_arg_num <- list(error_max = error_max,
                       approx_num_max = approx_num_max)


  for (i in seq_along(list_arg_num)) {
    if(length(list_arg_num[[i]]) > 1) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_num[i]), " doit etre un vecteur de longueur 1"))
    }
    if(!is.numeric(list_arg_num[[i]])) {
      cat("\n")
      stop(paste0("\u2716 ", names(list_arg_num[i]), " doit etre une valeur numerique"))
    }
  }

  # Ici plus de boucle, pas necessaire
  if(length(method_stringdist) > 1) {
    cat("\n")
    stop(paste0("\u2716 "," method_stringdist doit etre un vecteur de longueur 1"))
  }
  if(!is.character(method_stringdist)) {
    cat("\n")
    stop(paste0("\u2716"," method_stringdist doit etre un vecteur string"))
  }
  method_stringdist <- str_to_lower(unique(method_stringdist)) # Au cas ou l'utilisateur aurait introduit les langues en majuscule
  if(sum(method_stringdist %in% c("osa", "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")) == 0) {
    cat("\n")
    stop(paste0("\u2716"," method_stringdist doit prendre une des valeurs : 'osa', 'lv', 'dl', 'hamming', 'lcs', 'qgram', 'cosine', 'jaccard', 'jw', 'soundex'"))
  }
  if(!is.character(lang_encoded)) {
    cat("\n")
    stop(paste0("\u2716"," lang_encoded doit etre un vecteur string"))
  }
  lang_encoded <- str_to_upper(unique(lang_encoded)) # Au cas ou l'utilisateur aurait introduit les langues en minuscule
  if(sum(lang_encoded %in% c("FR", "NL", "DE")) == 0) {
    cat("\n")
    stop(paste0("\u2716"," lang_encoded doit prendre une des valeurs : 'FR', 'NL', 'DE'"))
  }

  # Ne pas lancer la fonction si les fichiers ne sont pas presents (cad qu'ils ne sont, en toute logique, pas installes)
  if (!all(file.exists(
    paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.parquet"),
    paste0(path_data,"BeST/PREPROCESSED/openaddress_be_PREPROCESSED.parquet"),
    paste0(path_data,"BeST/PREPROCESSED/table_commune_adjacentes.csv"),
    paste0(path_data,"BeST/PREPROCESSED/table_INS_recod_code_postal.csv"),
    paste0(path_data,"BeST/PREPROCESSED/table_postal_com_name.csv"),
    paste0(path_data,"STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv")
    ))) {

    cat("\n")
    stop(paste0("\u2716"," les fichiers ne sont pas install","\u00e9","s : lancez phaco_setup_data()"))

  }

  # On ne lance pas la fonction si des noms de colonnes du fichier a geocoder ont des noms de colonnes similaires a ceux utilises en interne
  # Pour l'instant on demande de changer les noms en indiquant ceux qui posent pb
  # Alternatives plus performantes dans le futur :
  # 1) d'abord mettre des noms moins communs a l'aide d'un prefixe
  # 2) changer automatiquement les noms qui posent pb avec un suffice _2, _3, etc.
  forbidden_names <- c("ID_address", "rue_to_geocode", "num_rue_to_geocode", "code_postal_to_geocode", "arrond", "Region", "num_rue_text", "num_rue_clean", "rue_recoded", "rue_recoded_commune",
                       "rue_recoded_code_postal", "rue_recoded_virgule", "rue_recoded_deux_points", "rue_recoded_parenthese", "rue_recoded_slash", "rue_recoded_boite", "rue_recoded_BP_CP",
                       "rue_recoded_No", "rue_recoded_num", "rue_recoded_Rez", "rue_recoded_Bis", "rue_recoded_Rdc", "rue_recoded_Commandant", "rue_recoded_Lieutenant", "rue_recoded_Saint",
                       "rue_recoded_chaussee", "rue_recoded_avenue", "rue_recoded_koning", "rue_recoded_professor", "rue_recoded_square", "rue_recoded_steenweg", "rue_recoded_burg",
                       "rue_recoded_dokter", "rue_recoded_boulevard", "rue_recoded_route", "rue_recoded_place", "rue_recoded_Rue", "rue_recoded_apostrophe", "rue_recoded_lettre_end",
                       "rue_recoded_lettre_end2", "rue_recoded_tiret", "recode", "street_id_phaco", "postal_id", "street_FINAL_detected", "langue_FINAL_detected", "nom_propre_abv", "mid_num",
                       "mid_x_31370", "mid_y_31370", "mid_cd_sector", "dist_fuzzy", "min", "address_join", "address_join_street", "distance_jw", "min_jw", "type_geocoding", "Refnis code",
                       "house_number_sans_lettre", "x_31370", "y_31370", "cd_sector", "approx_num", "type_geocoding2", "tx_sector_descr_nl", "tx_sector_descr_fr",
                       "cd_sub_munty", "tx_sub_munty_nl", "tx_sub_munty_fr", "tx_munty_dstr", "cd_munty_refnis", "tx_munty_descr_nl", "tx_munty_descr_fr", "cd_dstr_refnis", "tx_adm_dstr_descr_nl",
                       "tx_adm_dstr_descr_fr", "cd_prov_refnis", "tx_prov_descr_nl", "tx_prov_descr_fr", "cd_rgn_refnis", "tx_rgn_descr_nl", "tx_rgn_descr_fr", "MDRC", "NAME_FRE", "NAME_DUT",
                       "cd_sector_x_31370", "cd_sector_y_31370", "phaco_anonymous")

  if (any(names(data_to_geocode) %in% forbidden_names)) {
    cat("\n")
    stop(paste0("\u2716"," des noms de colonnes de votre fichier sont similaires ","\u00e0"," certains utilis","\u00e9"," en interne par phaco_geocode(). Changez les noms de colonnes suivants : ", paste(intersect(names(data_to_geocode), forbidden_names), collapse = ", ")))
  }



  # 0. FORMATAGE DES DONNEES ==================================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  cat("--- PhacochR ---")

  cat(paste0("\n","-- Formatage des donn","\u00e9","es"))

  #cat(paste0("\n","\u29D7"," Pr","\u00e9","paration et v","\u00e9","rification des donn","\u00e9","es..."))


  ## 1. Formatage des donnees -----------------------------------------------------------------------------------------------------------------

  colourise("\u2139", fg= "blue")

  # Creation d'un ID unique
  data_to_geocode <- data_to_geocode |>
    mutate(ID_address = row_number()) |>
    relocate(ID_address)

  # Creation/formatage des colonnes pour le geocodage

  if (have_number) {
    if (integrated_number) {
      if (integrated_postcode) {
        # if (situation == "num_rue_postal_i") {
          data_to_geocode <- data_to_geocode |>
            mutate(rue_to_geocode = !!rue_sym)
        # }
      }
      # if (situation == "num_rue_i_postal_s") {
        data_to_geocode <- data_to_geocode |>
          mutate(rue_to_geocode = !!rue_sym)
      # }
    } else {
      # if (situation == "num_rue_postal_s") {
        data_to_geocode <- data_to_geocode |>
          mutate(rue_to_geocode = !!rue_sym,
               num_rue_to_geocode = !!num_sym)
        # }
    }
  } else {
    if (integrated_postcode) {
      # if (situation == "no_num_rue_postal_i") {
        data_to_geocode <- data_to_geocode |>
          mutate(rue_to_geocode = !!rue_sym)
      # }
    }
    # if (situation == "no_num_rue_postal_s") {
      data_to_geocode <- data_to_geocode |>
        mutate(rue_to_geocode = !!rue_sym)
    # }
  }



  # Les rues vides "" sont recodees en NA
  data_to_geocode <- data_to_geocode |>
    mutate(
      rue_to_geocode = str_squish(rue_to_geocode),
      rue_to_geocode = ifelse(rue_to_geocode == "", NA, rue_to_geocode)
    )

  # Un stop() si la colonne contenant la rue ne possede que des NA
  if (all(is.na(data_to_geocode$rue_to_geocode))) {
    cat("\n")
    stop(paste0("\u2716"," La colonne contenant la rue ne contient que des NA"))
  }

  # Code postal (si separe)
  if (!integrated_postcode) {
  # if (situation == "num_rue_postal_s" | situation == "num_rue_i_postal_s" | situation == "no_num_rue_postal_s") {
    data_to_geocode <- data_to_geocode %>%
      mutate(code_postal_to_geocode = !!cp_sym)
  }


  ## 2. Code postal ---------------------------------------------------------------------------------------------------------------------------

  # Je m'assure que le code postal ne comprend pas de texte => je ne garde que les chiffres du code postal
  if (integrated_postcode) {

    data_to_geocode <- data_to_geocode |>
      mutate(
        code_postal_to_geocode = str_extract(rue_to_geocode, regex("([1-9][0-9]{3}\\s[\\p{Letter}-' ]+\\z)|([1-9][0-9]{3}(|\\s)\\z)", ignore_case = TRUE))
      )
  }

  data_to_geocode <- data_to_geocode |>
    mutate(
      code_postal_to_geocode = str_extract(code_postal_to_geocode, regex("[1-9][0-9]{3}", ignore_case = TRUE))
    )


  ## 3. Detection des regions/arrondissements en Belgique -------------------------------------------------------------------------------------
  # Cette partie directement apres le code postal pour pouvoir arreter si le code postal n'est pas valide
  table_postal_arrond <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_postal_arrond.csv"), delim = ";", progress= F,  col_types = cols(.default = col_character()))

  data_to_geocode <- data_to_geocode %>%
    left_join(table_postal_arrond, by = c("code_postal_to_geocode" = "postcode"))

  # @@@@@@@@@@ Tout le script se lance uniquement s'il y a des codes postaux en Belgique ! @@@@@@@@@@
  # Dans le cas contraire => message d'erreur

  # TODO : Replace with regex [1-9]{1}[0-9]{3} -> if(any(str_detect(cp, regex)))
  # Only load the file for the region when we use it at the end
  if (length(unique(data_to_geocode$Region[!is.na(data_to_geocode$Region)])) == 0) {
    cat("\n")
    stop(paste0("\u2716"," il n'y a aucun code postal belge dans le fichier (ou erreur d'encodage)"))
  }

  cat(paste0("\n",colourise("\u2139", fg= "blue")," R","\u00e9","gion(s) d","\u00e9","tect","\u00e9","e(s) : ",
             paste(unique(data_to_geocode$Region[!is.na(data_to_geocode$Region)]),
                   collapse = ', ')))


  ## 4. Numero de rue -------------------------------------------------------------------------------------------------------------------------
  # Pour creer un numero de rue clean + aller chercher le numero de la rue dans le champ texte de l'adresse (s'il est present)

  # Dans le cas ou il y a une colonne separee avec le num de rue

  if (have_number & !integrated_number) { # Do we let user choose if he want to do this since he explicitly say that the number is a specific column
  # if (situation == "num_rue_postal_s") {

  data_to_geocode <- data_to_geocode |>
    mutate(
      num_rue_clean = ifelse(
        is.na(num_rue_to_geocode) | !str_detect(num_rue_to_geocode, regex("[0-9]", ignore_case = TRUE)),
        regex_extract_number_from_address(rue_to_geocode),
        NA),
      num_rue_clean = ifelse(
        is.na(num_rue_clean),
        regex_extract_number(num_rue_to_geocode),
        num_rue_clean)
    )
  }


  # Dans le cas ou le num de rue est integre
  # NOTE /!\ le numero de rue doit IMPERATIVEMENT etre le premier chiffre du champ (souvent le cas) /!\
  if (have_number & integrated_number) {

    data_to_geocode <- data_to_geocode |>
      mutate(num_rue_clean = regex_extract_number_from_address(rue_to_geocode))

  }


  # On force mid_street = TRUE si la colonne contenant la rue ne possede que des NA
  if (!mid_street & have_number) {
  # if (mid_street == FALSE & (situation == "num_rue_postal_s" | situation == "num_rue_i_postal_s" | situation == "num_rue_postal_i")) {
    if(all(is.na(data_to_geocode$num_rue_clean)))
      # sum(is.na(data_to_geocode$num_rue_clean))/sum(nrow(data_to_geocode)) == 1
    {
      cat(colourise(paste0("\n","\u2192"," La colonne contenant le num","\u00e9","ro ne contient que des NA : switch mid_street = TRUE"), fg="brown"))
      mid_street <- TRUE
    }
  }


  # I. REGEX adresses (corrections) =========================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  if (integrated_postcode | integrated_number) {
  # if ((situation == "num_rue_i_postal_s"|situation == "num_rue_postal_i"|situation == "no_num_rue_postal_i") & corrections_REGEX == FALSE){
    cat(colourise(paste0("\n","\u2192"," La colonne contenant la rue est m","\u00e9","lang","\u00e9","e avec le num","\u00e9","ro ou le code postal : switch corrections_REGEX = TRUE"), fg="brown"))
    corrections_REGEX <- TRUE
  }

  # On cree une nouvelle colonne avec le nom de rue corrige + des colonnes avec TRUE / FALSE pour identifier les familles de changements
  if (corrections_REGEX) {

    cat(paste0("\n","\u29D7"," Correction orthographique des adresses"))

    # On cree rue_recoded qui contient toutes les corrections et sera l'objet du fuzzy matching apres
    data_to_geocode <- data_to_geocode %>%
      mutate(
        rue_recoded = ifelse(!is.na(rue_to_geocode), paste0(rue_to_geocode,"   "), NA),
        rue_recoded_commune = NA, # Pour la compatibilite avec la suite si le code postal n'est pas integre et supprime
        rue_recoded_code_postal = NA) # Pour la compatibilite avec la suite si le code postal n'est pas integre et supprime

    # Suppression du code postal ssi interne au champ d'adresse
    if (integrated_postcode) {
    # if (situation == "num_rue_postal_i" | situation == "no_num_rue_postal_i") {


      data_to_geocode <- data_to_geocode |>
        mutate(rue_recoded = regex_remove_postcode(rue_recoded))

    }

    # Les corrections a proprement parler
    # NOTE : en faire une fonction, et trouver une syntaxe plus pratique (une boucle ?)

    data_to_geocode <- data_to_geocode |>
      mutate(
        rue_recoded = regex_correct_street(rue_recoded),
        rue_recoded = if_else(rue_recoded == "", NA, rue_recoded))

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


  # On cree rue_recoded meme si corrections_REGEX == FALSE => necessaire car le fuzzy matching se fait sur cette colonne
  if (!corrections_REGEX & !integrated_postcode) {
    data_to_geocode <- data_to_geocode %>%
      mutate(rue_recoded = str_squish(rue_to_geocode),
             recode = NA)
  }


  cat(paste0("\033[K","\r",colourise("\u2714", fg="green")," Correction orthographique des adresses", "\033[K"))


  # II. GEOCODAGE ===========================================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ## 0. Parametres/fonctions ----------------------------------------------------------------------------------------------------------------

  n.cores <- detect_n_cores(min_free_cores = 1)

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
  # postal_street <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"), delim = ";", progress= F,  col_types = cols(.default = col_character())) %>%
    postal_street <- arrow::open_dataset(paste0(path_data,"BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.parquet")) |> collect()

  if (length(lang_encoded) != 3){
    postal_street <- postal_street %>%
      filter(langue_FINAL_detected %in% lang_encoded)
  }

  # On filtre + creation d'une cle de jointure
  data_to_geocode <- data_to_geocode %>%
    mutate(address_join = str_to_lower(str_trim(rue_recoded)))


  ### ii) Boucle de jointure par commune ----------------------------------------------------------------------------------------------------

  # /!\ NOTE : la cle de jointure est en minuscule (d'ou les str_to_lower() avant), car stringdist identifie la diff de case comme une diff !
  # /!\ NOTE2 : la jointure cree les colonnes de postal_street, meme si 0 match ! Important pour la suite, notamment le if statement pour la creation de l'objet sf
  res <- address_fuzzy_matching_by_group(
    data_to_geocode, postal_street,
    cols_to_match = c("address_join" = "address_join_street"),
    group_by = c("code_postal_to_geocode" = "postal_id"),
    method = method_stringdist,
    max_dist = error_max,
    nthread = n.cores)

  cat(paste0("\r",colourise("\u2714", fg="green")," D","\u00e9","tection des rues (matching inexact avec fuzzyjoin)", "\033[K"))

  # On ne retient que l'adresse detectee avec la distance minimale

  res <- res |>
    filter(dist_fuzzy == min(dist_fuzzy) | is.na(dist_fuzzy), .by = ID_address) |>
    select(-postal_id)

  # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler dans un if statement + au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
  # Si ca ne se lance pas, on supprime les cles de jointure dont on n'a plus besoin
  if (!anyDuplicated(res$ID_address)) {
    res <- res %>%
      select(-address_join, -address_join_street)
  }

  if (anyDuplicated(res$ID_address)) {

    cat(paste0("\n","\u29D7"," Ex-aequos : calcul de la distance Jaro-Winkler pour d","\u00e9","partager"))

    res <- res %>%
      mutate(distance_jw = stringdist(address_join, address_join_street, method = "jw", p = 0.1, nthread = n.cores)) %>% # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler
      group_by(ID_address) %>%
      filter(distance_jw == min(distance_jw) | is.na(distance_jw)) %>%
      sample_n(1) %>% # Au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
      select(-distance_jw, -address_join, -address_join_street)

    cat(paste0("\r",colourise("\u2714", fg="green")," Ex-aequos : calcul de la distance Jaro-Winkler pour d","\u00e9","partager"))
  }



  res <- res %>%
    # relocate(street_FINAL_detected, .after = recode) %>%
    mutate(type_geocoding = NA,
           type_geocoding = as.character(type_geocoding)) # pour compatibilite avec res_adj si res = NA


  ### iii) Elargissement de la boucle aux communes adjacentes -------------------------------------------------------------------------------
  # On supprime la contrainte de recherche de la rue dans la commune, pour augmenter le % de rues detectees

  if (elargissement_com_adj) {

    cat(paste0("\n","\u29D7"," \u00c9","largissement pour les rues non trouv","\u00e9","es aux communes adjacentes"))

    # On ne retient que les adresses dont les rues n'ont pas ete detectees
    ADDRESS_last_tentative <- res %>%
      filter(is.na(dist_fuzzy)) %>%
      mutate(address_join = str_to_lower(str_trim(rue_recoded))) %>%
      # On supprime les colonnes jointes par le fuzzy_join, puisqu'on va en refaire un elargi
      select(-street_FINAL_detected, -street_id_phaco, -langue_FINAL_detected, -nom_propre_abv, -ancien_nom_rue, -dist_fuzzy,
             -mid_num, -mid_x_31370, -mid_y_31370, -mid_cd_sector)

    if (nrow(ADDRESS_last_tentative) > 0) { # Un if au cas ou toutes les adresses auraient ete trouvees (alors il ne faut pas lancer la partie entre crochets)

      # On charge la table de conversion code postal > code INS recode (voir preprocessing)
      table_INS_recod_code_postal <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_INS_recod_code_postal.csv"), delim = ";",progress= F, col_types = cols(.default = col_character()))

      # On ajoute ce code INS recode 1) aux rues Best et 2) aux adresses non trouvees
      postal_street_adj <- postal_street %>%
        left_join(table_INS_recod_code_postal, by = c("postal_id" = "code_postal"))
      ADDRESS_last_tentative <- ADDRESS_last_tentative %>%
        left_join(table_INS_recod_code_postal, by = c("code_postal_to_geocode" = "code_postal"))

      # On charge la table des communes (= code INS recodes) adjacentes par commune (voir preprocessing)
      table_commune_adjacentes <- readr::read_delim(paste0(path_data,"BeST/PREPROCESSED/table_commune_adjacentes.csv"), progress= F, delim = ";", col_types = cols(.default = col_character()))

      res_adj <- foreach (i = unique(ADDRESS_last_tentative$`Refnis code`),
                          .combine = 'bind_rows',
                          .packages=c("dplyr","fuzzyjoin"))  %dopar% {

                            # On calcule un vecteur reprenant les communes adjacentes par commune i
                            com_adj_i <- table_commune_adjacentes$cd_munty_refnis_voisin[table_commune_adjacentes$cd_munty_refnis == i]

                            ADDRESS_last_tentative_i <- ADDRESS_last_tentative %>%
                              filter(`Refnis code` %in% i) %>%
                              select(-`Refnis code`)

                            postal_street_adj_i <- postal_street_adj %>%
                              filter(`Refnis code` %in% c(i, com_adj_i)) %>% # On inclut i dans c(i, com_adj_i) car le code postal est plus petit que i
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
          filter(dist_fuzzy == min(dist_fuzzy) | is.na(dist_fuzzy))

        # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler dans un if statement + au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
        # Si ca ne se lance pas, on supprime les cles de jointure dont on n'a plus besoin

        if (!anyDuplicated(res_adj$ID_address)) {
          res_adj <- res_adj %>%
            select(-address_join, -address_join_street)
        }

        if (anyDuplicated(res_adj$ID_address)) {
          res_adj <- res_adj %>%
            mutate(distance_jw = stringdist(address_join, address_join_street, method = "jw", p=0.1, nthread= n.cores)) %>% # Au cas ou il reste des doublons : nouveau calcul de distance Jaro-Winkler
            group_by(ID_address) %>%
            filter(distance_jw == min(distance_jw) | is.na(distance_jw)) %>%
            sample_n(1) %>% # Au cas ou il reste ENCORE des doublons : tirage aleatoire (arrive uniquement lorsque la tolerance est elevee)
            select(-distance_jw, -address_join, -address_join_street)
        }

        res_adj <- res_adj %>%
          # relocate(street_FINAL_detected, .after = recode) %>%
          mutate(type_geocoding = "elargissement_adj") %>%
          filter(!is.na(dist_fuzzy)) %>%
          mutate(code_postal_to_geocode = postal_id) %>%
          select(-postal_id)

        # On liste les ID_address geocodes dans cette nouvelle procedure
        ADDRESS_last_tentative_vector <- unique(res_adj$ID_address)

        # Et on les ajoute a res (prelablement deleste des adresses prealablement non trouvees mais desormais trouvees !)
        res <- res %>%
          filter(ID_address %ni% ADDRESS_last_tentative_vector) %>%
          bind_rows(res_adj)
      }
    }

    cat(paste0("\r",colourise("\u2714", fg="green")," \u00c9","largissement pour les rues non trouv","\u00e9","es aux communes adjacentes"))
  }


  ## 2)  Jointure des adresses --------------------------------------------------------------------------------------------------------------

  if (have_number) {
  # if (situation != "no_num_rue_postal_s" & situation != "no_num_rue_postal_i") {

    #### i. Preparation des fichiers adresses (BeST) ------------------------------------------------------------------------------------------

    cat(paste0("\n","\u29D7"," Chargement du fichier openaddress"))

    # Ici on cree une liste des adresses en n'important que les arrondissements detectes dans data_to_geocode

    openaddress_be <- arrow::open_dataset(paste0(path_data, "BeST/PREPROCESSED/openaddress_be_PREPROCESSED.parquet")) |>
      filter(street_id_phaco %in% unique(res$street_id_phaco)) |>
      collect()


    cat(paste0("\r",colourise("\u2714", fg="green")," Chargement du fichier openaddress "))


    #### ii. Jointure avec les adresses  ------------------------------------------------------------------------------------------------------

    cat(paste0("\n","\u29D7"," Jointure avec les coordonn","\u00e9","es X-Y"))

    # On joint aux rues detectees (res) les adresses pour obtenir les coord. x-y.
    FULL_GEOCODING <- res %>%
      # On joint par street_id x numero de rue (pour avoir la coord. x-y propre de cette adresse)
      left_join(openaddress_be, by = c("street_id_phaco", "num_rue_clean" = "house_number_sans_lettre")) %>%
      # Toutes les coord. trouvees = pas d'approximation
      mutate(approx_num = ifelse(!is.na(x_31370), 0, NA))

    cat(paste0("\r",colourise("\u2714", fg="green")," Jointure avec les coordonn","\u00e9","es X-Y"))


    ### iii. Approximation numero -------------------------------------------------------------------------------------------------------------

    # Ne s'applique que si approx_num_max > 0
    if (approx_num_max > 0) {

      cat(paste0("\n","\u29D7"," Approximation ", "\u00e0", " + ou - ", approx_num_max*2, " num","\u00e9","ros pour les adresses non localis","\u00e9","es"))

      # On selectionne les lignes pour lesquelles un numero de police a ete encode, on a trouve la rue, mais pour lesquelles on n'a pas trouve de correspondance dans les fichiers openaddress.
      FULL_GEOCODING_APPROX <- FULL_GEOCODING %>%
        filter(!is.na(street_id_phaco) & !is.na(num_rue_clean) & is.na(address_id)) %>%
        select(-x_31370, -y_31370, -cd_sector, -address_id, -approx_num)


      FULL_GEOCODING_APPROX <- FULL_GEOCODING_APPROX |>
        ungroup() |>
        # select(ID_address, num_rue_clean, street_id_phaco) |>
        inner_join(
          openaddress_be |> select(street_id_phaco, house_number_sans_lettre, x_31370, y_31370, cd_sector),
          by = c("street_id_phaco"),
          relationship = "many-to-many") |>
        mutate(
          is_same_side = is_same_parity(num_rue_clean, house_number_sans_lettre),
          approx_num = abs(num_rue_clean - house_number_sans_lettre),
          .by = ID_address) |>
        # Take number with minimum difference on the same side and under the max approximation allowed
        mutate(
          num_fix = if_else(approx_num == min(approx_num) & is_same_side & approx_num <= approx_num_max * 2, house_number_sans_lettre, NA),
          .by = c(is_same_side, ID_address)
        ) |>
        #
        mutate(
          num_fix = if_else(all(is.na(num_fix)) & approx_num == min(approx_num) & approx_num <= approx_num_max * 2, house_number_sans_lettre, num_fix),
          .by = ID_address
        ) |>
        filter(!is.na(num_fix)) |>
        group_by(ID_address) |>
        slice_sample_seeded(seed_cols = c(num_rue_clean, ID_address), n = 1)


      FULL_GEOCODING <- FULL_GEOCODING %>%
        filter(ID_address %ni% FULL_GEOCODING_APPROX$ID_address) %>%
        bind_rows(FULL_GEOCODING_APPROX)

      cat(paste0("\r",colourise("\u2714", fg="green")," Approximation ", "\u00e0", " + ou - ", approx_num_max*2, " num","\u00e9","ros pour les adresses non localis","\u00e9","es"))
    }
  }


  ## 3) Geocodage sans numero ---------------------------------------------------------------------------------------------------------------

  # On cree FULLGEOCODING si on est dans le cas d'absence de num (on geocode a la rue) => FULLGEOCODING n'a alors pas encore ete cree
  # On renomme les variables pour etre compatible avec le reste du script
  if (!have_number){
  # if (situation == "no_num_rue_postal_s" | situation == "no_num_rue_postal_i") {
    FULL_GEOCODING <- res %>%
      mutate(approx_num = NA,
             type_geocoding2 = ifelse(!is.na(mid_x_31370), "mid_street", NA)) %>%
      rename(cd_sector = mid_cd_sector,
             x_31370 = mid_x_31370,
             y_31370 = mid_y_31370)

    FULL_GEOCODING <- FULL_GEOCODING %>%
      unite(type_geocoding, c(type_geocoding, type_geocoding2), sep = " ; ", na.rm = TRUE) # unite doit fonctionner en dehors de mutate

  }

  # On indique le num du milieu de la rue si les coordonnee du batiment ne sont pas trouvee
  if (mid_street & have_number) {
  # if (mid_street == TRUE &(situation == "num_rue_postal_s"|situation == "num_rue_i_postal_s"|situation == "num_rue_postal_i")){

    FULL_GEOCODING <- FULL_GEOCODING %>%
      mutate(type_geocoding2 = ifelse(is.na(x_31370) & !is.na(mid_x_31370), "mid_street", NA),
             x_31370 = ifelse(is.na(x_31370) & !is.na(mid_x_31370), mid_x_31370, x_31370),
             y_31370 = ifelse(is.na(y_31370) & !is.na(mid_y_31370), mid_y_31370, y_31370),
             cd_sector = ifelse(is.na(cd_sector) & !is.na(mid_cd_sector), mid_cd_sector, cd_sector))

    FULL_GEOCODING <- FULL_GEOCODING %>%
      unite(type_geocoding, c(type_geocoding, type_geocoding2), sep = " ; ", na.rm = TRUE) # unite doit operer en dehors de mutate

  }


  # III. FICHIER FINAL  =====================================================================================================================
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  cat(paste0("\n","-- R","\u00e9","sultats"))

  cat(paste0("\n","\u29D7"," Cr","\u00e9","ation du fichier final et formatage des tables de v","\u00e9","rification"))


  ## 1) Jointure ----------------------------------------------------------------------------------------------------------------------------

  # Il manque potentiellement des lignes par rapport a la BD originale, car pas de code postal, ou qui ne matchent pas avec les donnees BeST => on les recupere par un antijoin(), et les ajoute
  MISSING <- data_to_geocode %>%
    anti_join(FULL_GEOCODING, by = "ID_address") %>%
    select(-address_join)

  FULL_GEOCODING <- FULL_GEOCODING %>%
    bind_rows(MISSING) %>%
    arrange(ID_address)

  # J'enleve num_rue_to_geocode : pas besoin dans l'objet final
  # Utilisation d'un if statement car la colonne n'est parfois pas creee
  if("num_rue_to_geocode" %in% colnames(FULL_GEOCODING)) {
    FULL_GEOCODING <- FULL_GEOCODING %>%
      select(-num_rue_to_geocode)
  }

  # On remet les bons noms de rue (ils sont abreges dans le cas des noms propres abreges, et on indique les nouvelles rues pour les anciennes)
  postal_street_join_final <- postal_street %>%
    filter(is.na(nom_propre_abv) & is.na(ancien_nom_rue)) %>%
    select(street_id_phaco, street_FINAL_detected_full = street_FINAL_detected, langue_FINAL_detected)

  FULL_GEOCODING <- as.data.frame(FULL_GEOCODING) %>% # On transforme en dataframe sinon ca pose pb dans la suite (a cause du foreach a priori ?)
    left_join(postal_street_join_final, by = c("street_id_phaco", "langue_FINAL_detected")) %>%
    relocate(street_FINAL_detected_full, .after = street_FINAL_detected) %>%
    select(-street_FINAL_detected, street_FINAL_detected = street_FINAL_detected_full)

  # @@@@@@@@@@ QUESTION : DOIT-ON AUSSI REMPLACER LES NOMS DES ANCIENNES RUES (CHARLEROI) PAR LES NOUVELLES ? @@@@@@@@@@

  # On joint les donnees de region, provinces, communes, quartiers (BXL)... aux secteurs stat
  table_secteurs_prov_commune_quartier <- readr::read_delim(paste0(path_data,"STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv"), delim = ";", progress= F, col_types = cols(.default = col_character()))

  FULL_GEOCODING <- FULL_GEOCODING %>%
    left_join(table_secteurs_prov_commune_quartier, by = "cd_sector")


  ## 2) Resultats recapitulatifs ------------------------------------------------------------------------------------------------------------
  Summary_region <- bind_rows(
    FULL_GEOCODING,
    FULL_GEOCODING |> mutate(Region = "Total") # Technique tres astucieuse pour ajouter un total au tableau de synthese avec le group_by > summarise!
  ) |>
    group_by(Region) |>
    summarise("n" = n(),
              "Valid rue(%)" = round((sum(!is.na(rue_to_geocode))/n())*100, 1),
              "Rue detect.(%valid)" = round((sum(!is.na(street_FINAL_detected))/sum(!is.na(rue_to_geocode)))*100,1),
              "stringdist (moy)" = mean(dist_fuzzy, na.rm = T),
              "Geocode(%tot)" = round((sum(!is.na(x_31370))/n())*100, 1),
              "Geocode(%valid)" = round((sum(!is.na(x_31370))/sum(!is.na(rue_to_geocode)))*100, 1),
              # "Approx (% geocodes)" = (sum(approx_num > 0, na.rm = T)/(sum(!is.na(x_31370))))*100,
              "Approx.(n)" = sum(approx_num > 0, na.rm = T),
              "Elarg.(n)" = (sum(str_detect(type_geocoding, "elargissement_adj"), na.rm = T)),
              "Mid.(n)" = (sum(str_detect(type_geocoding, "mid_street"), na.rm = T)),
              "Abrev.(n)" = (sum(nom_propre_abv == 1, na.rm = T)),
              "Rue FR" = (sum(langue_FINAL_detected == "FR", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Rue NL" = (sum(langue_FINAL_detected == "NL", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Rue DE" = (sum(langue_FINAL_detected == "DE", na.rm = T))/sum(!is.na(langue_FINAL_detected))*100,
              "Coord non valides" = sum(x_31370 == "0.00000", na.rm = T),
              "Dupliques" = sum(duplicated(ID_address)))

  Summary_original <- tibble(Region = "Total (original)",
                             "n" = nrow(data_to_geocode),
                             "Valid rue(%)" = NA,
                             "Rue detect.(%valid)" = NA,
                             "stringdist (moy)" = NA,
                             "Geocode(%tot)" = NA,
                             "Geocode(%valid)" = NA,
                             #"Approx (% geocodes)" = NA,
                             "Approx.(n)"=NA,
                             "Elarg.(n)" = NA,
                             "Mid.(n)" = NA,
                             "Abrev.(n)" = NA,
                             "Rue FR" = NA,
                             "Rue NL" = NA,
                             "Rue DE" = NA,
                             "Coord non valides" = NA,
                             "Dupliques" = sum(duplicated(data_to_geocode$ID_address)))


  Summary_full <- bind_rows(Summary_original, Summary_region) %>%
    slice(match(c("Total (original)", "Bruxelles", "Flandre", "Wallonie", NA, "Total"), Region))

  # J'enleve la region et les arrondissements, car doublon avec jointure dans le point precedent => pas ideal, mais necessaire pour importer les CSV par arrond avec map_dfr, pour le summary et au debut pour detecter les regions et ne pas executer si pas BE => optimiser ?
  # J'enleve aussi rue_to_geocode => plus besoin
  FULL_GEOCODING <- FULL_GEOCODING %>%
    select(-Region, -arrond, -rue_to_geocode)


  ## 3) Anonymisation potentielle -----------------------------------------------------------------------------------------------------------

  # Si l'anonymat est enclenche, supression de toutes les colonnes permettant de reconnaitre l'adresse

  if (anonymous == TRUE) {

    if (have_number) {
      if (integrated_number) {
        if (integrated_postcode) {
          # if (situation == "num_rue_postal_i") {
          data_to_geocode <- data_to_geocode %>%
            select(-!!rue_sym)
          # }
        }
        # if (situation == "num_rue_i_postal_s") {
        data_to_geocode <- data_to_geocode %>%
          select(-!!rue_sym)
        # }
      } else {
        # if (situation == "num_rue_postal_s") {
        data_to_geocode <- data_to_geocode %>%
          select(-c(!!rue_sym, !!num_sym))
        # }
      }
    } else {
      if (integrated_postcode) {
        # if (situation == "no_num_rue_postal_i") {
        data_to_geocode <- data_to_geocode %>%
          select(-!!rue_sym)
        # }
      }
      # if (situation == "no_num_rue_postal_s") {
      data_to_geocode <- data_to_geocode %>%
        select(-!!rue_sym)
      # }
    }


    FULL_GEOCODING <- FULL_GEOCODING %>%
      mutate(phaco_anonymous = ifelse(!is.na(cd_sector), 1, NA),  # On cree cette colonne pour signifier a phaco_map que c'est anonyme
             x_31370 = cd_sector_x_31370, # Dans le cas d'une anonymisation : les coordonnees = centroides des secteurs
             y_31370 = cd_sector_y_31370) |>
      select(-any_of(c("rue_recoded", "recode", "street_FINAL_detected", "num_rue_clean", "street_id_phaco", "langue_FINAL_detected", "nom_propre_abv", "mid_num", "mid_x_31370", "mid_y_31370", "mid_cd_sector", "house_number_sans_lettre", "cd_sector_x_31370", "cd_sector_y_31370")))


  }



  ## 4) Creation de l'objet SF avec les coordonnees -----------------------------------------------------------------------------------------

  if (sum(!is.na(FULL_GEOCODING$x_31370)) > 0){ # On cree un objet sf uniquement s'il y a des coordonnees
    # NOTE : l'objet sf ne peut pas contenir de NA pour les coordonnees
    FULL_GEOCODING_sf <- FULL_GEOCODING %>%
      filter(!is.na(x_31370)) %>%
      st_as_sf(coords = c("x_31370", "y_31370")) %>%  # on cree l'objet sf
      st_set_crs(31370) # on definit le systeme de projection
  }

  result <- list()
  result$summary <- Summary_full
  result$data_geocoded <- FULL_GEOCODING
  if (sum(!is.na(FULL_GEOCODING$x_31370)) > 0){ # On cree un objet sf uniquement s'il y a des coordonnees
    result$data_geocoded_sf <- FULL_GEOCODING_sf
  }
  # remplacer par 0 les NA (pas tres propre)
  result$summary$`Approx.(n)`[is.na(result$summary$`Approx.(n)`)] <- 0

  # On stoppe la parallelisation
  parallel::stopCluster(cl = my.cluster)

  cat(paste0("\r",colourise("\u2714", fg="green")," Cr","\u00e9","ation du fichier final et formatage des tables de v","\u00e9","rification"))
  cat(paste0("\n",colourise("\u2714", fg="green")," G","\u00e9","ocodage termin","\u00e9"))
  cat(paste0("\n",colourise("\u2139", fg= "blue")," Statistiques concernant le g","\u00e9","ocodage:"))

  end_time <- Sys.time()

  tab<-knitr::kable(result$summary[2:nrow(result$summary),c("Region", "n", "Valid rue(%)", "Rue detect.(%valid)", "Approx.(n)", "Elarg.(n)", "Mid.(n)", "Geocode(%valid)", "Geocode(%tot)")],
                    format = "pipe",
                    align="lrccccccc")
  cat("\n",tab, sep="\n" )

  cat(paste0("\n",colourise("\u2139", fg= "blue"), " Temps de calcul total : ", round(difftime(end_time, start_time, units = "secs")[[1]], digits = 1), " s
             "))
  cat(paste0("\n",colourise("/!\\", fg="red"), " Toutes les adresses n'ont pas ","\u00e9","t","\u00e9"," trouv","\u00e9","es avec certitude ", colourise("/!\\", fg="red"),"
- check \'dist_fuzzy\' pour les erreurs de reconnaissance des rues
- check \'approx_num\' pour les approximations de num","\u00e9","ro
- check \'type_geocoding\' pour l'","\u00e9","largissement aux communes adjacentes et le g","\u00e9","ocodage au milieu de la rue
- check \'nom_propre_abv\' pour les abr","\u00e9","viations de noms propres
             "))

  if (anonymous == TRUE) {
    cat(paste0("\n",colourise(paste0(" /!\\ Anonymisation enclench", "\u00e9e (supression des adresses) /!\\\n"), fg= "brown")))
  }

  cat(paste0("\n",colourise(paste0("-- Plus de r","\u00e9","sultats:"), fg= "light cyan"),
             "\n",colourise('\u2192', fg= "blue")," Tableau synth","\u00e9","tique : ","$summary",
             "\n",colourise('\u2192', fg= "blue")," Donn","\u00e9","es g","\u00e9","ocod","\u00e9","es : $data_geocoded",
             "\n",colourise('\u2192', fg= "blue")," Donn","\u00e9","es g","\u00e9","ocod","\u00e9","es en format sf : $data_geocoded_sf"))


  return(result)
}

