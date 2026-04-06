# run checkhelper::print_globals() to get the globalVariables

globalVariables(unique(c(
  # phaco_best_data_update:
  ".", "ancien_nom_rue", "ancienne_denomination", "arrond", "arrond2", "cd_country", "cd_dstr_refnis", "cd_munty_refnis", "cd_nuts_lvl1", "cd_nuts_lvl2", "cd_nuts_lvl3", "cd_sector", "cd_sector2024", "cd_sector2024_x_31370", "cd_sector2024_y_31370", "code_postal", "Count", "cp_n_abv", "cp_n_eng", "cp_n_fr", "cp_n_nl", "CP_NAME", "detect", "dt_situation", "Gemeentenaam", "GEOMETRY", "house_number_sans_lettre", "id_regex_belgium_street", "key_street_unique", "King", "langue_detected", "Last", "Last_double", "mid_cd_sector2024", "mid_num", "mid_x_31370", "mid_y_31370", "ms_area_ha", "MS_FREQUENCY", "ms_perimeter_m", "n_cp_abv", "n_cp_eng", "n_cp_fr", "n_cp_nl", "name", "name_abv", "name_eng", "Nom commune", "nom_propre_abv", "nouveau_nom", "postal_id", "postcode", "Refnis code", "rue_recoded", "rue_recoded_apostrophe", "rue_recoded_avenue", "rue_recoded_boulevard", "rue_recoded_burg", "rue_recoded_chaussee", "rue_recoded_Commandant", "rue_recoded_dokter", "rue_recoded_koning", "rue_recoded_Lieutenant", "rue_recoded_parenthese", "rue_recoded_place", "rue_recoded_professor", "rue_recoded_route", "rue_recoded_Saint", "rue_recoded_square", "rue_recoded_steenweg", "rue_recoded_virgule", "Saint", "section", "street_detected", "street_detected_Origin", "street_id_phaco", "tx_adm_dstr_descr_de", "TX_FST_NAME", "tx_munty_descr_de", "tx_prov_descr_de", "tx_rgn_descr_de", "tx_rgn_descr_fr", "tx_sector_descr_de", "voisin", "x_31370", "y_31370",
  # phaco_best_data_update : extract_street:
  "key_street_unique", "langue_detected", "postal_id", "street_detected", "street_id_phaco",
  # phaco_best_data_update : join_ss_adress:
  "geometry",
  # phaco_best_data_update : select_id_street:
  "house_number", "house_number_sans_lettre", "postcode", "status", "street_id_phaco", "street_name", "streetname_de", "streetname_fr", "streetname_nl", "x_31370", "y_31370",
  # phaco_data:
  "tx_rgn_descr_fr",
  # phaco_geocode:
  "address_join", "address_join_geocoding", "address_join_street", "ancien_nom_rue", "approx_num", "arrond", "cd_sector2024", "cd_sector2024_x_31370", "cd_sector2024_y_31370", "cd_sector2025", "code_postal_to_geocode", "dist_fuzzy", "distance_jw", "ecart", "house_number_sans_lettre", "langue_detected", "mid_cd_sector2024", "mid_num", "mid_x_31370", "mid_y_31370", "min_jw", "n_selection", "nom_propre_abv", "num_rue_clean", "num_rue_text", "num_rue_to_geocode", "phaco_id_adress", "postal_id", "Refnis code", "Region", "rue_recoded", "rue_recoded_apostrophe", "rue_recoded_avenue", "rue_recoded_Bis", "rue_recoded_boite", "rue_recoded_boulevard", "rue_recoded_BP_CP", "rue_recoded_burg", "rue_recoded_chaussee", "rue_recoded_code_postal", "rue_recoded_Commandant", "rue_recoded_commune", "rue_recoded_deux_points", "rue_recoded_dokter", "rue_recoded_koning", "rue_recoded_lettre_end", "rue_recoded_lettre_end2", "rue_recoded_Lieutenant", "rue_recoded_No", "rue_recoded_num", "rue_recoded_parenthese", "rue_recoded_place", "rue_recoded_professor", "rue_recoded_Rdc", "rue_recoded_Rez", "rue_recoded_route", "rue_recoded_Rue", "rue_recoded_Saint", "rue_recoded_slash", "rue_recoded_square", "rue_recoded_steenweg", "rue_recoded_tiret", "rue_recoded_virgule", "rue_to_geocode", "selection", "street_detected", "street_detected_full", "street_detected_utf8", "street_id_phaco", "type_geocoding", "type_geocoding2", "x_31370", "y_31370",
  # phaco_map_s:
  "CARTO_weight", "cd_rgn_refnis", "cd_sector2024", "geometry", "n_cd_sector"
)))
