
library(sf)
library(readr)
library(dplyr)
library(rappdirs)
library(readxl)

path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/"))


# Codes postaux -----
dir.create(paste0(path_data,"STATBEL/code_postaux"), recursive = TRUE)
dir.create(paste0(path_data,"TEMP"))


download.file("https://statbel.fgov.be/sites/default/files/files/documents/Over%20Statbel/Conversion%20Postal%20code_Refnis%20code_va01012019.xlsx",
              paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012019.xlsx"), mode = "wb")

# download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/ConversionPostalcode_Refniscode_va01012019.xlsx",
#               paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012019.xlsx"), mode = "wb")

# download.file("https://statbel.fgov.be/sites/default/files/Over_Statbel_FR/Nomenclaturen/Conversion%20Postal%20code_Refnis%20code_va01012025.xlsx",
#               paste0(path_data,"STATBEL/code_postaux/Conversion\ Postal\ code_Refnis\ code_va01012025.xlsx"))


# Fichiers IBSA -----
dir.create(paste0(path_data,"IBSA"), recursive = TRUE)

# Correspondance ...-2024
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/MQ_Communes_Quartiers_Secteurs.xlsx",
              paste0(path_data,"IBSA/MQ_Communes_Quartiers_Secteurs.xlsx"), mode = "wb")

# Correspondance 2025-...
download.file("https://github.com/phacochr/phacochr_data/raw/main/data_phacochr/conversion_secteur_quartier_2025.csv",
              paste0(path_data,"IBSA//conversion_secteur_quartier_2025.csv"))


# Secteurs statistiques -----
dir.create(paste0(path_data,"STATBEL/secteurs_statistiques"), recursive = TRUE)

## 2025 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip",
              paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite"))

