
library(sf)
library(readr)
library(dplyr)
library(tidyr)
library(rappdirs)
library(readxl)
library(spdep)
library(stringr)


path_data <- gsub("\\\\", "/", paste0(rappdirs::user_data_dir("phacochr"),"/data_phacochr/"))
dir.create(paste0(path_data,"TEMP"), recursive = TRUE)


# 0. Version de phacochr -----
writeLines(as.character(utils::packageVersion("phacochr")), paste0(path_data,"phacochr_version.txt"))


# 1. Nouveau noms de rue Charleroi -----
dir.create(paste0(path_data,"CHARLEROI/"), recursive = TRUE)

download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/Rues-Nouveaux-noms_2024-01-17.xlsx",
              paste0(path_data,"TEMP/Rues-Nouveaux-noms_2024-01-17.xlsx"), mode = "wb")

saveRDS(readxl::read_excel(paste0(path_data,"TEMP/Rues-Nouveaux-noms_2024-01-17.xlsx")),
        paste0(path_data,"CHARLEROI/Rues-Nouveaux-noms_2024-01-17.rds"))


# 2. Prénoms 2018 (Statbel) -----
dir.create(paste0(path_data,"STATBEL/prenoms"), recursive = TRUE)

download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Voornamen%20bevolking%20per%20gemeente/TA_POP_2018_M.xlsx",
              paste0(path_data, "TEMP/TA_POP_2018_M.xlsx"), mode = "wb")
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Voornamen%20bevolking%20per%20gemeente/TA_POP_2018_F.xlsx",
              paste0(path_data, "TEMP/TA_POP_2018_F.xlsx"), mode = "wb")

saveRDS(read_excel(paste0(path_data, "TEMP/TA_POP_2018_M.xlsx")), file = paste0(path_data,"STATBEL/prenoms/TA_POP_2018_M.rds"))
saveRDS(read_excel(paste0(path_data, "TEMP/TA_POP_2018_F.xlsx")), file = paste0(path_data,"STATBEL/prenoms/TA_POP_2018_F.rds"))


# 3.  Codes postaux - Communes (Statbel) -----
dir.create(paste0(path_data,"STATBEL/code_postaux"), recursive = TRUE)

download.file("https://statbel.fgov.be/sites/default/files/files/documents/Over%20Statbel/Conversion%20Postal%20code_Refnis%20code_va01012019.xlsx",
              paste0(path_data,"TEMP/Conversion\ Postal\ code_Refnis\ code_va01012019.xlsx"), mode = "wb")

saveRDS(readxl::read_excel(paste0(path_data,"TEMP/Conversion\ Postal\ code_Refnis\ code_va01012019.xlsx")),
        paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012019.rds"))


# download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/ConversionPostalcode_Refniscode_va01012019.xlsx",
#               paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012019.xlsx"), mode = "wb")

# download.file("https://statbel.fgov.be/sites/default/files/Over_Statbel_FR/Nomenclaturen/Conversion%20Postal%20code_Refnis%20code_va01012025.xlsx",
#               paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012025.xlsx"))


# 4. Secteurs statistiques (Statbel) -----
dir.create(paste0(path_data,"STATBEL/secteurs_statistiques"), recursive = TRUE)

# Conversion 2024-2025 -----
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/Statsect2025_2024.csv",
              paste0(path_data,"TEMP/Statsect2025_2024.csv"))

saveRDS(readr::read_delim(paste0(path_data,"TEMP/Statsect2025_2024.csv"), delim = ";", col_types = readr::cols(.default = readr::col_character())), file = paste0(path_data,"STATBEL/secteurs_statistiques/Statsect2025_2024.rds"))


## 2025 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip",
              paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite"))

sec2025 <- st_read(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite/sh_statbel_statistical_sectors_31370_20250101.sqlite/sh_statbel_statistical_sectors_31370_20250101.sqlite")) |>
  rename("cd_sector2025"="cd_sector")


## 2024 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip",
              paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite"))

sec2024 <- st_read(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite/sh_statbel_statistical_sectors_31370_20240101.sqlite/sh_statbel_statistical_sectors_31370_20240101.sqlite"))|>
  rename("cd_sector2024"="cd_sector")


## 2011 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_spatialite.zip",
              paste0(path_data,"TEMP/sh_statbel_spatialite2011.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_spatialite2011.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_spatialite2011"))

sec2011 <- st_read(paste0(path_data,"TEMP/sh_statbel_spatialite2011/sh_statbel_statistical_sectors.sqlite")) |>
  st_set_crs(31370) |>
  rename("cd_sector2011"="cd_sector")


# 5. Quartiers du monitoring (IBSA) -----
dir.create(paste0(path_data,"IBSA"), recursive = TRUE)

# Correspondance ...-2024
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/MQ_Communes_Quartiers_Secteurs.xlsx",
              paste0(path_data,"TEMP/MQ_Communes_Quartiers_Secteurs.xlsx"), mode = "wb")

