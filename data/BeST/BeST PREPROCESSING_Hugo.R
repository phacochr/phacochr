
# ### PREPROCESSING ### #

# 0. Mise à jour --------------------------------------------------------------------------------------------------------------------------

# Mise à jour si pas déjà il y a moins de 7 jours

# Première fois
if (!file.exists("BeST/openaddress/log.csv")){
  log <- data.frame(update = "0001-01-01 00:00:00 UTC")
  write_csv2(log,"BeST/openaddress/log.csv")
  rm(log)
  }

log <- read_csv2("BeST/openaddress/log.csv")
log$update <- as.POSIXct(log$update)

if (max(as.Date(log$update)) + days(7) < Sys.Date()) {
  options(timeout=300)
  
  download.file("https://opendata.bosa.be/download/best/postalstreets-latest.zip","BeST/openaddress/postalstreets-latest.zip")
  download.file("https://opendata.bosa.be/download/best/openaddress-bevlg.zip","BeST/openaddress/openaddress-bevlg.zip")
  download.file("https://opendata.bosa.be/download/best/openaddress-bebru.zip","BeST/openaddress/openaddress-bebru.zip")
  download.file("https://opendata.bosa.be/download/best/openaddress-bewal.zip","BeST/openaddress/openaddress-bewal.zip")
  
  unzip("BeST/openaddress/postalstreets-latest.zip", exdir= "BeST/openaddress")
  file.remove("BeST/openaddress/postalstreets-latest.zip")
  
  unzip("BeST/openaddress/openaddress-bevlg.zip", exdir= "BeST/openaddress")
  file.remove("BeST/openaddress/openaddress-bevlg.zip")
  
  unzip("BeST/openaddress/openaddress-bebru.zip", exdir= "BeST/openaddress")
  file.remove("BeST/openaddress/openaddress-bebru.zip")
  
  unzip("BeST/openaddress/openaddress-bewal.zip", exdir= "BeST/openaddress")
  file.remove("BeST/openaddress/openaddress-bewal.zip")
  
  log[nrow(log)+1,] <- Sys.time()
  write_csv2(log,"BeST/openaddress/log.csv")


  # 1. Fichier rues -------------------------------------------------------------------------------------------------------------------------
  
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
  
  Brussels_postal_street <- read_csv("BeST/openaddress/Brussels_postal_street.csv", col_types = cols(.default = col_character()))
  Wallonia_postal_street <- read_csv("BeST/openaddress/Wallonia_postal_street.csv", col_types = cols(.default = col_character()))
  Flanders_postal_street <- read_csv("BeST/openaddress/Flanders_postal_street.csv", col_types = cols(.default = col_character()))
  
  belgium_street <- bind_rows(Brussels_postal_street,Wallonia_postal_street, Flanders_postal_street)
  belgium_street <- extract_street(belgium_street)
  
  
  rm(Brussels_postal_street, Flanders_postal_street, Wallonia_postal_street, extract_street)
  
  
  # 2. Fichier adresses ---------------------------------------------------------------------------------------------------------------------
  
  # Fonction pour sélectionner les variables et créer un ID street
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
      distinct(house_number_sans_lettre, street_id_phaco, postcode, .keep_all = TRUE) # J'enlève les coordonnées car 1 adresse en double avec des coordonnées différentes (?)
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
  BE_SS <- st_read("Shp/sh_statbel_statistical_sectors_31370_20220101.sqlite/sh_statbel_statistical_sectors_20220101.sqlite") %>%
    st_set_crs(31370) %>% 
    st_zm(drop = TRUE)
  
  BE_SS_lite_sector_arrond <- BE_SS %>% 
    select(cd_sector, cd_dstr_refnis) %>% 
    mutate(arrond= as.numeric(substr(cd_dstr_refnis, 1, 2))) %>%  
    select(-cd_dstr_refnis)
  
  # Bruxelles
  openaddress_bebru <- read_csv("BeST/openaddress/openaddress-bebru.csv", col_types = cols(.default = col_character()))
  openaddress_bebru <- select_id_street(openaddress_bebru)
  openaddress_bebru <- join_ss_adress(openaddress_bebru)
  # Wallonie
  openaddress_bewal <- read_csv("BeST/openaddress/openaddress-bewal.csv", col_types = cols(.default = col_character()))
  openaddress_bewal <- select_id_street(openaddress_bewal)
  openaddress_bewal <- join_ss_adress(openaddress_bewal)
  # Flandres
  openaddress_bevlg <- read_csv("BeST/openaddress/openaddress-bevlg.csv", col_types = cols(.default = col_character()))
  openaddress_bevlg <- select_id_street(openaddress_bevlg)
  openaddress_bevlg <- join_ss_adress(openaddress_bevlg)
  
  # Belgique
  openaddress_be <- bind_rows(openaddress_bebru, openaddress_bewal, openaddress_bevlg)
  
  
  rm(openaddress_bebru, openaddress_bewal, openaddress_bevlg, BE_SS_lite_sector_arrond)
  
  
  # 3. Export Belgium street ----------------------------------------------------------------------------------------------------------------
  
  # Fonction utilisée ci-dessous => https://www.r-bloggers.com/2018/07/the-notin-operator/
  `%ni%` <- Negate(`%in%`) 
  
  # Créer les rues avec abréviations de noms
  
  TA_POP_2018_M <- read_excel("BeST/prenoms/TA_POP_2018_M.xlsx")
  TA_POP_2018_F <- read_excel("BeST/prenoms/TA_POP_2018_F.xlsx")
  
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
  
  
  #write_csv2(belgium_street, "BeST/PREPROCESSED/belgium_street_PREPROCESSED.csv")
  write_csv2(belgium_street_abv, "BeST/PREPROCESSED/belgium_street_abv_PREPROCESSED.csv")
  
  rm(belgium_street, belgium_street_abv, TA_POP_2018_M, TA_POP_2018_F, prenoms)
  # Vidage RAM
  gc()
  
  
  # 4. Table codes postaux > arrondissements ------------------------------------------------------------------------------------------------
  
  code_postal_INS <- read_excel("BeST/Statbel_code_postaux/Conversion Postal code_Refnis code_va01012019.xlsx") %>% 
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
  
  table_postal_arrond$Region[table_postal_arrond$Region == "Région de Bruxelles-Capitale"] <- "Bruxelles"
  table_postal_arrond$Region[table_postal_arrond$Region == "Région flamande"] <- "Flandre"
  table_postal_arrond$Region[table_postal_arrond$Region == "Région wallonne"] <- "Wallonie"
  
  
  write_csv2(table_postal_arrond, "BeST/PREPROCESSED/table_postal_arrond.csv")
  
  rm(BE_SS_lite_comm_arrond_rgn)
  
  
  # 5. Table de conversion code postal > communes INS recodé --------------------------------------------------------------------------------
  
  table_INS_recod_code_postal <- code_postal_INS %>% 
    select(code_postal, "Refnis code") %>% 
    mutate(`Refnis code` = case_when(`Refnis code` == "21004" | `Refnis code` == "21005" | `Refnis code` == "21009" ~ "21004-21005-21009",
                                     `Refnis code` == "23088" | `Refnis code` == "23096" ~ "23088-23096",
                                     TRUE ~ `Refnis code`)) %>% 
    distinct()
  
  
  write_csv2(table_INS_recod_code_postal, "BeST/PREPROCESSED/table_INS_recod_code_postal.csv")
  
  rm(code_postal_INS, table_INS_recod_code_postal)
  
  
  # 6. Export openaddress par arrondissement ------------------------------------------------------------------------------------------------
  
  openaddress_be <- rename(openaddress_be, "arrond2" = "arrond") %>% 
    left_join(select(table_postal_arrond, postcode, arrond), by = "postcode")
  
  # Verif = pas toujours convergent ! => On penche plutôt pour des erreurs des coordonnées que du code postal
  # => On garde donc les arrond issus de la jointure CODE POSTAL > ARROND au lieu de partir des arrond définis par localisation géo.
  # table(openaddress_be$arrond, openaddress_be$arrond2)
  
  openaddress_be <- openaddress_be %>% 
    select(-arrond2)
  
  filter_arrondissements <- unique(openaddress_be$arrond[!is.na(openaddress_be$arrond)])
  
  for (i in filter_arrondissements) {
    temp <- openaddress_be %>%
      filter(arrond == i) %>% 
      select(-postcode, -arrond) 
    write_csv2(temp, paste0("BeST/PREPROCESSED/data_arrond_PREPROCESSED_",  i, ".csv"), na = "")
    }
  
  rm(i, filter_arrondissements, table_postal_arrond, openaddress_be, temp)
  
  
  # 7. Table secteurs - quartiers - communes -  arrond - région -----------------------------------------------------------------------------
  
  # Quartiers du monitoring
  BXL_QUARTIERS_sf <- st_read("Shp/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.shp") %>%
    st_set_crs(31370) 
  
  # jointure spatiale avec le centroid des secteurs statistiques
  BXL_QUARTIERS <- st_join(BXL_QUARTIERS_sf, st_centroid(BE_SS)) %>% 
    as.data.frame() %>% 
    select(cd_sector, MDRC, NAME_FRE, NAME_DUT) 
  
  table_secteurs_prov_commune_quartier <- BE_SS %>% 
    left_join(BXL_QUARTIERS, by="cd_sector") %>% 
    as.data.frame() %>% 
    select(-tx_sector_descr_de, -tx_munty_descr_de, -tx_adm_dstr_descr_de,
           -tx_rgn_descr_de, -cd_country,- cd_nuts_lvl1, -cd_nuts_lvl2, -cd_nuts_lvl3, 
           -ms_area_ha, -ms_perimeter_m, -dt_situation, -geometry, -tx_prov_descr_de)
  
  
  write_csv2(table_secteurs_prov_commune_quartier, "BeST/PREPROCESSED/table_secteurs_prov_commune_quartier.csv", na = "")
  rm(BXL_QUARTIERS_sf, BXL_QUARTIERS, table_secteurs_prov_commune_quartier)
  
  
  # 8. Liste des communes adjacentes par commune --------------------------------------------------------------------------------------------
  
  # communes adjacente
  # D'abord un recodage car codes postaux et INS n'ont pas de relation bi-univoque : https://statbel.fgov.be/fr/propos-de-statbel/methodologie/classifications/geographie
  BE_communes <- BE_SS %>%
    mutate(cd_munty_refnis = case_when(cd_munty_refnis == "21004" | cd_munty_refnis == "21005" | cd_munty_refnis == "21009" ~ "21004-21005-21009",
                                       cd_munty_refnis == "23088" | cd_munty_refnis == "23096" ~ "23088-23096",
                                       TRUE ~ cd_munty_refnis)) %>% 
    group_by(cd_munty_refnis) %>%
    summarize(geometry = st_union(geometry))
  
  nb <- poly2nb(BE_communes)
  mat <- nb2mat(nb, style="B")
  colnames(mat) <- BE_communes$cd_munty_refnis
  mat <- mat %>%
    as.data.frame() %>%
    mutate(cd_munty_refnis= BE_communes$cd_munty_refnis) %>%
    pivot_longer(cols= 1:578, names_to= "cd_munty_refnis_voisin", values_to= "voisin") %>%
    filter(voisin==1) %>%
    select(-voisin)
  
  
  write_csv2(mat, "BeST/PREPROCESSED/table_commune_adjacentes.csv")
  
  rm(BE_SS, BE_communes, mat, nb, join_ss_adress, select_id_street, "%ni%")
  # Vidage RAM
  gc()
  
  
  # 9. Delete des fichiers openaddress originaux --------------------------------------------------------------------------------------------
  
  file.remove(c("BeST/openaddress/Brussels_postal_street.csv",
                "BeST/openaddress/Flanders_postal_street.csv",
                "BeST/openaddress/Wallonia_postal_street.csv"))
  file.remove("BeST/openaddress/openaddress-bevlg.csv")
  file.remove("BeST/openaddress/openaddress-bebru.csv")
  file.remove("BeST/openaddress/openaddress-bewal.csv")
  
  options(timeout=60)
  
  # ### FIN PREPROCESSING ### #

} else {
  message("Les fichiers openaddress ont moins d'une semaine : mise à jour non nécessaire")
}

rm(log)

