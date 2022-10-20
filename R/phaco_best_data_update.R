#' phaco_best_data_update
#'
#' @param force force le update meme si les donnees sont a jour
#'
#' @import rappdirs
#' @import readr
#' @import readxl
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import lubridate
#' @import sf
#' @import sp
#' @import spdep
#' @importFrom stats quantile
#'
#' @export
#'
#' @examples
#' phaco_best_data_update()

phaco_best_data_update <- function(force=FALSE) {
  options(warn=-1) # supprime les warnings

  # 0. Mise a jour --------------------------------------------------------------------------------------------------------------------------

  path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows

  # Ne pas lancer la fonction si les fichiers ne sont pas presents (cad qu'ils ne sont, en tout logique, pas installes)
  if(sum(
    file.exists(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"),
                paste0(path_data, "URBIS/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.gpkg"),
                paste0(path_data, "STATBEL/prenoms/TA_POP_2018_M.xlsx"),
                paste0(path_data, "STATBEL/prenoms/TA_POP_2018_F.xlsx"),
                paste0(path_data, "STATBEL/code_postaux/Conversion Postal code_Refnis code_va01012019.xlsx")
    )
  ) != 5) {
    stop(paste0("\u2716"," les fichiers ne sont pas install","\u00e9","s : lancez phaco_setup_data()"))
  }

  # Mise a jour si pas deja il y a moins de 7 jours
  cat(paste0(" -- Mise ","\u00e0", " jour des donn","\u00e9","es BeST pour PhacochR --"))


  # Premiere fois
  if (!file.exists(paste0(path_data, "BeST/openaddress/log.csv"))){
    log <- data.frame(update = "0001-01-01 00:00:00 UTC")
    write_csv2(log, paste0(path_data, "BeST/openaddress/log.csv"), progress=F)
    }


  log <- readr::read_delim(paste0(path_data, "BeST/openaddress/log.csv"), delim= ",", progress= F, show_col_types = FALSE)
  log$update <- as.POSIXct(log$update)

  if (max(as.Date(log$update)) + days(7) < Sys.Date()| force==TRUE) {

    cat(paste0("\n", "\u29D7"," T", "\u00e9", "l", "\u00e9", "chargement des donn", "\u00e9", "es BeST...","\n"))

    options(timeout=300)

    download.file("https://opendata.bosa.be/download/best/postalstreets-latest.zip", paste0(path_data, "BeST/openaddress/postalstreets-latest.zip"))
    download.file("https://opendata.bosa.be/download/best/openaddress-bevlg.zip", paste0(path_data, "BeST/openaddress/openaddress-bevlg.zip"))
    download.file("https://opendata.bosa.be/download/best/openaddress-bebru.zip", paste0(path_data, "BeST/openaddress/openaddress-bebru.zip"))
    download.file("https://opendata.bosa.be/download/best/openaddress-bewal.zip", paste0(path_data, "BeST/openaddress/openaddress-bewal.zip"))

    # Test si les donnees ont ete telechargees
    if(sum(
      file.exists(paste0(path_data,"BeST/openaddress/postalstreets-latest.zip"),
                  paste0(path_data,"BeST/openaddress/openaddress-bevlg.zip"),
                  paste0(path_data,"BeST/openaddress/openaddress-bebru.zip"),
                  paste0(path_data,"BeST/openaddress/openaddress-bewal.zip")
                  )
      ) != 4) {
      stop(paste0("\u2716"," les fichiers n'ont pas pu", " \u00ea", "tre download","\u00e9","s : relancez phaco_update() ou v","\u00e9","rifiez votre connexion"))
    }
    cat(paste0("\n", colourise("\u2714", fg="green")," T", "\u00e9", "l", "\u00e9", "chargement des donn", "\u00e9", "es BeST"))
    cat(paste0("\n","\u29D7"," D","\u00e9","compression des donn","\u00e9","es"))


    unzip(paste0(path_data, "BeST/openaddress/postalstreets-latest.zip"), exdir= paste0(path_data, "BeST/openaddress"))
    file.remove(paste0(path_data, "BeST/openaddress/postalstreets-latest.zip"))

    unzip(paste0(path_data, "BeST/openaddress/openaddress-bevlg.zip"), exdir= paste0(path_data, "BeST/openaddress"))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bevlg.zip"))

    unzip(paste0(path_data, "BeST/openaddress/openaddress-bebru.zip"), exdir= paste0(path_data, "BeST/openaddress"))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bebru.zip"))

    unzip(paste0(path_data, "BeST/openaddress/openaddress-bewal.zip"), exdir= paste0(path_data, "BeST/openaddress"))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bewal.zip"))


    # Test si les donnees ont ete ecrite (plus pour la suite => si ca marche ici ca marchera apres)
    if(sum(
      file.exists(paste0(path_data,"BeST/openaddress/Brussels_postal_street.csv"),
                  paste0(path_data,"BeST/openaddress/Wallonia_postal_street.csv"),
                  paste0(path_data,"BeST/openaddress/Flanders_postal_street.csv"),
                  paste0(path_data,"BeST/openaddress/openaddress-bebru.csv"),
                  paste0(path_data,"BeST/openaddress/openaddress-bewal.csv"),
                  paste0(path_data,"BeST/openaddress/openaddress-bevlg.csv")
      )
    ) != 6) {
      stop(paste0("\u2716"," les fichiers n'ont pas pu", " \u00ea", "tre d","\u00e9","compress","\u00e9","s : v","\u00e9","rifiez vos droits d'","\u00e9","criture sur le disque"))
    }


    log[nrow(log)+1,] <- Sys.time()
    write_csv2(log, paste0(path_data, "BeST/openaddress/log.csv"), progress=F)
    cat(paste0("\r",colourise("\u2714", fg="green")," D","\u00e9","compression des donn","\u00e9","es"))



    # 1. Fichier rues -------------------------------------------------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7", " Cr", "\u00e9", "ation du fichier des rues BeST"))

    # Fonction pour extraire les rues
    extract_street <- function(x) {
      temp <- x %>%
        mutate(street_id_phaco=1:n()) %>%
        pivot_longer(cols = c("street_fr", "street_nl", "street_de"),
                     values_to = "street_FINAL_detected",
                     names_to = "langue_FINAL_detected") %>%
        filter(!is.na(street_FINAL_detected)) %>%
        mutate(langue_FINAL_detected = recode(langue_FINAL_detected,
                                             "street_fr" = "FR",
                                             "street_nl" = "NL",
                                             "street_de" ="DE"),
               key_street_unique = paste(street_FINAL_detected, postal_id)) %>%
        distinct(key_street_unique, .keep_all = TRUE) %>%
        select(street_id_phaco, postal_id, street_FINAL_detected, langue_FINAL_detected, key_street_unique) %>%
      return(temp)
    }


    Brussels_postal_street <- readr::read_delim(paste0(path_data, "BeST/openaddress/Brussels_postal_street.csv"), progress= F, col_types = cols(.default = col_character()))
    Wallonia_postal_street <- readr::read_delim(paste0(path_data, "BeST/openaddress/Wallonia_postal_street.csv"), progress= F, col_types = cols(.default = col_character()))
    Flanders_postal_street <- readr::read_delim(paste0(path_data, "BeST/openaddress/Flanders_postal_street.csv"), progress= F, col_types = cols(.default = col_character()))

    belgium_street <- bind_rows(Brussels_postal_street,Wallonia_postal_street, Flanders_postal_street)
    belgium_street <- extract_street(belgium_street)

    cat(paste0("\r", colourise("\u2714", fg="green"), " Cr", "\u00e9", "ation du fichier des rues BeST"))

    # 2. Fichier adresses ---------------------------------------------------------------------------------------------------------------------

    cat(paste0("\n",  "\u29D7"," Cr", "\u00e9", "ation du fichier des adresses BeST (jointure spatiale avec les secteurs statistiques)"))

    # Fonction pour selectionner les variables et creer un ID street
    select_id_street <- function(x) {
      temp <- x %>%
        rename("x_31370" = "EPSG:31370_x",
               "y_31370" = "EPSG:31370_y") %>%
        filter(x_31370 != "0.00000") %>%
        mutate(x_31370 = round(as.numeric(x_31370), 0),
               y_31370 = round(as.numeric(y_31370), 0),
               house_number_sans_lettre = str_extract(house_number, regex("[0-9]+", ignore_case = TRUE))) %>%
        select(house_number_sans_lettre, streetname_de, streetname_fr, streetname_nl, postcode, x_31370, y_31370) %>%
        distinct(house_number_sans_lettre, streetname_de, streetname_fr, streetname_nl, postcode, .keep_all = TRUE) %>%
        pivot_longer(cols=  c("streetname_de", "streetname_fr", "streetname_nl"),
                     values_to = "street_name",
                     names_to = "langue") %>%
        filter(!is.na(street_name)) %>%
        mutate(key_street_unique = paste(street_name, postcode)) %>%
        left_join(belgium_street, by = "key_street_unique") %>%
        select(house_number_sans_lettre, street_id_phaco, x_31370, y_31370, postcode) %>%
        distinct(house_number_sans_lettre, street_id_phaco, postcode, .keep_all = TRUE) # J'enleve les coordonnees car 1 adresse en double avec des coordonnees differentes (?)
      return(temp)
    }

    # Fonction pour faire la jointure spatiale avec les secteurs statistiques
    join_ss_adress <- function(x) {
      temp <- x %>%
        st_as_sf(coords = c("x_31370", "y_31370"), remove = FALSE) %>%
        st_set_crs(31370) %>%
        st_join(BE_SS_lite_sector_arrond) %>%
        as.data.frame() %>%
        select(- geometry) %>%
      return(temp)
    }

    # Charger le fichier secteurs statistiques
    BE_SS <- st_read(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"), quiet=T, crs= 31370) %>%
      st_zm(drop = TRUE)

    BE_SS_lite_sector_arrond <- BE_SS %>%
      select(cd_sector, cd_dstr_refnis) %>%
      mutate(arrond= as.numeric(substr(cd_dstr_refnis, 1, 2))) %>%
      select(-cd_dstr_refnis)

    # Bruxelles
    openaddress_bebru <- readr::read_delim(paste0(path_data, "BeST/openaddress/openaddress-bebru.csv"), progress= F, col_types = cols(.default = col_character()))
    openaddress_bebru <- select_id_street(openaddress_bebru)
    openaddress_bebru <- join_ss_adress(openaddress_bebru)
    # Wallonie
    openaddress_bewal <- readr::read_delim(paste0(path_data, "BeST/openaddress/openaddress-bewal.csv"), progress= F, col_types = cols(.default = col_character()))
    openaddress_bewal <- select_id_street(openaddress_bewal)
    openaddress_bewal <- join_ss_adress(openaddress_bewal)
    # Flandres
    openaddress_bevlg <- readr::read_delim(paste0(path_data, "BeST/openaddress/openaddress-bevlg.csv"), progress= F, col_types = cols(.default = col_character()))
    openaddress_bevlg <- select_id_street(openaddress_bevlg)
    openaddress_bevlg <- join_ss_adress(openaddress_bevlg)

    # Belgique
    openaddress_be <- bind_rows(openaddress_bebru, openaddress_bewal, openaddress_bevlg)

    cat(paste0("\r",  colourise("\u2714", fg="green")," Cr", "\u00e9", "ation du fichier des adresses BeST (jointure spatiale avec les secteurs statistiques)"))

    # 3. Export Belgium street ----------------------------------------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7", " Cr", "\u00e9", "ation des noms propres abr", "\u00e9", "g", "\u00e9", "s pour le fichier des rues BeST"))


    # Fonction utilisee ci-dessous => https://www.r-bloggers.com/2018/07/the-notin-operator/
    `%ni%` <- Negate(`%in%`)

    # Creer les rues avec abreviations de noms

    TA_POP_2018_M <- read_excel(paste0(path_data, "STATBEL/prenoms/TA_POP_2018_M.xlsx"), progress= F)
    TA_POP_2018_F <-read_excel(paste0(path_data, "STATBEL/prenoms/TA_POP_2018_F.xlsx"),  progress= F)



    prenoms <- bind_rows(TA_POP_2018_M, TA_POP_2018_F) %>%
      select(TX_FST_NAME, MS_FREQUENCY) %>%
      group_by(TX_FST_NAME) %>%
      summarise(MS_FREQUENCY = sum(MS_FREQUENCY)) %>%
      filter(MS_FREQUENCY > 500) %>%
      filter(TX_FST_NAME %ni% c("Prince", "Reine")) %>%
      mutate(abv = str_remove_all(str_replace(TX_FST_NAME, "-", " "), "(?<!^|[:space:])."))

    belgium_street_abv <- belgium_street %>%
      mutate(
        detect = str_detect(
          street_FINAL_detected,
          str_c(
            "\\b(?<!\\-)(",
            str_c(prenoms$TX_FST_NAME,
              collapse = "|"
            ),
            ")\\b(?!\\-)"
          )
        ),
        street_FINAL_detected_abv = str_replace(
          street_FINAL_detected,
          str_c(
            "\\b(?<!\\-)(",
            str_c(prenoms$TX_FST_NAME,
              collapse = "|"
            ),
            ")\\b(?!\\-)"
          ),
          str_remove_all(str_replace(str_extract(
            street_FINAL_detected,
            str_c(
              "\\b(?<!\\-)(",
              str_c(prenoms$TX_FST_NAME,
                collapse = "|"
              ),
              ")\\b(?!\\-)"
            )
          ), "-", " "), "(?<!^|[:space:]).")
        )
      ) %>%
      filter(detect == TRUE) %>%
      select(-key_street_unique, "street_FINAL_detected_Origin" = "street_FINAL_detected", "street_FINAL_detected" = "street_FINAL_detected_abv", nom_propre_abv = detect) %>%
      mutate(nom_propre_abv = 1)

    belgium_street_abv <- belgium_street_abv %>%
      mutate(Count = str_length(street_FINAL_detected),
             Saint = str_detect(street_FINAL_detected, regex("(Sint-[a-z])|(Saint(|e)-[a-z])", ignore_case = TRUE)),
             Last = str_detect(street_FINAL_detected, regex("(\\s|'|-)[A-Z]$", ignore_case = TRUE)),
             Last_double = str_detect(street_FINAL_detected, regex("((\\s|'|-)[A-Z][A-Z]$)", ignore_case = TRUE)),
             King = str_detect(street_FINAL_detected_Origin, regex("1er$|II|Roi\\s|Koning(|in)\\s", ignore_case = TRUE))
             ) %>%
      filter(Last == FALSE) %>%
      filter(Last_double == FALSE) %>%
      filter(Count >= 10 & Count <= 25) %>%
      filter(Saint == FALSE) %>%
      filter(King == FALSE) %>%
      select(street_id_phaco, postal_id, street_FINAL_detected, langue_FINAL_detected, nom_propre_abv)

    # Export Belgium street
    belgium_street <- belgium_street %>%
      select(-key_street_unique)

    belgium_street_abv <- belgium_street %>%
      bind_rows(belgium_street_abv)



    cat(paste0("\r",  colourise("\u2714", fg="green"), " Cr", "\u00e9", "ation des noms propres abr", "\u00e9", "g", "\u00e9", "s pour le fichier des rues BeST"))


    # Assigner à chaque rue par code postal les coordonnées du numéro du milieu
    cat(paste0("\n", "\u29D7", " Recherche du num", "\u00e9", "ro au milieu de la rue par code postal"))

    num_mid <- belgium_street_abv %>%
      inner_join(openaddress_be, by="street_id_phaco" ) %>% # certaines rues n'ont pas de numéro, on les écartes
      mutate (house_number_sans_lettre= as.numeric(house_number_sans_lettre)) %>%
      group_by(street_id_phaco, postal_id) %>% # par rue et code postal
      filter(house_number_sans_lettre==as.numeric(quantile(house_number_sans_lettre, p = 0.5, type = 3, na.rm=T))) %>% # quantile parce que median() prend la valeur du milieu quand paire, type 3 arrondi vers le bas
      rename(mid_num = house_number_sans_lettre,
             mid_x_31370 = x_31370,
             mid_y_31370= y_31370,
             mid_postcode= postcode,
             mid_cd_sector= cd_sector,
             mid_arrond= arrond) %>%
      select(-c(3:5)) %>%
      unique()

    belgium_street_abv<-belgium_street_abv %>%
      left_join(num_mid, by=c("street_id_phaco", "postal_id"))


    #write_csv2(belgium_street, paste0(path_data, "BeST/PREPROCESSED/belgium_street_PREPROCESSED.csv"))
    write_csv2(belgium_street_abv, paste0(path_data, "BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv"), progress=F)
    cat(paste0("\r", colourise("\u2714", fg="green"), " Recherche du num", "\u00e9", "ro au milieu de la rue par code postal"))


    # 4. Table codes postaux > arrondissements ------------------------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7"," Cr", "\u00e9", "ation de la table de conversion 'codes postaux - arrondissements' (Statbel)"))

    code_postal_INS <- read_excel(paste0(path_data, "STATBEL/code_postaux/Conversion Postal code_Refnis code_va01012019.xlsx"), progress= F) %>%
      rename("code_postal" = "Postal code")



    BE_SS_lite_comm_arrond_rgn <- BE_SS %>%
      as.data.frame() %>%
      select(cd_munty_refnis, cd_dstr_refnis, tx_rgn_descr_fr) %>%
      mutate(arrond = as.numeric(substr(cd_dstr_refnis, 1, 2))) %>%
      select(-cd_dstr_refnis)

    table_postal_arrond <- code_postal_INS %>%
      left_join(BE_SS_lite_comm_arrond_rgn, by = c("Refnis code" = "cd_munty_refnis")) %>%
      select("postcode" = "code_postal", arrond, "Region" = "tx_rgn_descr_fr") %>%
      distinct()

    table_postal_arrond$Region[table_postal_arrond$Region == paste0("R", "\u00e9", "gion de Bruxelles-Capitale")] <- "Bruxelles"
    table_postal_arrond$Region[table_postal_arrond$Region == paste0("R", "\u00e9", "gion flamande")] <- "Flandre"
    table_postal_arrond$Region[table_postal_arrond$Region == paste0("R", "\u00e9", "gion wallonne")] <- "Wallonie"


    write_csv2(table_postal_arrond, paste0(path_data, "BeST/PREPROCESSED/table_postal_arrond.csv"), progress=F)
    cat(paste0("\r", colourise("\u2714", fg="green")," Cr", "\u00e9", "ation de la table de conversion 'codes postaux - arrondissements' (Statbel)"))


    # 5. Table de conversion code postal > communes INS recode --------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7"," Cr", "\u00e9", "ation de la table de conversion codes postaux > communes recod", "\u00e9", "es (Statbel)"))

    table_INS_recod_code_postal <- code_postal_INS %>%
      select(code_postal, "Refnis code") %>%
      mutate(`Refnis code` = case_when(`Refnis code` == "21004" | `Refnis code` == "21005" | `Refnis code` == "21009" ~ "21004-21005-21009",
                                       `Refnis code` == "23088" | `Refnis code` == "23096" ~ "23088-23096",
                                       TRUE ~ `Refnis code`)) %>%
      distinct()


    write_csv2(table_INS_recod_code_postal, paste0(path_data, "BeST/PREPROCESSED/table_INS_recod_code_postal.csv"), progress=F)
    cat(paste0("\r", colourise("\u2714", fg="green")," Cr", "\u00e9", "ation de la table de conversion 'codes postaux - communes recod", "\u00e9", "es' (Statbel)"))


    # 6. Export openaddress par arrondissement ------------------------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7"," Export des fichiers BeST par arrondissement"))

    openaddress_be <- rename(openaddress_be, "arrond2" = "arrond") %>%
      left_join(select(table_postal_arrond, postcode, arrond), by = "postcode")

    # Verif = pas toujours convergent ! => On penche plutot pour des erreurs des coordonnees que du code postal
    # => On garde donc les arrond issus de la jointure CODE POSTAL > ARROND au lieu de partir des arrond definis par localisation geo.
    # table(openaddress_be$arrond, openaddress_be$arrond2)

    openaddress_be <- openaddress_be %>%
      select(-arrond2)

    filter_arrondissements <- unique(openaddress_be$arrond[!is.na(openaddress_be$arrond)])

    for (i in filter_arrondissements) {
      temp <- openaddress_be %>%
        filter(arrond == i) %>%
        select(-postcode, -arrond)
      write_csv2(temp, paste0(paste0(path_data, "BeST/PREPROCESSED/data_arrond_PREPROCESSED_"),  i, ".csv"), na = "", progress=F)
      }
    cat(paste0("\r", colourise("\u2714", fg="green")," Export des fichiers BeST par arrondissement"))


    # 7. Table secteurs - quartiers - communes -  arrond - region -----------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7", " Collecte des informations par secteur statistique (jointure secteurs statistiques Statbel - quartiers Urbis)"))

    # Quartiers du monitoring
    BXL_QUARTIERS_sf <- st_read(paste0(path_data, "URBIS/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.gpkg"), quiet=T,crs=31370)
    # jointure spatiale avec le centroid des secteurs statistiques
    BXL_QUARTIERS <- st_join(BXL_QUARTIERS_sf, st_centroid(BE_SS)) %>%
      as.data.frame() %>%
      select(cd_sector, MDRC, NAME_FRE, NAME_DUT)

    table_secteurs_prov_commune_quartier <- BE_SS %>%
      left_join(BXL_QUARTIERS, by="cd_sector") %>%
      as.data.frame() %>%
      select(-tx_sector_descr_de, -tx_munty_descr_de, -tx_adm_dstr_descr_de,
             -tx_rgn_descr_de, -cd_country,- cd_nuts_lvl1, -cd_nuts_lvl2, -cd_nuts_lvl3,
             -ms_area_ha, -ms_perimeter_m, -dt_situation, -geom, -tx_prov_descr_de) # NOTE : dans BE_SS version gpkg, le champ geometrie = "geom" et non "geometry" => PKOI ?


    write_csv2(table_secteurs_prov_commune_quartier, paste0(path_data, "STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.csv"), na = "", progress=F)
    cat(paste0("\r", colourise("\u2714", fg="green"), " Collecte des informations par secteur statistique (jointure secteurs statistiques Statbel - quartiers Urbis)"))


    # 8. Liste des communes adjacentes par commune --------------------------------------------------------------------------------------------

    cat(paste0("\n", "\u29D7", " Cr", "\u00e9", "ation de la table des communes adjacentes (Statbel)"))

    # communes adjacentes
    # D'abord un recodage car codes postaux et INS n'ont pas de relation bi-univoque : https://statbel.fgov.be/fr/propos-de-statbel/methodologie/classifications/geographie
    BE_communes <- BE_SS %>%
      mutate(cd_munty_refnis = case_when(cd_munty_refnis == "21004" | cd_munty_refnis == "21005" | cd_munty_refnis == "21009" ~ "21004-21005-21009",
                                         cd_munty_refnis == "23088" | cd_munty_refnis == "23096" ~ "23088-23096",
                                         TRUE ~ cd_munty_refnis)) %>%
      group_by(cd_munty_refnis) %>%
      summarize(geom = st_union(geom))

    nb <- poly2nb(BE_communes)
    mat <- nb2mat(nb, style="B")
    colnames(mat) <- BE_communes$cd_munty_refnis
    mat <- mat %>%
      as.data.frame() %>%
      mutate(cd_munty_refnis= BE_communes$cd_munty_refnis) %>%
      pivot_longer(cols= 1:578, names_to= "cd_munty_refnis_voisin", values_to= "voisin") %>%
      filter(voisin==1) %>%
      select(-voisin)


    write_csv2(mat, paste0(path_data, "BeST/PREPROCESSED/table_commune_adjacentes.csv"), progress=F)

    cat(paste0("\r", colourise("\u2714", fg="green"), " Cr", "\u00e9", "ation de la table des communes adjacentes (Statbel)"))

    # 9. Delete des fichiers openaddress originaux --------------------------------------------------------------------------------------------

    cat(paste0("\n", colourise("\u2714", fg="green")," Supression des fichiers initiaux BeST sur le disque dur"))

    file.remove(c(paste0(path_data, "BeST/openaddress/Brussels_postal_street.csv"),
                  paste0(path_data, "BeST/openaddress/Flanders_postal_street.csv"),
                  paste0(path_data, "BeST/openaddress/Wallonia_postal_street.csv")))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bevlg.csv"))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bebru.csv"))
    file.remove(paste0(path_data, "BeST/openaddress/openaddress-bewal.csv"))

    options(timeout=60)
    cat(paste0("\n", colourise("\u2714", fg="green")," Les donn", "\u00e9", "es BeST sont"," \u00e0"," jour."))


  } else {
    cat(paste0("\n", colourise("\u2714", fg="green")," Les fichiers openaddress ont moins d'une semaine : mise", " \u00e0 ", "jour non n", "\u00e9", "cessaire"))
  }
}
