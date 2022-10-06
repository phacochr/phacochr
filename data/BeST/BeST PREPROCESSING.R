
# NOTE : le répertoire doit être réglé comme dans le script principal

# date de téléchargement des derniers fichiers openaddress : 12/08/2022

# 1) Import des secteurs statistiques  ====================================================================================================

BE_SS <- st_read("Shp/sh_statbel_statistical_sectors_31370_20220101.sqlite/sh_statbel_statistical_sectors_20220101.sqlite") %>%
  st_set_crs(31370) %>% 
  st_zm(drop = TRUE) %>% 
  select(cd_sector,
         tx_sector_descr_nl,
         tx_sector_descr_fr,
         cd_dstr_refnis,
         tx_adm_dstr_descr_nl,
         tx_adm_dstr_descr_fr,
         cd_rgn_refnis,
         tx_rgn_descr_nl,
         tx_rgn_descr_fr
         )


# 2) Postal street ========================================================================================================================

## a) Bruxelles ---------------------------------------------------------------------------------------------------------------------------

Brussels_postal_street <- read_csv("BeST/openaddress/Brussels_postal_street.csv", col_types = cols(.default = col_character()))

Brussels_postal_street_FR <- Brussels_postal_street %>% 
  filter(!is.na(street_fr)) %>% 
  mutate(street_FINAL_detected = street_fr) %>% 
  select(postal_id, postal_nl, postal_fr, street_FINAL_detected, street_fr, street_nl) %>%
  mutate(langue_FINAL_detected = "FR")

Brussels_postal_street_NL <- Brussels_postal_street %>% 
  filter(!is.na(street_fr)) %>% 
  mutate(street_FINAL_detected = street_nl) %>% 
  select(postal_id, postal_nl, postal_fr, street_FINAL_detected, street_fr, street_nl) %>%
  mutate(langue_FINAL_detected = "NL")

Brussels_postal_street <- bind_rows(Brussels_postal_street_FR, Brussels_postal_street_NL) %>% 
  mutate(Key_postal_street = paste(street_FINAL_detected, postal_id, postal_fr),
         address_join_street = str_to_lower(street_FINAL_detected),
         address_join_cd_postal_street = paste(str_to_lower(str_trim(street_FINAL_detected)), postal_id))

# Pour vérif : les dupliqués
#Brussels_postal_street$duplicated <- 0
#Brussels_postal_street$duplicated[duplicated(Brussels_postal_street$Key_postal_street) | duplicated(Brussels_postal_street$Key_postal_street, fromLast = TRUE)] <- 1

# Je supprime les doublons (ce sont les mêmes rues mais avec un street_no différent => je ne sais pas pkoi)
Brussels_postal_street <- Brussels_postal_street %>% 
  filter(!duplicated(Brussels_postal_street$Key_postal_street)) %>% 
  select(-Key_postal_street)

write_csv2(Brussels_postal_street, "BeST/PREPROCESSED/Brussels_postal_street_PREPROCESSED_LONG.csv")


## b) Wallonie ----------------------------------------------------------------------------------------------------------------------------
# INFO IMPORTANTE : quand street_de est non vide, street_fr l'est => pas les 2 infos en même temps (=/= BXL)

Wallonia_postal_street <- read_csv("BeST/openaddress/Wallonia_postal_street.csv", col_types = cols(.default = col_character()))

Wallonia_postal_street_FR <- Wallonia_postal_street %>% 
  filter(!is.na(street_fr)) %>% 
  select(postal_id, city_nl, city_fr, city_de, street_FINAL_detected = street_fr) %>%
  mutate(langue_FINAL_detected = "FR")

Wallonia_postal_street_DE <- Wallonia_postal_street %>% 
  filter(!is.na(street_de)) %>% 
  select(postal_id, city_nl, city_fr, city_de, street_FINAL_detected = street_de) %>%
  mutate(langue_FINAL_detected = "DE")

Wallonia_postal_street <- bind_rows(Wallonia_postal_street_FR, Wallonia_postal_street_DE) %>% 
  mutate(Key_postal_street = paste(street_FINAL_detected, postal_id, city_fr),
         address_join_street = str_to_lower(street_FINAL_detected))

