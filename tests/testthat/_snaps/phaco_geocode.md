# phaco_geocode() works

    Code
      geocoded
    Output
      $summary
      # A tibble: 3 x 16
        Region               n `Valid rue(%)` `Rue detect.(%valid)` `stringdist (moy)`
        <chr>            <int>          <dbl>                 <dbl>              <dbl>
      1 Total (original)     2             NA                    NA                 NA
      2 Bruxelles            2            100                   100                  0
      3 Total                2            100                   100                  0
      # i 11 more variables: `Geocode(%tot)` <dbl>, `Geocode(%valid)` <dbl>,
      #   `Approx.(n)` <dbl>, `Elarg.(n)` <int>, `Mid.(n)` <int>, `Abrev.(n)` <int>,
      #   `Rue FR` <dbl>, `Rue NL` <dbl>, `Rue DE` <dbl>, `Coord non valides` <int>,
      #   Dupliques <int>
      
      $data_geocoded
        ID_address                                   nom                   rue num
      1          1 Observatoire de la Santé et du Social          rue Belliard  71
      2          2                                   ULB avenue Antoine Depage  30
        code_postal           rue_recoded recode street_FINAL_detected num_rue_clean
      1        1040          rue Belliard                 Rue Belliard            71
      2        1000 avenue Antoine Depage        Avenue Antoine Depage            30
        code_postal_to_geocode street_id_phaco langue_FINAL_detected nom_propre_abv
      1                   1040            1525                    FR           <NA>
      2                   1000             874                    FR           <NA>
        mid_num mid_x_31370 mid_y_31370 mid_cd_sector dist_fuzzy type_geocoding
      1     122      150646      170037     21004B2WJ          0               
      2      25      151061      166750     21004C61-          0               
        house_number_sans_lettre x_31370 y_31370 cd_sector approx_num
      1                       71  150373  170090 21004B13-          0
      2                       30  151105  166831 21004C61-          0
        tx_sector_descr_nl tx_sector_descr_fr cd_sub_munty   tx_sub_munty_nl
      1        TRIERSTRAAT    TREVES (RUE DE)       21004B BRUSSEL-WETSTRAAT
      2             V.U.B.             U.L.B.       21004C    BRUSSEL-LOUISA
                tx_sub_munty_fr tx_munty_dstr cd_munty_refnis tx_munty_descr_nl
      1 BRUXELLES-RUE DE LA LOI          <NA>           21004           Brussel
      2        BRUXELLES-LOUISE          <NA>           21004           Brussel
        tx_munty_descr_fr cd_dstr_refnis             tx_adm_dstr_descr_nl
      1         Bruxelles          21000 Arrondissement Brussel-Hoofdstad
      2         Bruxelles          21000 Arrondissement Brussel-Hoofdstad
                        tx_adm_dstr_descr_fr cd_prov_refnis tx_prov_descr_nl
      1 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
      2 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
        tx_prov_descr_fr cd_rgn_refnis                tx_rgn_descr_nl
      1             <NA>         04000 Brussels Hoofdstedelijk Gewest
      2             <NA>         04000 Brussels Hoofdstedelijk Gewest
                     tx_rgn_descr_fr MDRC          NAME_FRE   NAME_DUT
      1 Région de Bruxelles-Capitale   35 QUARTIER EUROPEEN EUROPAWIJK
      2 Région de Bruxelles-Capitale  106          BOONDAEL   BOONDAAL
        cd_sector_x_31370 cd_sector_y_31370
      1            150467            170197
      2            150989            166782
      
      $data_geocoded_sf
      Simple feature collection with 2 features and 45 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: 150373 ymin: 166831 xmax: 151105 ymax: 170090
      Projected CRS: BD72 / Belgian Lambert 72
        ID_address                                   nom                   rue num
      1          1 Observatoire de la Santé et du Social          rue Belliard  71
      2          2                                   ULB avenue Antoine Depage  30
        code_postal           rue_recoded recode street_FINAL_detected num_rue_clean
      1        1040          rue Belliard                 Rue Belliard            71
      2        1000 avenue Antoine Depage        Avenue Antoine Depage            30
        code_postal_to_geocode street_id_phaco langue_FINAL_detected nom_propre_abv
      1                   1040            1525                    FR           <NA>
      2                   1000             874                    FR           <NA>
        mid_num mid_x_31370 mid_y_31370 mid_cd_sector dist_fuzzy type_geocoding
      1     122      150646      170037     21004B2WJ          0               
      2      25      151061      166750     21004C61-          0               
        house_number_sans_lettre cd_sector approx_num tx_sector_descr_nl
      1                       71 21004B13-          0        TRIERSTRAAT
      2                       30 21004C61-          0             V.U.B.
        tx_sector_descr_fr cd_sub_munty   tx_sub_munty_nl         tx_sub_munty_fr
      1    TREVES (RUE DE)       21004B BRUSSEL-WETSTRAAT BRUXELLES-RUE DE LA LOI
      2             U.L.B.       21004C    BRUSSEL-LOUISA        BRUXELLES-LOUISE
        tx_munty_dstr cd_munty_refnis tx_munty_descr_nl tx_munty_descr_fr
      1          <NA>           21004           Brussel         Bruxelles
      2          <NA>           21004           Brussel         Bruxelles
        cd_dstr_refnis             tx_adm_dstr_descr_nl
      1          21000 Arrondissement Brussel-Hoofdstad
      2          21000 Arrondissement Brussel-Hoofdstad
                        tx_adm_dstr_descr_fr cd_prov_refnis tx_prov_descr_nl
      1 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
      2 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
        tx_prov_descr_fr cd_rgn_refnis                tx_rgn_descr_nl
      1             <NA>         04000 Brussels Hoofdstedelijk Gewest
      2             <NA>         04000 Brussels Hoofdstedelijk Gewest
                     tx_rgn_descr_fr MDRC          NAME_FRE   NAME_DUT
      1 Région de Bruxelles-Capitale   35 QUARTIER EUROPEEN EUROPAWIJK
      2 Région de Bruxelles-Capitale  106          BOONDAEL   BOONDAAL
        cd_sector_x_31370 cd_sector_y_31370              geometry
      1            150467            170197 POINT (150373 170090)
      2            150989            166782 POINT (151105 166831)
      

