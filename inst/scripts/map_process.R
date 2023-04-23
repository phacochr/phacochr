
# MAP_PROCESS.R
# Ce script permet de recalculer les géométries des différentes entités administratives belges/bruxelloise, nécessaires à la fonction phaco_map()
# Le répertoire de provenance/destination est le répertoire d'installation par défaut de phacochr

library(rappdirs)
library(sf)
library(forcats)
library(dplyr)

path_data <- gsub("\\\\", "/", paste0(user_data_dir("phacochr"),"/data_phacochr/")) # bricolage pour windows

# 1) BELGIQUE =============================================================================================================================

# Belgique : secteurs statistiques
BE_SS <- st_read(paste0(path_data, "STATBEL/secteurs_statistiques/sh_statbel_statistical_sectors_20220101.gpkg"), quiet = T, crs = 31370) %>%
  st_set_crs(31370) %>%
  st_zm(drop = TRUE)

BE_SS$tx_prov_descr_fr <- BE_SS$tx_prov_descr_fr %>%
  fct_recode(
    "Anvers" = "Province d’Anvers",
    "Flandre occidentale" = "Province de Flandre occidentale",
    "Flandre orientale" = "Province de Flandre orientale",
    "Liège" = "Province de Liège",
    "Namur" = "Province de Namur",
    "Brabant flamand" = "Province du Brabant flamand",
    "Brabant wallon" = "Province du Brabant wallon",
    "Hainaut" = "Province du Hainaut",
    "Limbourg" = "Province du Limbourg",
    "Luxembourg" = "Province du Luxembourg"
  )
BE_SS$tx_munty_descr_fr <- BE_SS$tx_munty_descr_fr %>%
  fct_recode(
    "Molenbeek" = "Molenbeek-Saint-Jean",
    "Saint-Josse" = "Saint-Josse-ten-Noode"
  )

# Belgique : communes
BE_communes <- BE_SS %>%
  group_by(tx_munty_descr_fr) %>%
  summarize(geom = st_union(geom))
st_write(obj = BE_communes, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BE_communes_PREPROCESSED.gpkg"), append = FALSE)

# Belgique : provinces
BE_provinces <- BE_SS %>%
  group_by(tx_prov_descr_fr) %>%
  summarize(geom = st_union(geom))
st_write(obj = BE_provinces, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg"), append = FALSE)

# Belgique : régions
BE_regions <- BE_SS %>%
  group_by(tx_rgn_descr_fr) %>%
  summarize(geom = st_union(geom))
st_write(obj = BE_regions, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BE_regions_PREPROCESSED.gpkg"), append = FALSE)

# Belgique : tout le pays
BELGIQUE <- BE_SS %>%
  summarize(geom = st_union(geom))
st_write(obj = BELGIQUE, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg"), append = FALSE)


# 2) BRUXELLES ============================================================================================================================

# Bruxelles : secteurs statistiques
BXL_SS <- BE_SS %>%
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
st_write(obj = BXL_SS, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg"), append = FALSE)

# Bruxelles : Quartiers du monitoring
URBIS <- st_read(paste0(path_data,"URBIS/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.gpkg"), quiet = T) %>%
  st_set_crs(31370)

# Table Sect stat - quartiers monitoring -> jointure spatiale avec le centroide des secteurs statistiques
table_QUARTIER_SS <- st_join(URBIS, st_centroid(BXL_SS)) %>%
  as.data.frame() %>%
  select(cd_sector, MDRC, NAME_FRE, NAME_DUT)

BXL_QUARTIERS <- BXL_SS %>%
  left_join(table_QUARTIER_SS, by = "cd_sector") %>%
  group_by(MDRC) %>%
  summarize(geom = st_union(geom))
st_write(obj = BXL_QUARTIERS, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BXL_quartiers_PREPROCESSED.gpkg"), append = FALSE)

# Bruxelles : Communes
BXL_communes <- BXL_SS %>%
  group_by(tx_munty_descr_fr) %>%
  summarize(geom = st_union(geom))
st_write(obj = BXL_communes, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg"), append = FALSE)

# Bruxelles : toute la région
BRUXELLES <- BXL_SS %>%
  summarize(geom = st_union(geom))
st_write(obj = BRUXELLES, dsn = paste0(path_data,"STATBEL/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg"), append = FALSE)

rm(BE_SS, BE_communes, BE_provinces, BE_regions, BELGIQUE, BXL_SS, URBIS, table_QUARTIER_SS, BXL_QUARTIERS, BXL_communes, BRUXELLES)