# Pour vérif : les dupliqués
#Wallonia_postal_street$duplicated <- 0
#Wallonia_postal_street$duplicated[duplicated(Wallonia_postal_street$Key_postal_street) | duplicated(Wallonia_postal_street$Key_postal_street, fromLast = TRUE)] <- 1

# Je supprime les doublons (ce sont les mêmes rues mais avec un street_no différent => je ne sais pas pkoi)
Wallonia_postal_street <- Wallonia_postal_street %>% 
  filter(!duplicated(Wallonia_postal_street$Key_postal_street)) %>% 
  select(-Key_postal_street)

write_csv2(Wallonia_postal_street, "BeST/PREPROCESSED/Wallonia_postal_street_PREPROCESSED_LONG.csv")


## c) Flandre -----------------------------------------------------------------------------------------------------------------------------

# Je crée une clé par région
Flanders_postal_street <- read_csv("BeST/openaddress/Flanders_postal_street.csv", col_types = cols(.default = col_character()))

Flanders_postal_street_FR <- Flanders_postal_street %>% 
  filter(!is.na(street_fr)) %>% 
  mutate(street_FINAL_detected = street_fr) %>% 
  select(postal_id, postal_nl, postal_fr, street_FINAL_detected, street_fr, street_nl) %>%
  mutate(langue_FINAL_detected = "FR")

Flanders_postal_street_NL <- Flanders_postal_street %>% 
  filter(!is.na(street_nl)) %>% 
  mutate(street_FINAL_detected = street_nl) %>% 
  select(postal_id, postal_nl, postal_fr, street_FINAL_detected, street_fr, street_nl) %>%
  mutate(langue_FINAL_detected = "NL")

Flanders_postal_street <- bind_rows(Flanders_postal_street_FR, Flanders_postal_street_NL) %>% 
  mutate(Key_postal_street = paste(street_FINAL_detected, postal_id, postal_nl),
         address_join_street = str_to_lower(street_FINAL_detected))

# Pour vérif : les dupliqués
#Flanders_postal_street$duplicated <- 0
#Flanders_postal_street$duplicated[duplicated(Flanders_postal_street$Key_postal_street) | duplicated(Flanders_postal_street$Key_postal_street, fromLast = TRUE)] <- 1
# INFO IMPORTANTE : quand street_fr est non vide, street_nl a aussi une info => les 2 infos sont en même temps (=/= WALLONIE)

Flanders_postal_street <- Flanders_postal_street %>% 
  filter(!duplicated(Flanders_postal_street$Key_postal_street)) %>% 
  select(-Key_postal_street)

write_csv2(Flanders_postal_street, "BeST/PREPROCESSED/Flanders_postal_street_PREPROCESSED_LONG.csv")


rm(Brussels_postal_street, Brussels_postal_street_FR, Brussels_postal_street_NL, Flanders_postal_street, Flanders_postal_street_FR, Flanders_postal_street_NL, Wallonia_postal_street, Wallonia_postal_street_FR, Wallonia_postal_street_DE)
# Vidage RAM
gc()


# 3) Openaddress ==========================================================================================================================

## a) Bruxelles ---------------------------------------------------------------------------------------------------------------------------

openaddress_bebru <- read_csv("BeST/openaddress/openaddress-bebru.csv", col_types = cols(.default = col_character()))

# Verif
#sum(!is.na(openaddress_bebru$streetname_fr))
#sum(!is.na(openaddress_bebru$streetname_nl))
#sum(duplicated(openaddress_bebru$address_id))
#sum(openaddress_bebru$`EPSG:31370_x` == "0.00000")

openaddress_bebru <- openaddress_bebru %>% 
  rename("postcode_openaddress" = "postcode") %>% 
  mutate(house_number_sans_lettre = str_extract(house_number, regex("[0-9]+", ignore_case = TRUE)),
         address_join_geocoding = paste(house_number_sans_lettre, streetname_fr, postcode_openaddress)) %>% 
  relocate(house_number_sans_lettre, .after = house_number)