sec2025 <- st_read(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20250101.sqlite/sh_statbel_statistical_sectors_31370_20250101.sqlite/sh_statbel_statistical_sectors_31370_20250101.sqlite"))

quartier_sec_2025<-read_delim(paste0(path_data,"IBSA/conversion_secteur_quartier_2025.csv"), delim = ";") %>%
  rename(cd_sector2025= secteurstatistique_code) %>%
  select(cd_sector2025, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2025 <- sec2025 %>%
  left_join(quartier_sec_2025, by = c("cd_sector"= "cd_sector2025"))

# #BXL
# sec_bxl2025<-sec2025%>%
#   filter(!is.na(quartier_code))
#
# # test
# nrow(sec_bxl2025)==nrow( sec2025 %>% filter(tx_rgn_descr_fr=="Région de Bruxelles-Capitale"))

# SAVE
saveRDS(sec2025, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20250101.rds"))
# saveRDS(sec_bxl2025, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20250101.rds"))

## 2024 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip",
              paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite"))

sec2024 <- st_read(paste0(path_data,"TEMP/sh_statbel_statistical_sectors_31370_20240101.sqlite/sh_statbel_statistical_sectors_31370_20240101.sqlite/sh_statbel_statistical_sectors_31370_20240101.sqlite"))

quartier_sec_2024 <- read_excel(paste0(path_data,"IBSA/MQ_Communes_Quartiers_Secteurs.xlsx")) %>%
  rename(cd_sector2024 = SecteurStatistique_Code,
         quartier_nom_nl = Quartier_Nom_NL,
         quartier_nom_fr = Quartier_Nom_FR,
         quartier_code = Quartier_Code) %>%
  select(cd_sector2024, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2024 <- sec2024 %>%
  left_join(quartier_sec_2024, by = c("cd_sector"= "cd_sector2024"))

# #BXL
# sec_bxl2024<-sec2024%>%
#   filter(!is.na(quartier_code))
#
# # test
# nrow(sec_bxl2024)==nrow( sec2024 %>% filter(tx_rgn_descr_fr=="Région de Bruxelles-Capitale"))

saveRDS(sec2024, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20240101.rds"))
# saveRDS(sec_bxl2024, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_20240101.rds"))

## 2011 -----
download.file("https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_spatialite.zip",
              paste0(path_data,"TEMP/sh_statbel_spatialite2011.zip"))
unzip(paste0(path_data,"TEMP/sh_statbel_spatialite2011.zip"), exdir = paste0(path_data,"TEMP/sh_statbel_spatialite2011"))

sec2011 <- st_read(paste0(path_data,"TEMP/sh_statbel_spatialite2011/sh_statbel_statistical_sectors.sqlite")) %>%
  st_set_crs(31370)

quartier_sec_2024 <- read_excel(paste0(path_data,"IBSA/MQ_Communes_Quartiers_Secteurs.xlsx")) %>%
  rename(cd_sector2024 = SecteurStatistique_Code,
         quartier_nom_nl = Quartier_Nom_NL,
         quartier_nom_fr = Quartier_Nom_FR,
         quartier_code = Quartier_Code) %>%
  select(cd_sector2024, quartier_code,quartier_nom_fr, quartier_nom_nl  )

sec2011 <- sec2011 %>%
  left_join(quartier_sec_2024, by = c("cd_sector"= "cd_sector2024"))

# # BXL
# sec_bxl2011<-sec2011%>%
#   filter(!is.na(quartier_code))
#
# # test
# nrow(sec_bxl2011)==nrow( sec2011 %>% filter(tx_rgn_descr_fr=="Région de Bruxelles-Capitale"))

# SAVE
saveRDS(sec2011, file = paste0(path_data,"STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_31370_2011_2017.rds"))


# Quartiers du monitoring -----

## 2025 -----
sec_bxl2025 <- sec2025 %>%
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2025 <- sec_bxl2025 %>%
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl ) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()

saveRDS(quartiers2025, file = paste0(path_data,"IBSA/quartiers2025.rds"))

## 2024 -----
sec_bxl2024 <- sec2024 %>%
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2024 <- sec_bxl2024 %>%
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl ) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()

saveRDS(quartiers2024, file = paste0(path_data,"IBSA/quartiers2024.rds"))

## 2011 -----
sec_bxl2011 <- sec2011 %>%
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
quartiers2011 <- sec_bxl2011 %>%
  group_by(quartier_code,quartier_nom_fr, quartier_nom_nl) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()

saveRDS(quartiers2011, file = paste0(path_data,"IBSA/quartiers2011.rds"))


# Communes -----
dir.create(paste0(path_data,"STATBEL/communes"), recursive = TRUE)

communes2025 <- sec2025 %>%
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()

saveRDS(communes2025, file = paste0(path_data,"STATBEL/communes/communes2025.rds"))

communes2024 <- sec2024 %>%
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()
saveRDS(communes2024, file = paste0(path_data,"STATBEL/communes/communes2024.rds"))

communes2011 <- sec2011 %>%
  group_by(cd_munty_refnis,tx_munty_descr_fr, tx_munty_descr_nl, tx_munty_descr_de,
           cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()
saveRDS(communes2011, file = paste0(path_data,"STATBEL/communes/communes2011.rds"))


# Autres -----
dir.create(paste0(path_data,"STATBEL/autres"), recursive = TRUE)

provinces <- communes2024 %>%
  group_by(cd_prov_refnis, tx_prov_descr_fr, tx_prov_descr_nl, tx_prov_descr_de,
           cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()
saveRDS(provinces, file = paste0(path_data,"STATBEL/autres/provinces.rds"))

regions <- provinces %>%
  group_by(cd_rgn_refnis,tx_rgn_descr_fr, tx_rgn_descr_nl, tx_rgn_descr_de) %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()
saveRDS(regions, file = paste0(path_data,"STATBEL/autres/regions.rds"))

belgique <- regions %>%
  summarise(GEOMETRY = st_union(GEOMETRY)) %>%
  ungroup()
saveRDS(belgique, file = paste0(path_data,"STATBEL/autres/belgique.rds"))

rbc <- regions %>%
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
saveRDS(rbc, file = paste0(path_data,"STATBEL/autres/rbc.rds"))


# Supression des fichiers temporaires

unlink(paste0(path_data,"TEMP"), recursive = TRUE, force = TRUE)


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