# Correspondance 2025-...
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/conversion_secteur_quartier_2025.csv",
              paste0(path_data,"TEMP/conversion_secteur_quartier_2025.csv"))

## 2025 -----
quartier_sec_2025<-read_delim(paste0(path_data,"TEMP/conversion_secteur_quartier_2025.csv"), delim = ";") |>
  rename(cd_sector2025= secteurstatistique_code) |>
  select(cd_sector2025, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2025 <- sec2025 |>
  left_join(quartier_sec_2025, by = "cd_sector2025")

sec_bxl2025 <- sec2025 |>
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2025 <- sec_bxl2025 |>
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl ) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

saveRDS(quartiers2025, file = paste0(path_data,"IBSA/quartiers2025.rds"))

## 2024 -----
quartier_sec_2024 <- read_excel(paste0(path_data,"TEMP/MQ_Communes_Quartiers_Secteurs.xlsx")) |>
  rename(cd_sector2024 = SecteurStatistique_Code,
         quartier_nom_nl = Quartier_Nom_NL,
         quartier_nom_fr = Quartier_Nom_FR,
         quartier_code = Quartier_Code) |>
  select(cd_sector2024, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2024 <- sec2024 |>
  left_join(quartier_sec_2024, by ="cd_sector2024")

sec_bxl2024 <- sec2024 |>
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2024 <- sec_bxl2024 |>
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl ) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

saveRDS(quartiers2024, file = paste0(path_data,"IBSA/quartiers2024.rds"))

## 2011 -----
quartier_sec_2024 <- read_excel(paste0(path_data,"TEMP/MQ_Communes_Quartiers_Secteurs.xlsx")) |>
  rename(cd_sector2024 = SecteurStatistique_Code,
         quartier_nom_nl = Quartier_Nom_NL,
         quartier_nom_fr = Quartier_Nom_FR,
         quartier_code = Quartier_Code) |>
  select(cd_sector2024, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2011 <- sec2011 |>
  left_join(quartier_sec_2024, by = c("cd_sector2011"= "cd_sector2024"))

sec_bxl2011 <- sec2011 |>
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2011 <- sec_bxl2011 |>
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

saveRDS(quartiers2011, file = paste0(path_data,"IBSA/quartiers2011.rds"))


# 6.  Quartiers SS et Bassins (OBSS) -----
dir.create(paste0(path_data,"OBSS"))

download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/SS_QSS_2024.xlsx",
              paste0(path_data,"TEMP/SS_QSS_2024.xlsx"), mode = "wb")

QSS_2024_original <- read_excel(paste0(path_data,"TEMP/SS_QSS_2024.xlsx")) |>
  select(CodeSector, QuartierSS_Gwwijk, NomQuartierSSFR, NaamGWwijkNL, BassinFR, ZoneNL) |>
  rename("cd_sector2024"= "CodeSector")

sec2024<-sec2024 |>
  left_join(QSS_2024_original, by= "cd_sector2024")

## QSS -----
QSS_2024 <- sec_bxl2024 |>
  left_join(QSS_2024_original, by = "cd_sector2024") |>
  group_by(QuartierSS_Gwwijk, NomQuartierSSFR, NaamGWwijkNL, BassinFR, ZoneNL) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

saveRDS(QSS_2024, file = paste0(path_data,"OBSS/QSS_2024.rds"))

## Bassins -----
bassins<- QSS_2024_original |>
  select(cd_sector2024, BassinFR, ZoneNL)

Bassins_2024 <- sec_bxl2024 |>
  left_join(bassins, by = "cd_sector2024") |>
  group_by(BassinFR, ZoneNL) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

# Bassins_2024 |> st_geometry() |> plot()
saveRDS(Bassins_2024, file = paste0(path_data,"OBSS/Bassins_2024.rds"))


# 7.  Couronnes IBSA -----
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/ibsa_couronnes.rds",
              paste0(path_data,"TEMP/ibsa_couronnes.rds"), mode = "wb")

ibsa_couronnes_original<-readRDS( paste0(path_data,"TEMP/ibsa_couronnes.rds")) |>
  rename("couronne_id" = "ibsa_couronne") |>
  mutate(
    couronne_nom = case_when(
      couronne_id == 1 ~ "1ere couronne ouest",
      couronne_id == 2 ~ "1ere couronne est",
      couronne_id == 3 ~ "2eme couronne ouest",
      couronne_id == 4 ~ "2eme couronne est",
      couronne_id == 5 ~ "Pentagone",
      TRUE ~ NA_character_
    )
  )