# Pour vérif
#openaddress_bebru$duplicated <- 0
#openaddress_bebru$duplicated[duplicated(openaddress_bebru$address_join_geocoding) | duplicated(openaddress_bebru$address_join_geocoding, fromLast = TRUE)] <- 1
#sum(duplicated(openaddress_bebru$address_join_geocoding))
#table(openaddress_bebru$postcode_openaddress, openaddress_bebru$municipality_id)

# /!\ A FAIRE : vérifier que les dupliqués sont aux mêmes coordonnées X-Y (diff par ligne par rapport au min/max -> si 0 = OK)

openaddress_bebru_num <- openaddress_bebru %>%
  group_by(address_join_geocoding) %>% 
  rename("ID_openaddress" = "address_id") %>% 
  relocate(ID_openaddress, .before = "EPSG:31370_x") %>% 
  filter(row_number()==1) %>% 
  select(-status, -region_code, -box_number)

# Quartiers du monitoring
BXL_QUARTIERS_sf <- st_read("Shp/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.shp") %>%
  st_set_crs(31370) 

# jointure spatiale avec le centroid des secteurs statistiques
BXL_QUARTIERS <- st_join(BXL_QUARTIERS_sf, st_centroid(BE_SS)) %>% 
  as.data.frame() %>% 
  select(cd_sector, MDRC, NAME_FRE, NAME_DUT) 

BE_SS <- BE_SS %>% 
  left_join(BXL_QUARTIERS, by=c("cd_sector"="cd_sector"))

# Jointure spatiale avec la couche secteur statistique
openaddress_bebru_num_sf <- openaddress_bebru_num %>% 
  st_as_sf(coords = c("EPSG:31370_x", "EPSG:31370_y"), remove = FALSE) %>%
  st_set_crs(31370) %>%
  st_join(BE_SS)

# Revenir à un data.frame (nécessaire ?)
openaddress_bebru_num <- openaddress_bebru_num_sf %>%
  as.data.frame() %>%
  select(-geometry,
         -postname_fr,
         -postname_nl,
         -cd_rgn_refnis,
         -tx_rgn_descr_nl,
         -tx_rgn_descr_fr,
         -cd_dstr_refnis,
         -tx_adm_dstr_descr_nl,
         -tx_adm_dstr_descr_fr)

# Pour vérif
#sum(duplicated(openaddress_bebru_num$address_join_geocoding))


write_csv2(openaddress_bebru_num, "BeST/PREPROCESSED/openaddress_bebru_PREPROCESSED.csv", na = "")
#saveRDS(openaddress_bebru_num, file = "BeST/PREPROCESSED/openaddress_bebru_PREPROCESSED.rds", compress = FALSE)


rm(openaddress_bebru, openaddress_bebru_num, openaddress_bebru_num_sf, BXL_QUARTIERS_sf, BXL_QUARTIERS)
# Vidage RAM
gc()


## b) Wallonie ----------------------------------------------------------------------------------------------------------------------------

openaddress_bewal <- read_csv("BeST/openaddress/openaddress-bewal.csv", col_types = cols(.default = col_character()))

# Verif
#sum(!is.na(openaddress_bewal$streetname_fr))
#sum(!is.na(openaddress_bewal$streetname_de))
#sum(duplicated(openaddress_bewal$address_id))
#sum(openaddress_bewal$`EPSG:31370_x` == "0.00000")

# /!\ ATTENTION : la version wallonne est de moins bonne qualité : une certaine proportion de coordonnées X-Y manquent (EPSG:31370_x == "0.00000") /!\
# => je supprime donc les lignes où les coordonnées = 0.00000
# /!\ A voir avec la MAJ futures des données de la Région Wallonne ! /!\

openaddress_bewal <- openaddress_bewal %>% 
  filter(`EPSG:31370_x` != "0.00000") %>% 
  rename("postcode_openaddress" = "postcode") %>% 
  mutate(house_number_sans_lettre = str_extract(house_number, regex("[0-9]+", ignore_case = TRUE)),
         address_join_geocoding = paste(house_number_sans_lettre, ifelse(!is.na(streetname_de), streetname_de, streetname_fr), postcode_openaddress)) %>% 
  relocate(house_number_sans_lettre, .after = house_number)

