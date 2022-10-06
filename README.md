
<!-- README.md is generated from README.Rmd. Please edit that file -->

# phacochr

<!-- badges: start -->
<!-- badges: end -->

PhaochR est un géocodeur pour la Belgique. A partir, d’une liste
d’adresse, il permet de retrouver les coordonnées X-Y nécessaire à toute
analyse spatiale.

Le logiciel fonctionne à partir des données publiques BeST Address
(“<https://opendata.bosa.be>”) compilées par BOSA à partir des données
régionales Urbis (Région de Bruxelles-Capitale), CRAB (Région flamande)
et ICAR (Région wallonne). Il réalise des corrections orthographiques
préalables (Regex), il fait une jointure inexacte avec les noms de rues
(fuzzyjoin) et il trouve le numéro le plus proche et de préférence du
même côté de la rue si le numéro n’est pas trouvé.

## Installation

Vous pouvez installer le package phacochr depuis
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("phacochr/phacochr")
```

## Example

``` r
library(phacochr)
x<- data.frame(nom= c("Observatoire de la Santé et du Social", "ULB"),
               rue= c("rue Beilliard","avenue Antoine Depage"),
               num=c("71", "30"),
               code_postal=c("1040","1000"))

phaco_geocode(data_to_geocode = x,
              colonne_rue= "rue",
              colonne_num_rue= "num",
              colonne_code_postal="code_postal",
              preloading_RAM= T
                )
#> # A tibble: 3 × 13
#>   Region           Effectifs `Rue détectée (…` `stringdist (m…` `Géocodé (% to…`
#>   <chr>                <int>             <dbl>            <dbl>            <dbl>
#> 1 Total (original)         2                NA             NA                 NA
#> 2 Bruxelles                2               100              0.5              100
#> 3 Total (final)            2               100              0.5              100
#> # … with 8 more variables: `Approx (% géocodés)` <dbl>, `Elarg (n)` <int>,
#> #   `Abrev (n)` <int>, `Rue FR` <dbl>, `Rue NL` <dbl>, `Rue DE` <dbl>,
#> #   `Coord non valides` <int>, Dupliqués <int>
#> $summary
#> # A tibble: 3 × 13
#>   Region           Effectifs `Rue détectée (…` `stringdist (m…` `Géocodé (% to…`
#>   <chr>                <int>             <dbl>            <dbl>            <dbl>
#> 1 Total (original)         2                NA             NA                 NA
#> 2 Bruxelles                2               100              0.5              100
#> 3 Total (final)            2               100              0.5              100
#> # … with 8 more variables: `Approx (% géocodés)` <dbl>, `Elarg (n)` <int>,
#> #   `Abrev (n)` <int>, `Rue FR` <dbl>, `Rue NL` <dbl>, `Rue DE` <dbl>,
#> #   `Coord non valides` <int>, Dupliqués <int>
#> 
#> $data_geocoded
#>   ID_address                                   nom                   rue num
#> 1          1 Observatoire de la Santé et du Social         rue Beilliard  71
#> 2          2                                   ULB avenue Antoine Depage  30
#>   code_postal           rue_recoded recode street_FINAL_detected num_rue_clean
#> 1        1040         rue Beilliard                 Rue Belliard            71
#> 2        1000 avenue Antoine Depage        Avenue Antoine Depage            30
#>   code_postal_to_geocode street_id_phaco langue_FINAL_detected nom_propre_abv
#> 1                   1040            1525                    FR           <NA>
#> 2                   1000             875                    FR           <NA>
#>   distance_FINAL_detected type_geocoding house_number_sans_lettre x_31370
#> 1                       1             NA                       71  150373
#> 2                       0             NA                       30  151105
#>   y_31370 cd_sector dif tx_sector_descr_nl tx_sector_descr_fr cd_sub_munty
#> 1  170090 21004B13-   0        TRIERSTRAAT    TREVES (RUE DE)       21004B
#> 2  166831 21004C61-   0             V.U.B.             U.L.B.       21004C
#>     tx_sub_munty_nl         tx_sub_munty_fr tx_munty_dstr cd_munty_refnis
#> 1 BRUSSEL-WETSTRAAT BRUXELLES-RUE DE LA LOI          <NA>           21004
#> 2    BRUSSEL-LOUISA        BRUXELLES-LOUISE          <NA>           21004
#>   tx_munty_descr_nl tx_munty_descr_fr cd_dstr_refnis
#> 1           Brussel         Bruxelles          21000
#> 2           Brussel         Bruxelles          21000
#>               tx_adm_dstr_descr_nl                 tx_adm_dstr_descr_fr
#> 1 Arrondissement Brussel-Hoofdstad Arrondissement de Bruxelles-Capitale
#> 2 Arrondissement Brussel-Hoofdstad Arrondissement de Bruxelles-Capitale
#>   cd_prov_refnis tx_prov_descr_nl tx_prov_descr_fr cd_rgn_refnis
#> 1           <NA>             <NA>             <NA>         04000
#> 2           <NA>             <NA>             <NA>         04000
#>                  tx_rgn_descr_nl              tx_rgn_descr_fr MDRC
#> 1 Brussels Hoofdstedelijk Gewest Région de Bruxelles-Capitale   35
#> 2 Brussels Hoofdstedelijk Gewest Région de Bruxelles-Capitale  106
#>            NAME_FRE   NAME_DUT
#> 1 QUARTIER EUROPEEN EUROPAWIJK
#> 2          BOONDAEL   BOONDAAL
#> 
#> $data_geocoded_sf
#> Simple feature collection with 2 features and 39 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 150373 ymin: 166831 xmax: 151105 ymax: 170090
#> Projected CRS: BD72 / Belgian Lambert 72
#>   ID_address                                   nom                   rue num
#> 1          1 Observatoire de la Santé et du Social         rue Beilliard  71
#> 2          2                                   ULB avenue Antoine Depage  30
#>   code_postal           rue_recoded recode street_FINAL_detected num_rue_clean
#> 1        1040         rue Beilliard                 Rue Belliard            71
#> 2        1000 avenue Antoine Depage        Avenue Antoine Depage            30
#>   code_postal_to_geocode street_id_phaco langue_FINAL_detected nom_propre_abv
#> 1                   1040            1525                    FR           <NA>
#> 2                   1000             875                    FR           <NA>
#>   distance_FINAL_detected type_geocoding house_number_sans_lettre cd_sector dif
#> 1                       1             NA                       71 21004B13-   0
#> 2                       0             NA                       30 21004C61-   0
#>   tx_sector_descr_nl tx_sector_descr_fr cd_sub_munty   tx_sub_munty_nl
#> 1        TRIERSTRAAT    TREVES (RUE DE)       21004B BRUSSEL-WETSTRAAT
#> 2             V.U.B.             U.L.B.       21004C    BRUSSEL-LOUISA
#>           tx_sub_munty_fr tx_munty_dstr cd_munty_refnis tx_munty_descr_nl
#> 1 BRUXELLES-RUE DE LA LOI          <NA>           21004           Brussel
#> 2        BRUXELLES-LOUISE          <NA>           21004           Brussel
#>   tx_munty_descr_fr cd_dstr_refnis             tx_adm_dstr_descr_nl
#> 1         Bruxelles          21000 Arrondissement Brussel-Hoofdstad
#> 2         Bruxelles          21000 Arrondissement Brussel-Hoofdstad
#>                   tx_adm_dstr_descr_fr cd_prov_refnis tx_prov_descr_nl
#> 1 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
#> 2 Arrondissement de Bruxelles-Capitale           <NA>             <NA>
#>   tx_prov_descr_fr cd_rgn_refnis                tx_rgn_descr_nl
#> 1             <NA>         04000 Brussels Hoofdstedelijk Gewest
#> 2             <NA>         04000 Brussels Hoofdstedelijk Gewest
#>                tx_rgn_descr_fr MDRC          NAME_FRE   NAME_DUT
#> 1 Région de Bruxelles-Capitale   35 QUARTIER EUROPEEN EUROPAWIJK
#> 2 Région de Bruxelles-Capitale  106          BOONDAEL   BOONDAAL
#>                geometry
#> 1 POINT (150373 170090)
#> 2 POINT (151105 166831)
```