couronnes2024  <- quartiers2024 |>
  left_join(ibsa_couronnes_original, by = c("quartier_code" = "id")) |>
  group_by(couronne_id,couronne_nom ) |>
  summarise(GEOMETRY = st_union(GEOMETRY))

couronnes2025  <- quartiers2025 |>
  left_join(ibsa_couronnes_original, by = c("quartier_code" = "id")) |>
  group_by(couronne_id,couronne_nom ) |>
  summarise(GEOMETRY = st_union(GEOMETRY))

couronne_ss2024<- sec_bxl2024 |>
  st_point_on_surface() |>
  st_join(couronnes2024) |>
  as.data.frame() |>
  select(cd_sector2024, couronne_id,couronne_nom )

sec2024<- sec2024 |>
  left_join(couronne_ss2024, by= "cd_sector2024")

sec2011<- sec2011 |>
  left_join(couronne_ss2024, by= c("cd_sector2011"="cd_sector2024"))

couronne_ss2025<- sec_bxl2025 |>
  st_point_on_surface() |>
  st_join(couronnes2025) |>
  as.data.frame() |>
  select(cd_sector2025, couronne_id,couronne_nom )

sec2025<- sec2025 |>
  left_join(couronne_ss2025, by= "cd_sector2025")

# mf_map(sec2025|>
#          filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale"),
#        type="typo",
#        var="couronne_nom")

saveRDS(couronnes2024, file = paste0(path_data,"IBSA/couronnes2024.rds"))
saveRDS(couronnes2025, file = paste0(path_data,"IBSA/couronnes2025.rds"))