# Pour vérif
#openaddress_bewal$duplicated <- 0
#openaddress_bewal$duplicated[duplicated(openaddress_bewal$address_join_geocoding) | duplicated(openaddress_bewal$address_join_geocoding, fromLast = TRUE)] <- 1
#sum(duplicated(openaddress_bewal$address_join_geocoding))
#table(openaddress_bewal$postcode_openaddress, openaddress_bewal$municipality_id)

# /!\ A FAIRE : vérifier que les dupliqués sont aux mêmes coordonnées X-Y (diff par ligne par rapport au min/max -> si 0 = OK)

openaddress_bewal_num <- openaddress_bewal %>%
  group_by(address_join_geocoding) %>% 
  rename("ID_openaddress" = "address_id") %>% 
  relocate(ID_openaddress, .before = "EPSG:31370_x") %>% 
  filter(row_number()==1) %>% 
  select(-status, -region_code, -box_number)

# Pour vérif
#sum(duplicated(openaddress_bewal_num$address_join_geocoding))

# Jointure spatiale avec la couche secteur statistique
openaddress_bewal_num_sf <- openaddress_bewal_num %>%
  st_as_sf(coords = c("EPSG:31370_x", "EPSG:31370_y"), remove = FALSE) %>%
  st_set_crs(31370) %>%
  st_join(BE_SS)

# Revenir à un data.frame (nécessaire ?)
openaddress_bewal_num <- openaddress_bewal_num_sf %>%
  as.data.frame() %>%
  filter(cd_rgn_refnis == "03000") %>% 
  select(-geometry,
         -postname_fr,
         -postname_nl,
         -cd_rgn_refnis,
         -tx_rgn_descr_nl,
         -tx_rgn_descr_fr,
         -MDRC,
         -NAME_FRE,
         -NAME_DUT)

# Lister les arrondissements en wallonie
filter_arrondissements <- unique(openaddress_bewal_num$cd_dstr_refnis)

# Boucle pour scinder les adresses dans des fichiers d'arrondissement
for (i in filter_arrondissements) {
  
  openaddress_bewal_num_filtered <- openaddress_bewal_num %>%
    filter(cd_dstr_refnis == i) %>% 
    select(-cd_dstr_refnis,
           -tx_adm_dstr_descr_nl,
           -tx_adm_dstr_descr_fr)
  
  write_csv2(openaddress_bewal_num_filtered, paste0("BeST/PREPROCESSED/openaddress_bewal_PREPROCESSED_",  i, ".csv", na = ""))
  
}

openaddress_bewal_num <- openaddress_bewal_num %>% 
  select(-cd_dstr_refnis,
         -tx_adm_dstr_descr_nl,
         -tx_adm_dstr_descr_fr)


write_csv2(openaddress_bewal_num, "BeST/PREPROCESSED/openaddress_bewal_FULL_PREPROCESSED.csv", na = "")
#saveRDS(openaddress_bewal_num, file = "BeST/PREPROCESSED/openaddress_bewal_PREPROCESSED.rds", compress = FALSE)


rm(openaddress_bewal, openaddress_bewal_num, openaddress_bewal_num_sf, openaddress_bewal_num_filtered)
# Vidage RAM
gc()


## c) Flandre -----------------------------------------------------------------------------------------------------------------------------

openaddress_bevlg <- read_csv("BeST/openaddress/openaddress-bevlg.csv", col_types = cols(.default = col_character()))

# Verif
#sum(!is.na(openaddress_bevlg$streetname_fr))
#sum(!is.na(openaddress_bevlg$streetname_nl))
#sum(duplicated(openaddress_bevlg$address_id))
#sum(openaddress_bevlg$`EPSG:31370_x` == "0.00000")

openaddress_bevlg <- openaddress_bevlg %>% 
  rename("postcode_openaddress" = "postcode") %>% 
  mutate(house_number_sans_lettre = str_extract(house_number, regex("[0-9]+", ignore_case = TRUE)),
         address_join_geocoding = paste(house_number_sans_lettre, streetname_nl, postcode_openaddress)) %>% 
  relocate(house_number_sans_lettre, .after = house_number)

