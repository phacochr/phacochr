# run checkhelper::print_globals() to get the globalVariables

globalVariables(unique(c(
  # phaco_geocode:
  "address_join", "address_join_geocoding", "address_join_street",
  "arrond", "cd_sector", "code_postal_to_geocode", "approx_num",
  "distance_FINAL_detected", "distance_jw", "house_number_sans_lettre",
  "i", "ID_address", "langue_FINAL_detected", "min_jw", "nom_propre_abv",
  "num_rue_clean", "num_rue_text", "num_rue_to_geocode", "postal_id",
  "Refnis code", "Region", "rue_recoded", "rue_recoded_apostrophe",
  "rue_recoded_avenue", "rue_recoded_Bis", "rue_recoded_boite",
  "rue_recoded_boulevard", "rue_recoded_BP", "rue_recoded_burg",
  "rue_recoded_chaussee", "rue_recoded_Commandant",
  "rue_recoded_dokter", "rue_recoded_double_lettre_end",
  "rue_recoded_koning", "rue_recoded_lettre_end",
  "rue_recoded_Lieutenant", "rue_recoded_No", "rue_recoded_num",
  "rue_recoded_parenthese", "rue_recoded_place", "rue_recoded_professor",
  "rue_recoded_Rdc", "rue_recoded_Rez", "rue_recoded_route",
  "rue_recoded_Rue", "rue_recoded_Saint", "rue_recoded_slash",
  "rue_recoded_square", "rue_recoded_steenweg", "rue_recoded_tiret",
  "rue_recoded_virgule", "rue_to_geocode", "street_FINAL_detected",
  "street_FINAL_detected_full", "street_id_phaco", "type_geocoding",
  "x_31370", "y_31370", "export_table", "dist_fuzzy",
  "mid_arrond", "mid_cd_sector", "mid_num", "mid_postcode", "mid_x_31370", "mid_y_31370", "type_geocoding2",
  # phaco_update:
  "arrond2", "cd_country", "cd_dstr_refnis", "cd_munty_refnis", "cd_nuts_lvl1",
  "cd_nuts_lvl2", "cd_nuts_lvl3", "code_postal", "Count", "dt_situation", "geom",
  "key_street_unique", "King", "Last", "Last_double", "MDRC", "ms_area_ha",
  "MS_FREQUENCY", "ms_perimeter_m", "NAME_DUT", "NAME_FRE", "postcode",
  "Saint", "street_FINAL_detected_Origin", "tx_adm_dstr_descr_de", "TX_FST_NAME",
  "tx_munty_descr_de", "tx_prov_descr_de", "tx_rgn_descr_de", "tx_rgn_descr_fr",
  "tx_sector_descr_de", "voisin",
  # phaco_update : extract_street:
  "key_street_unique",
  # phaco_update : select_id_street:
  "house_number", "postcode", "street_name", "streetname_de", "streetname_fr",
  "streetname_nl",
  # phaco_map_s:
  "cd_rgn_refnis"
)))