# 8. SAVE SECTEURS ---------
saveRDS(sec2011, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_2011_2017.rds"))
saveRDS(sec2024, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20240101.rds"))
saveRDS(sec2025, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20250101.rds"))


# 9. Communes -----
dir.create(paste0(path_data,"STATBEL/communes"), recursive = TRUE)

communes2025 <- sec2025 |>
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()

saveRDS(communes2025, file = paste0(path_data,"STATBEL/communes/communes2025.rds"))

communes2024 <- sec2024 |>
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()
saveRDS(communes2024, file = paste0(path_data,"STATBEL/communes/communes2024.rds"))

communes2011 <- sec2011 |>
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()
saveRDS(communes2011, file = paste0(path_data,"STATBEL/communes/communes2011.rds"))


# 10.  Provinces-Regions-Belgique-RBC -----
dir.create(paste0(path_data,"STATBEL/autres"), recursive = TRUE)

provinces <- communes2024 |>
  group_by(cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()
saveRDS(provinces, file = paste0(path_data,"STATBEL/autres/provinces.rds"))

regions <- provinces |>
  group_by(cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()
saveRDS(regions, file = paste0(path_data,"STATBEL/autres/regions.rds"))

belgique <- regions |>
  summarise(GEOMETRY = st_union(GEOMETRY)) |>
  ungroup()
saveRDS(belgique, file = paste0(path_data,"STATBEL/autres/belgique.rds"))

rbc <- regions |>
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
saveRDS(rbc, file = paste0(path_data,"STATBEL/autres/rbc.rds"))


# Supression des fichiers temporaires

unlink(paste0(path_data,"TEMP"), recursive = TRUE, force = TRUE)


# 11. Table secteurs - quartiers - communes -  arrond - region -----------------------------------------------------------------------------

# On cree une table avec les infos administratives pour jointure a la fin de phaco_geocode()
# cat(paste0("\n", "\u29D7", " Collecte des informations par secteur statistique (jointure secteurs statistiques Statbel - quartiers IBSA)"))

# Quartiers du monitoring
# BXL_QUARTIERS_sf <- st_read(paste0(path_data, "URBIS/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.gpkg"), quiet=T,crs=31370)
# jointure spatiale avec le centroid des secteurs statistiques
# BXL_QUARTIERS <- st_join(BXL_QUARTIERS_sf, st_point_on_surface(BE_SS)) |>
#   as.data.frame() |>
#   select(cd_sector, MDRC, NAME_FRE, NAME_DUT)

# On calcule les centroides des secteurs stats (en cas d'anonymisation des donnees)
sec2024_coord <- sec2024 |>
  sf::st_point_on_surface() %>% # pipe magrittr pour utiliser le dot (.)
  mutate(
    cd_sector2024_x_31370 = sf::st_coordinates(.)[, 1] |>
      str_replace(",", ".") |>
      as.numeric() |>
      round(3),
    cd_sector2024_y_31370 = sf::st_coordinates(.)[, 2] |>
      str_replace(",", ".") |>
      as.numeric() |>
      round(3)
  ) |>
  as.data.frame() |>
  select(cd_sector2024, cd_sector2024_x_31370, cd_sector2024_y_31370)

table_secteurs_prov_commune_quartier <- sec2024 |>
  left_join(sec2024_coord, by = "cd_sector2024") |>
  as.data.frame() |>
  select(
    cd_sector2024,
    cd_sector2024_x_31370,
    cd_sector2024_y_31370,
    tx_sector_descr_fr,
    tx_sector_descr_nl,
    cd_sub_munty,
    tx_sub_munty_fr,
    tx_sub_munty_nl,
    cd_munty_refnis,
    tx_munty_descr_fr,
    tx_munty_descr_nl,
    cd_dstr_refnis,
    tx_munty_descr_fr,
    tx_munty_descr_nl,
    cd_prov_refnis,
    tx_prov_descr_fr,
    tx_prov_descr_nl,
    cd_rgn_refnis,
    tx_rgn_descr_fr,
    tx_rgn_descr_nl,
    quartier_code,
    quartier_nom_fr,
    quartier_nom_nl
  )

  # select(-tx_sector_descr_de, -tx_munty_descr_de, -tx_adm_dstr_descr_de,
  #        -tx_rgn_descr_de, -cd_country,- cd_nuts_lvl1, -cd_nuts_lvl2, -cd_nuts_lvl3,
  #        -ms_area_ha, -ms_perimeter_m, -dt_situation, -GEOMETRY, -tx_prov_descr_de)
  # NOTE : dans BE_SS version gpkg, le champ geometrie = "geom" et non "geometry" => PKOI ? Réponse: une histoire de convention parfois liés aux formats des fichiers, ça peut être geom, geometry, the_geom en minuscule ou majuscule ...

saveRDS(table_secteurs_prov_commune_quartier, file=paste0(path_data, "STATBEL/secteurs_statistiques/table_secteurs_prov_commune_quartier.rds"))

# cat(paste0("\r", colourise("\u2714", fg="green"), " Collecte des informations par secteur statistique (jointure secteurs statistiques Statbel - quartiers IBSA)"))


# 12. Liste des communes adjacentes par commune --------------------------------------------------------------------------------------------

# On cree une liste des communes adjacentes par commune (via INS recode)
# cat(paste0("\n", "\u29D7", " Cr", "\u00e9", "ation de la table des communes adjacentes (Statbel)"))

# D'abord un recodage car codes postaux et INS n'ont pas de relation bi-univoque : https://statbel.fgov.be/fr/propos-de-statbel/methodologie/classifications/geographie
BE_communes <- sec2024 |>
  mutate(cd_munty_refnis = case_when(
    cd_munty_refnis == "21004" |
      cd_munty_refnis == "21005" |
      cd_munty_refnis == "21009" ~ "21004-21005-21009",
    cd_munty_refnis == "23088" |
      cd_munty_refnis == "23096" ~ "23088-23096",
    TRUE ~ cd_munty_refnis
  )) |>
  group_by(cd_munty_refnis) |>
  summarize(GEOMETRY = sf::st_union(GEOMETRY))

nb <- spdep::poly2nb(BE_communes)
mat <- spdep::nb2mat(nb, style = "B")
colnames(mat) <- BE_communes$cd_munty_refnis
mat <- mat |>
  as.data.frame() |>
  mutate(cd_munty_refnis = BE_communes$cd_munty_refnis) |>
  tidyr::pivot_longer(cols = 1:last_col(1), names_to = "cd_munty_refnis_voisin", values_to = "voisin") |>
  filter(voisin == 1) |>
  select(-voisin)

# Au cas ou le repertoire est pas existant
dir.create(paste0(path_data,"BeST/PREPROCESSED"), recursive = TRUE)
saveRDS(mat, file = paste0(path_data, "BeST/PREPROCESSED/table_commune_adjacentes.rds"))

# cat(paste0("\r", colourise("\u2714", fg="green"), " Cr", "\u00e9", "ation de la table des communes adjacentes (Statbel)"))


# # TESTS
#
# for (i in
# c(
#   "rues", "adresses",
#   "sec","sec2024","sec2025","sec2011",
#   "sec_bxl","sec_bxl2011", "sec_bxl2024", "sec_bxl2025",
#   "communes", "communes2011","communes2024","communes2025",
#   "communes_bxl", "communes_bxl2011","communes_bxl2024","communes_bxl2025",
#   "quartiers", "quartiers2011","quartiers2024", "quartiers2025",
#   "provinces", "regions", "belgique", "rbc")) {
#
#   test<- phaco_data(i)
#   cat("\n")
#   cat(i)
# }
#
# phaco_data("slkdjlk")


# sec2024$<-phaco_data("sec_bxl2024")
#
#
# mf_map(sec2024,
#        type="typo",
#        var="QuartierSS_Gwwijk")
#
#
# mf_map(sec2024,
#        type="typo",
#        var="BassinFR")