# Pour vérif
#openaddress_bevlg$duplicated <- 0
#openaddress_bevlg$duplicated[duplicated(openaddress_bevlg$address_join_geocoding) | duplicated(openaddress_bevlg$address_join_geocoding, fromLast = TRUE)] <- 1
#sum(duplicated(openaddress_bevlg$address_join_geocoding))
#table(openaddress_bevlg$postcode_openaddress, openaddress_bevlg$municipality_id)

# /!\ A FAIRE : vérifier que les dupliqués sont aux mêmes coordonnées X-Y (diff par ligne par rapport au min/max -> si 0 = OK)

openaddress_bevlg_num <- openaddress_bevlg %>%
  group_by(address_join_geocoding) %>% 
  rename("ID_openaddress" = "address_id") %>% 
  relocate(ID_openaddress, .before = "EPSG:31370_x") %>% 
  filter(row_number()==1) %>% 
  select(-status, -region_code, -box_number)

# Pour vérif
#sum(duplicated(openaddress_bevlg_num$address_join_geocoding))

# Jointure spatiale avec la couche secteur statistique
openaddress_bevlg_num_sf <- openaddress_bevlg_num %>%
  st_as_sf(coords = c("EPSG:31370_x", "EPSG:31370_y"), remove = FALSE) %>%
  st_set_crs(31370) %>%
  st_join(BE_SS)

# Revenir à un data.frame (nécessaire ?)
openaddress_bevlg_num <- openaddress_bevlg_num_sf %>% 
  as.data.frame() %>% 
  filter(cd_rgn_refnis == "02000") %>% 
  select(-geometry,
         -postname_fr,
         -postname_nl,
         -cd_rgn_refnis,
         -tx_rgn_descr_nl,
         -tx_rgn_descr_fr,
         -MDRC,
         -NAME_FRE,
         -NAME_DUT)

# Lister les arrondissements en wallonie
filter_arrondissements <- unique(openaddress_bevlg_num$cd_dstr_refnis)

# Boucle pour scinder les adresses dans des fichiers d'arrondissement
for (i in filter_arrondissements) {
  
  openaddress_bevlg_num_filtered <- openaddress_bevlg_num %>%
    filter(cd_dstr_refnis == i) %>% 
    select(-cd_dstr_refnis,
           -tx_adm_dstr_descr_nl,
           -tx_adm_dstr_descr_fr)
  
  write_csv2(openaddress_bevlg_num_filtered, paste0("BeST/PREPROCESSED/openaddress_bevlg_PREPROCESSED_",  i, ".csv", na = ""))
  
}

openaddress_bevlg_num <- openaddress_bevlg_num %>% 
  select(-cd_dstr_refnis,
         -tx_adm_dstr_descr_nl,
         -tx_adm_dstr_descr_fr)


write_csv2(openaddress_bevlg_num, "BeST/PREPROCESSED/openaddress_bevlg_FULL_PREPROCESSED.csv", na = "")
#saveRDS(openaddress_bevlg_num, file = "BeST/PREPROCESSED/openaddress_bevlg_PREPROCESSED.rds", compress = FALSE)


rm(openaddress_bevlg, openaddress_bevlg_num, openaddress_bevlg_num_sf, openaddress_bevlg_num_filtered, filter_arrondissements, BE_SS)
gc()


# 4) Codes postaux - Arrondissement =======================================================================================================

code_postal_INS <- read_excel("BeST/Statbel_code_postaux/Conversion Postal code_Refnis code_va01012019.xlsx") %>% 
  rename("code_postal" = "Postal code")

TU_COM_REFNIS <- read_excel("BeST/Statbel_code_postaux/TU_COM_REFNIS.xlsx")

TU_COM_REFNIS_communes <- TU_COM_REFNIS %>% 
  filter(str_sub(DT_VLDT_END, 7, 10) == "9999") %>% 
  filter(LVL_REFNIS == "4") %>% 
  select("Commune_tu_com" = "CD_REFNIS", "Arrondissement_tu_com" = "CD_SUP_REFNIS")

