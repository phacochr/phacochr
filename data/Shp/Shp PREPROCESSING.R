
# NOTE : le répertoire doit être réglé comme dans le script principal

# 1) BELGIQUE =============================================================================================================================

# Belgique : secteurs statistiques

BE_SS <- st_read("Shp/sh_statbel_statistical_sectors_31370_20220101.sqlite/sh_statbel_statistical_sectors_20220101.sqlite") %>%
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
  summarize(geometry = st_union(geometry))
st_write(obj = BE_communes, dsn = "Shp/PREPROCESSED/BE_communes_PREPROCESSED.gpkg")

# Belgique : provinces
BE_provinces <- BE_SS %>%
  group_by(tx_prov_descr_fr) %>%
  summarize(geometry = st_union(geometry))
st_write(obj = BE_provinces, dsn = "Shp/PREPROCESSED/BE_provinces_PREPROCESSED.gpkg")

# Belgique : régions
BE_regions <- BE_SS %>%
  group_by(tx_rgn_descr_fr) %>%
  summarize(geometry = st_union(geometry))
st_write(obj = BE_regions, dsn = "Shp/PREPROCESSED/BE_regions_PREPROCESSED.gpkg")

# Belgique : tout le pays
BELGIQUE <- BE_SS %>%
  summarize(geometry = st_union(geometry))
st_write(obj = BELGIQUE, dsn = "Shp/PREPROCESSED/BELGIQUE_PREPROCESSED.gpkg")


# 2) BRUXELLES ============================================================================================================================

# Bruxelles : secteurs statistiques
BXL_SS <- BE_SS %>% 
  filter(tx_rgn_descr_fr == "Région de Bruxelles-Capitale")
st_write(obj = BXL_SS, dsn = "Shp/PREPROCESSED/BXL_SS_PREPROCESSED.gpkg")

# Bruxelles : Quartiers du monitoring
BXL_QUARTIERS <- st_read("Shp/URBIS_ADM_MD/UrbAdm_MONITORING_DISTRICT.shp") %>%
  st_set_crs(31370) 
st_write(obj = BXL_QUARTIERS, dsn = "Shp/PREPROCESSED/BXL_quartiers_PREPROCESSED.gpkg")

# Bruxelles : Communes
BXL_communes <- BXL_SS %>%
  group_by(tx_munty_descr_fr) %>%
  summarize(geometry = st_union(geometry))
st_write(obj = BXL_communes, dsn = "Shp/PREPROCESSED/BXL_communes_PREPROCESSED.gpkg")

# Bruxelles : toute la région
BRUXELLES <- BXL_SS %>%
  summarize(geometry = st_union(geometry))
st_write(obj = BRUXELLES, dsn = "Shp/PREPROCESSED/BRUXELLES_PREPROCESSED.gpkg")

rm(BE_SS, BE_communes, BE_provinces, BE_regions, BELGIQUE, BXL_SS, BXL_communes, BRUXELLES, BXL_QUARTIERS)