TU_COM_REFNIS_arrond <- TU_COM_REFNIS %>% 
  filter(str_sub(DT_VLDT_END, 7, 10) == "9999") %>% 
  filter(LVL_REFNIS == "3") %>% 
  select("Arrondissement_tu_com" = "CD_REFNIS", "Province_tu_com" = "CD_SUP_REFNIS", "Arrondissement_tu_com_FR" = "TX_REFNIS_FR", "Arrondissement_tu_com_NL" = "TX_REFNIS_NL")
TU_COM_REFNIS_arrond$Province_tu_com[TU_COM_REFNIS_arrond$Province_tu_com == "04000"] <- NA

TU_COM_REFNIS_provinces <- TU_COM_REFNIS %>% 
  filter(str_sub(DT_VLDT_END, 7, 10) == "9999") %>% 
  filter(LVL_REFNIS == "2") %>% 
  select("Province_tu_com" = "CD_REFNIS", "Region_tu_com" = "CD_SUP_REFNIS", "Province_tu_com_FR" = "TX_REFNIS_FR", "Province_tu_com_NL" = "TX_REFNIS_NL")

TU_COM_REFNIS_regions <- TU_COM_REFNIS %>% 
  filter(str_sub(DT_VLDT_END, 7, 10) == "9999") %>% 
  filter(LVL_REFNIS == "1") %>% 
  select("Region_tu_com" = "CD_REFNIS","Region_tu_com_FR" = "TX_REFNIS_FR", "Region_tu_com_NL" = "TX_REFNIS_NL")

code_postal_INS <- code_postal_INS %>% 
  left_join(TU_COM_REFNIS_communes, by = c("Refnis code" = "Commune_tu_com")) %>% 
  left_join(TU_COM_REFNIS_arrond, by = c("Arrondissement_tu_com" = "Arrondissement_tu_com")) %>% 
  left_join(TU_COM_REFNIS_provinces, by = c("Province_tu_com" = "Province_tu_com")) %>% 
  left_join(TU_COM_REFNIS_regions, by = c("Region_tu_com" = "Region_tu_com"))
code_postal_INS$Region_tu_com[code_postal_INS$Arrondissement_tu_com == "21000"] <- "04000"
code_postal_INS$Region_tu_com_FR[code_postal_INS$Arrondissement_tu_com == "21000"] <- "Région de Bruxelles-Capitale"
code_postal_INS$Region_tu_com_NL[code_postal_INS$Arrondissement_tu_com == "21000"] <- "Brussels Hoofdstedelijk Gewest"

code_postal_INS <- code_postal_INS %>% 
  group_by(code_postal) %>% 
  summarise(Arrondissement_tu_com = first(Arrondissement_tu_com),
            Arrondissement_tu_com_FR = first(Arrondissement_tu_com_FR),
            Arrondissement_tu_com_NL = first(Arrondissement_tu_com_NL),
            Province_tu_com = first(Province_tu_com),
            Province_tu_com_FR = first(Province_tu_com_FR),
            Province_tu_com_NL = first(Province_tu_com_NL),
            Region_tu_com = first(Region_tu_com),
            Region_tu_com_FR = first(Region_tu_com_FR),
            Region_tu_com_NL = first(Region_tu_com_NL))

## Recoding code_postal_INS$Region_tu_com_FR
code_postal_INS$Region_tu_com_FR <- code_postal_INS$Region_tu_com_FR %>%
  fct_recode(
    "Bruxelles" = "Région de Bruxelles-Capitale",
    "Flandre" = "Région flamande",
    "Wallonie" = "Région wallonne"
  )

# Verif
#verif_arrond <- as.data.frame(table(code_postal_INS$'Postal code', code_postal_INS$Arrondissement))
#verif_arrond <- verif_arrond %>% 
#  filter(Freq > 0)
#verif_arrond$duplicated <- 0
#verif_arrond$duplicated[duplicated(verif_arrond$'Postal code') | duplicated(verif_arrond$'Postal code', fromLast = TRUE)] <- 1


write_csv2(code_postal_INS, "BeST/PREPROCESSED/table_codes_postaux_Arrondissements.csv")


rm(code_postal_INS, TU_COM_REFNIS, TU_COM_REFNIS_arrond, TU_COM_REFNIS_communes, TU_COM_REFNIS_provinces, TU_COM_REFNIS_regions)

